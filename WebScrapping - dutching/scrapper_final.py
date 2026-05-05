import re
import json
import time
import random
import logging
import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
from bs4 import BeautifulSoup
from dataclasses import dataclass, field
from typing import Optional, List
from urllib.parse import urlparse

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
log = logging.getLogger(__name__)

BASE_URL   = "https://www.thefork.es"
CITY_PATH  = "/restaurantes/alcala-de-henares-c12515"

# ── Data models ────────────────────────────────────────────────────────────────

@dataclass
class MenuItem:
    name: str
    description: Optional[str] = None
    unitPrice:  Optional[float] = None
    type:        Optional[str]  = None   # starter | main | dessert | drink | other

@dataclass
class Menu:
    name:  str = "Menú principal"
    items: List[MenuItem] = field(default_factory=list)

@dataclass
class Restaurant:
    name:                str
    url:                 str
    type:                Optional[str]   = None
    avgPricePerson: Optional[float] = None
    location:             Optional[str]   = None
    imageUrl:           Optional[str]   = None
    menus:               List[Menu]      = field(default_factory=list)

# ── Driver ─────────────────────────────────────────────────────────────────────

def init_driver() -> uc.Chrome:
    """
    undetected-chromedriver patches Chrome at the binary level.
    """
    options = uc.ChromeOptions()
    options.add_argument("--start-maximized")
    options.add_argument("--lang=es-ES,es")
    # No correr en headless ayuda a evadir la seguridad de Cloudflare
    return uc.Chrome(options=options, version_main=146)

def human_delay(min_s=2.5, max_s=6.0):
    time.sleep(random.uniform(min_s, max_s))

def human_scroll(driver, steps=4):
    for _ in range(steps):
        driver.execute_script(f"window.scrollBy(0, {random.randint(120, 250)});")
        time.sleep(random.uniform(0.3, 0.9))

# ── List scraper ───────────────────────────────────────────────────────────────

def scrape_restaurant_list(driver) -> List[dict]:
    results = []
    page = 1

    while True:
        url = f"{BASE_URL}{CITY_PATH}?page={page}"
        log.info(f"Listing page {page}: {url}")
        driver.get(url)
        human_delay(5, 10)       # Más largo en la primera carga
        human_scroll(driver)

        soup  = BeautifulSoup(driver.page_source, "html.parser")
        cards = soup.find_all("a", id=lambda x: x and x.startswith("restaurant-"))

        if not cards:
            cards = soup.select('a[href*="/restaurante/"]')

        if not cards:
            log.warning("No cards found — stopping pagination.")
            break

        for card in cards:
            name = card.get("aria-label") or card.get_text(strip=True)
            href = card.get("href", "")
            if href and not href.startswith("http"):
                href = BASE_URL + href
            if name and href:
                results.append({"name": name, "url": href})

        log.info(f"  {len(cards)} restaurants found on page {page}.")

        next_btn = soup.select_one('a[rel="next"], a[data-testid="pagination-next"]')
        if not next_btn:
            break

        page += 1
        human_delay(4, 8)

    return results

# ── Detalle scraper ─────────────────────────────────────────────────────────────

def scrape_restaurant_detail(driver, url: str) -> dict:
    log.info(f"  Detail → {url}")
    driver.get(url)
    human_delay(3, 7)
    human_scroll(driver)

    soup = BeautifulSoup(driver.page_source, "html.parser")
    data: dict = {"url": url}

    # Extraemos los datos generales desde la página principal del restaurante
    h1 = soup.find("h1") or soup.select_one('[data-testid="restaurant-name"]')
    data["name"] = h1.get_text(strip=True) if h1 else None

    cuisine_type = soup.select_one('[data-testid="cuisine-type"], [class*="cuisine"]')
    data["type"] = cuisine_type.get_text().lower().replace("tipo de cocina", "").strip() if cuisine_type else None

    price_el = soup.select_one('[data-testid="price-range"], [class*="avgPrice"], [class*="avg-price"]')
    data["avgPricePerson"] = None
    if price_el:
        m = re.search(r"(\d+(?:[.,]\d+)?)", price_el.get_text())
        if m:
            data["avgPricePerson"] = float(m.group(1).replace(",", "."))

    addr = soup.select_one('location, [data-testid="restaurant-info-location"], [class*="location"], [class*="location"]')
    data["location"] = addr.get_text(strip=True) if addr else None

    img = soup.select_one('[class*="hero"] img, [class*="cover"] img, [data-testid="restaurant-photos-header"] img')
    data["imageUrl"] = (img.get("src") or img.get("data-src")) if img else None
    # Usamos urlparse para quedarnos solo con la ruta base (ej: /restaurante/nombre-id)
    # ignorando cualquier # o ? que venga al final
    parsed_url = urlparse(url)
    ruta_limpia = parsed_url.path.rstrip('/')
    
    # Construimos la URL apuntando directamente al menú
    menu_url = f"https://www.thefork.es{ruta_limpia}/menu"
    log.info(f"  Navegando directamente a la carta → {menu_url}")
    
    driver.get(menu_url)
    human_delay(3, 5) # Esperamos un poco a que cargue la lista de platos
    
    # Leemos el HTML de la página específica del menú
    soup_menu = BeautifulSoup(driver.page_source, "html.parser")
    data["menus"] = extract_menus(soup_menu)

    return data


def extract_menus(soup: BeautifulSoup) -> List[dict]:
    # Ahora solo tendremos UNA lista con todos los platos de la carta
    todos_los_platos = []

    sections = soup.select('div[data-testid^="SECTION-"]')

    for section in sections:
        title_el = section.find('h4')
        # Esto es el secondaryType (ej: "Antipasti", "Arroces")
        secondaryType = title_el.get_text(strip=True) if title_el else "General"
        mainType = infer_item_type(secondaryType) 

        dl = section.find('dl')
        if dl:
            filas_platos = dl.find_all('div', recursive=False)

            for fila in filas_platos:
                dt_elements = fila.find_all('dt')
                if not dt_elements:
                    continue

                item_name = dt_elements[0].get_text(strip=True)
                
                description = None
                if len(dt_elements) > 1:
                    description = dt_elements[1].get_text(strip=True)

                unitPrice = None
                dd = fila.find('dd')
                if dd:
                    texto_precio = dd.get_text(strip=True)
                    m = re.search(r"(\d+(?:[.,]\d+)?)", texto_precio)
                    if m:
                        unitPrice = float(m.group(1).replace(",", "."))

                if item_name and len(item_name) > 3:
                    # Añadimos el plato a la lista global de la carta
                    todos_los_platos.append({
                        "name":           item_name,
                        "description":    description,
                        "unitPrice":     unitPrice,
                        "mainType":      mainType,
                        "secondaryType": secondaryType
                    })

    # Devolvemos una lista con UN SOLO MENÚ que contiene todos los platos
    if todos_los_platos:
        return [{"items": todos_los_platos}]
    
    return []

def infer_item_type(section_name: str) -> str:
    s = section_name.lower()
    if any(w in s for w in ["desayuno", "brunch", "breakfast", "colazione", "prima colazione"]):
        return "breakfast"
    
    if any(w in s for w in ["entrante", "aperitivo", "entradas", "compartir", "comenzar", "nachos", 
                            "tapas", "starter", "appetizer", "antipast", "racion", "compartiendo", "picoteo", 
                            "picando", "tapa", "acompana", "acompaña", "tasca", "primero", "aperitivo" ]):
        return "starter"
    
    if any(w in s for w in ["principal", "segundo", "carne", "carni", "pescado", "pesci", "pasta", "arroz", "cachopo", 
                            "arroces", "verdura", "sugerencias", "sopa", "ensalada", "insalate", "pasta", "huevos", 
                            "taco", "burrito", "especialidades", "specialita", "chachapa", "pepit", "arepa", "milanesa", 
                            "empanada", "sabores", "hamburguesa", "grill", "sándwich", "hot dog", "horno", "pizze",
                             "parrilla", "brasa", "burger", "quesadilla", "vegetales", "huerta", "tartar" "platos",
                             "cercanía", "a la carta", "del mar", "cocina", "continuar", "plato", "bocadillo",
                             "kapsalon", "cordero", "poke", "nigiri", "maki", "roll", "temaki", "combo", "bandejas", "otros" ]):
        return "main"
    
    if any(w in s for w in ["postre", "potres", "dulce", "helado", "fruta", "tarta", "pastel", "dessert", "terminar",
                            "merienda", "dolci", "dolche"]):
        return "dessert"
    
    if any(w in s for w in ["bebida", "vino", "tinto", "blanco", "rioja", "ribera", "rosado", "blancos", "cubata",
                             "cava", "cerveza", "refresco", "copa", "café", "coffee", "zumo", "drink", "vermut", 
                            "cocktail", "cóctel", "coctel", "smoothies", "espumosos", "ron", "whisky", "ginebra",
                             "vodka", "tequila", "brandy", "cognac", "armagnac", "té", "infusiones"]):
        return "drink"
    
    return "other"

# ── Pipeline ───────────────────────────────────────────────────────────────────

def run():
    driver = init_driver()
    datos_restaurantes = [] # Lista para acumular los datos de los restaurantes

    EXCLUDED_URLS = [
        "https://www.thefork.es/restaurante/healthy-poke-alcala-de-henares-r748918",
        "https://www.thefork.es/restaurante/anexo-bistro-hostel-complutum-r751991",
        "https://www.thefork.es/restaurante/antologico-r464013",
        "https://www.thefork.es/restaurante/eximio-by-fernando-martin-r722070",
        "https://www.thefork.es/restaurante/cervantes-escuela-de-hosteleria-de-alcala-de-henares-r49078"
    ]

    try:
        log.info("=== Step 1: Restaurant list ===")
        raw_list = scrape_restaurant_list(driver)
        log.info(f"Total: {len(raw_list)} restaurants.")

        

        for i, entry in enumerate(raw_list): #[:3] para probar con menos restaurantes

        ## EXCLUIMOS LA URL DEL RESTAURANTE CON LA ESTRUCTURA PROBLEMATICA ##
            url_actual = entry["url"]
            nombre_restaurante = entry.get('name', 'Desconocido')

            if any(url_actual.startswith(excluida) for excluida in EXCLUDED_URLS):
                log.info(f"\n[]{i+1}/{len(raw_list)}] {entry['name']} -> URL excluida, saltando.")
                continue
        ##----------------------------------------------------------------##

        ### OTRA OPCIÖN, UN POCO MÄS REFINADA, PERO REQUIERE MÄS RECURSOS/TIEMPO
         ## CONTROLAMOS LA CALIDAD DE LOS DATOS DE LA CARTA/MENÚ  ##
                ## Extracción de menús en una lista
                # todos_los_platos = []
                # for menu in detail.get("menus", []):
                #     todos_los_platos.extend(menu.get("items", []))

                # # Verificación de que haya al menos un plato con precio válido
                # tiene_precios = any(plato.get("unitPrice") is not None for plato in todos_los_platos)

                # # Si no hay platos, o ninguno de ellos tiene precio válido, se descarta el menú
                # if not todos_los_platos or not tiene_precios:
                #     log.warning(f"  ⚠ {entry['name']} descartado: No se encontraron platos con precio.")
                #     continue
        ##----------------------------------------------------------------##        

            log.info(f"\n[{i+1}/{len(raw_list[:4])}] {entry['name']}")
            try:
                # Extraemos los detalles del restaurante
                detail = scrape_restaurant_detail(driver, entry["url_actual"])
                # Solo guardamos si el scraper ha conseguido traer un menú con platos
                platos = []
                for m in detail.get("menus", []):
                    platos.extend(m.get("items", []))
                
                if not platos:
                    log.warning(f"  ⚠ {nombre_restaurante} descartado: No tiene platos en el menú.")
                    continue

                #
                # Solo guardamos 'de verdad' si llega aquí. Y se crea la lista que se envia al json.
                datos_restaurantes.append(detail)
                log.info(f"  ✓ Datos extraídos y añadidos a la lista.")

            except Exception as e:
                    log.error(f"  ✗ Error en el restaurante {nombre_restaurante}: {e}")

            human_delay(5, 12)    # Pausa entre restaurantes

        # --- GUARDADO EN ARCHIVO JSON

        # # Ruta relativa para que se guarde directamente en la API cuando los junte
        #ruta_salida = "../api-spring-boot/src/main/resources/data/restaurants_thefork.json"

        #with open(ruta_salida, 'w', encoding='utf-8') as f:
            #json.dump(datos, f, ensure_ascii=False, indent=4)
        ### --------------------------------------------------------------------------------- ###

        log.info("\n=== Step 2: Guardando datos en archivo JSON ===")
        with open("restaurantes_alcala.json", "w", encoding="utf-8") as f:
            json.dump(datos_restaurantes, f, ensure_ascii=False, indent=4)
        log.info("✓ Archivo 'restaurantes_alcala.json' creado con éxito.")

    finally:
        log.info("Cerrando el navegador...")
        try:
            driver.quit()
        except OSError:
            # Captura el error de Windows (WinError 6) si ocurre al cerrar
            log.warning("Se detectó el error de controlador no válido al cerrar, pero el navegador se cerró.")
        log.info("=== Done ===")

if __name__ == "__main__":
    run()