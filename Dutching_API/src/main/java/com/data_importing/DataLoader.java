package com.data_importing;

import com.dto.RestaurantDTO;
import com.entities.Menu;
import com.entities.MenuItem;
import com.entities.Restaurant;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.repositories.jpa.IRestaurantRepository;
import jakarta.annotation.Nonnull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.*;

@Component
public class DataLoader implements CommandLineRunner {

    private final IRestaurantRepository restaurantRepository;
    private final ObjectMapper objectMapper;

    public DataLoader(IRestaurantRepository restaurantRepository, ObjectMapper objectMapper){
        this.restaurantRepository = restaurantRepository;
        this.objectMapper = objectMapper;
    }

    // Méto.do para que cada plato sepa a qué menú pertenece
    private void vincularPlatosAMenu(Menu menu) {
        if (menu.getMenuItems() != null) {
            // Si llega un plato sin precio, o con precio null, no queremos que se guarde.
            // También intentaré que no se guarden en el scrapper de python,
            // pero si alguno escapa ese filtro, está este
            menu.getMenuItems().removeIf(item -> item.getUnitPrice() == null);
            // Y tras eso, podemos vincular los platos al menú
            for (MenuItem item : menu.getMenuItems()) {
                item.setMenu(menu);
            }
        }
    }

    private void syncRestaurant(Restaurant scrapedRes) {
        Optional<Restaurant> dbResOpt = restaurantRepository.findByName(scrapedRes.getName());

        if (dbResOpt.isEmpty()) {
            // Nuevo Restaurante
            // Preparamos el menú antes de que hibernate intente guardar sin e
            if (scrapedRes.getMenus() != null && !scrapedRes.getMenus().isEmpty()) {
                Menu firstMenu = scrapedRes.getMenus().iterator().next();
                firstMenu.setActive(true);           // Lo marcamos como activo
                firstMenu.setRestaurant(scrapedRes); // Vinculamos Menu -> Restaurant
                vincularPlatosAMenu(firstMenu);      // Vinculamos Platos -> Menu
            }
            // Ahora es seguro guardarlo
            restaurantRepository.save(scrapedRes);

        } else {
            // 2. EL RESTAURANTE YA EXISTÍA
            Restaurant dbRes = dbResOpt.get();

            // Usamos Boolean.TRUE.equals para evitar un NullPointerException si por error hay un null
            Optional<Menu> currentActiveMenuOpt = dbRes.getMenus().stream()
                    .filter(m -> Boolean.TRUE.equals(m.getActive()))
                    .findFirst();

            Menu scrapedMenu = scrapedRes.getMenus().iterator().next();

            if (currentActiveMenuOpt.isPresent()) {
                Menu dbMenu = currentActiveMenuOpt.get();

                boolean structureChanged = checkStructureChanged(dbMenu, scrapedMenu);

                if (structureChanged) {
                    // Desactivamos el viejo
                    dbMenu.setActive(false);

                    // Preparamos el nuevo
                    scrapedMenu.setRestaurant(dbRes);
                    scrapedMenu.setActive(true);
                    vincularPlatosAMenu(scrapedMenu);

                    dbRes.getMenus().add(scrapedMenu);
                } else {
                    actualizarPrecios(dbMenu, scrapedMenu);
                }
            } else {
                // El restaurante existía pero por algún motivo no tenía menús activos
                scrapedMenu.setRestaurant(dbRes);
                scrapedMenu.setActive(true);
                vincularPlatosAMenu(scrapedMenu);

                if (dbRes.getMenus() == null) {
                    dbRes.setMenus(new HashSet<>());
                }
                dbRes.getMenus().add(scrapedMenu);
            }

            restaurantRepository.save(dbRes);
        }
    }

    // Compara si los nombres de los platos han cambiado
    private boolean checkStructureChanged(Menu dbMenu, Menu scrapedMenu) {
        if (dbMenu.getMenuItems().size() != scrapedMenu.getMenuItems().size()) return true;

        List<String> dbNames = dbMenu.getMenuItems().stream().map(i -> i.getName().toLowerCase()).toList();
        List<String> scrapedNames = scrapedMenu.getMenuItems().stream().map(i -> i.getName().toLowerCase()).toList();

        return !dbNames.containsAll(scrapedNames);
    }

    private void actualizarPrecios(Menu dbMenu, Menu scrapedMenu) {
        for (MenuItem scrapedItem : scrapedMenu.getMenuItems()) {
            dbMenu.getMenuItems().stream()
                    .filter(dbItem -> dbItem.getName().equalsIgnoreCase(scrapedItem.getName()))
                    .findFirst()
                    .ifPresent(dbItem -> dbItem.setUnitPrice(scrapedItem.getUnitPrice()));
        }
    }

    @Override
    public void run(@Nonnull String... args) throws Exception {
        if (restaurantRepository.count() == 0) {
            System.out.println("Loading data from the Scraper JSON...");

            // Mapeamos el JSON a una lista de objetos Restaurant
            try (InputStream inputStream = getClass().getResourceAsStream("/data/restaurants_thefork.json")) {
                List<Restaurant> incomingRestaurants = objectMapper.readValue(inputStream, new TypeReference<List<Restaurant>>(){});

                for (Restaurant scrapedRes : incomingRestaurants) {
                    // En lugar de guardarlo a lo bruto, usamos nuestra nueva lógica
                    syncRestaurant(scrapedRes);
                }
                System.out.println("¡Sincronización completada!");
            } catch (Exception e) {
                System.err.println("Error while loading the data from the JSON file: " + e.getMessage());
                e.printStackTrace(); // Cambiado de e.getStackTrace() que no imprime nada
            }
        } else {
            System.out.println("Base de datos ya poblada. Saltando carga de datos.");
        }
    }
}