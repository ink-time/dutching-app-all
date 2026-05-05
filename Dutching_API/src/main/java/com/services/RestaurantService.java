package com.services;

import com.dto.MenuDTO;
import com.dto.MenuItemDTO;
import com.dto.RestaurantDTO;
import com.dto.SimpleRestaurantDTO;
import com.entities.Menu;
import com.entities.Restaurant;
import com.repositories.jpa.IRestaurantRepository;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;


@Service
public class RestaurantService {
    private static final Logger log = LoggerFactory.getLogger(RestaurantService.class);
    private final IRestaurantRepository restaurantRepository;
    // Here we have the logic, so the way we want the methods to work.
    // We can also have all the conditions that we use to make the methods more solid, and harder to brak in production.
    // We have to create controls or validations that check if the restaurant that is asking for the information is in a certain
    // privilege group

    private RestaurantDTO mapToRestaurantDTO(Restaurant entity) {
        RestaurantDTO dto = new RestaurantDTO();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setLocation(entity.getLocation());
        dto.setImageUrl(entity.getImageUrl());
        dto.setType(entity.getType());
        dto.setAvgPricePerson(entity.getAvgPricePerson());

        if (entity.getMenus() != null && !entity.getMenus().isEmpty()) {
            entity.getMenus().stream()
                    .filter(m -> Boolean.TRUE.equals(m.getActive())) // If I dont do this, the findFirst will get the first menu it finds, no matter if it is active or not.
                    .findFirst().ifPresent(
                    activeMenu -> {
                        dto.setMenu(mapToMenuDTO(activeMenu));
                    }
            );
        }
        return dto;

    }
    private MenuDTO mapToMenuDTO(Menu entity) {
        MenuDTO dto = new MenuDTO();
        dto.setId(entity.getId());

        // If the items are null, the menu is not considered null, but
        if (entity.getMenuItems() == null) {
            dto.setMenuItems(new ArrayList<>());
            return dto;
        }

        List<MenuItemDTO> itemData = entity.getMenuItems().stream()
                .map(menuItem -> {
                    MenuItemDTO itemDto = new MenuItemDTO();
                    itemDto.setId(menuItem.getId());
                    itemDto.setName(menuItem.getName());
                    itemDto.setDescription(menuItem.getDescription());
                    itemDto.setMainType(menuItem.getMainType());
                    itemDto.setUnitPrice(menuItem.getUnitPrice());
                    return itemDto;
                        }
                ).toList(); // .collect(Collectors.toList()) se puede usar también, pero a partir de java 16 no hace falta.
        dto.setMenuItems(itemData);
        return dto;
    }
    // SimpleRestaurant is used for lists, since menu is not needed. I still dont know if I want all the data apart from menu
    private SimpleRestaurantDTO mapToSimpleResDTO(Restaurant entity) {
        SimpleRestaurantDTO dto = new SimpleRestaurantDTO();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setLocation(entity.getLocation());
        dto.setImageUrl(entity.getImageUrl());
        dto.setType(entity.getType());
        dto.setAvgPricePerson(entity.getAvgPricePerson());
        return dto;
    }

    public RestaurantService(IRestaurantRepository restaurantRepository){
        this.restaurantRepository = restaurantRepository;
    }
    // This is actually what is gonna be used to get all the restaurants for lists and similar.
    public List<SimpleRestaurantDTO> getAll(){
        return restaurantRepository.findAll().stream()
                .map(this::mapToSimpleResDTO)
                .collect(Collectors.toList());
    }

    public RestaurantDTO getByID(Long id){
        Restaurant restaurant = restaurantRepository.findByIdWithMenu(id).orElseThrow(() -> new RuntimeException("Restaurante no encontrado"));
        return mapToRestaurantDTO(restaurant);
    }
    public Restaurant getByIDwithMenu(Long id){
        return restaurantRepository.findByIdWithMenu(id).orElseThrow(() -> new RuntimeException("Restaurante no encontrado"));
    }

    public Optional<Restaurant> getByName(String name){
        return restaurantRepository.findByName(name);
    }

    public List<SimpleRestaurantDTO> getByNameContains(String name){
        List<Restaurant> entities = restaurantRepository.findByNameContainingIgnoreCase(name);
        return entities.stream()
                .map(this::mapToSimpleResDTO)
                .collect(Collectors.toList());
    }

    public List<SimpleRestaurantDTO> getByTypeContains(String type){
        List<Restaurant> entities = restaurantRepository.findByTypeContainingIgnoreCase(type);
        return entities.stream()
                .map(this::mapToSimpleResDTO)
                .collect(Collectors.toList());
    }


    // Creating Restaurant
    @Transactional // So the operation stops suddenly, the data doesn't get written or read half-baked.
    public Restaurant insert(Restaurant restaurant){
            restaurant.setId(null); // This way, when we insert many restaurants in a row, the database will handle the id asignation with the autonumeric.
            return restaurantRepository.save(restaurant);
    }

    // Total update (PUT)
    @Transactional
    public Restaurant updateByID(Long id, Restaurant newData){
        Restaurant restaurant = getByIDwithMenu(id);
        restaurant.setName(newData.getName());
        restaurant.setType(newData.getType());
        restaurant.setAvgPricePerson(newData.getAvgPricePerson());
        restaurant.setLocation(newData.getLocation());
        restaurant.setImageUrl(newData.getImageUrl());
        return restaurantRepository.save(restaurant);
    }

    // Partial update (PATCH)
    @Transactional
    public Restaurant patch(Long id, Map<String, Object> changes){
        Restaurant restaurant = getByIDwithMenu(id);
        if(changes.containsKey("name")){
            restaurant.setName((String) changes.get("name"));

        }
        if(changes.containsKey("type")){
            restaurant.setType((String) changes.get("type"));
        }
        if(changes.containsKey("avgPricePerson")){
            restaurant.setAvgPricePerson((Double) changes.get("avgPricePerson"));
        }
        if(changes.containsKey("location")){
            restaurant.setLocation((String) changes.get("location"));
        }
        if(changes.containsKey("imageUrl")){
            restaurant.setImageUrl((String) changes.get("imageUrl"));
        }

        return restaurantRepository.save(restaurant);

    }

    @Transactional
    public void delete(Long id){
        restaurantRepository.deleteById(id);
    }

}
