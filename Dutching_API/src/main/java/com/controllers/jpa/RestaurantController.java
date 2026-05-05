package com.controllers.jpa;

import com.dto.RestaurantDTO;
import com.dto.SimpleRestaurantDTO;
import com.entities.Restaurant;
import com.services.RestaurantService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

// This class will handle incoming HTTP requests

@RestController
@RequestMapping("/api/restaurants")
@CrossOrigin(origins= "*") // So Flutter doesnt get CORS errorrs (produced by mobile security systems when they block requests
public class RestaurantController {
    private final RestaurantService restaurantService;
    public RestaurantController(RestaurantService restaurantService){
        this.restaurantService = restaurantService;
    }

    @GetMapping
    public ResponseEntity<List<SimpleRestaurantDTO>> getAll(){
        List<SimpleRestaurantDTO> restaurants = restaurantService.getAll();
        return ResponseEntity.ok(restaurants);
    }

    @GetMapping(value="/{id}")
    public ResponseEntity<RestaurantDTO> getByID(@PathVariable Long id){
//        try  {
            RestaurantDTO dto = restaurantService.getByID(id);
            return ResponseEntity.ok(dto);
//        } catch (RuntimeException e){
//            // If the service throws the not found exception
//            return ResponseEntity.notFound().build();
//        }
    }

    @GetMapping("/search/name/{name}") //If these have the same structure as the idGetMapping, it will not work, because both mappings have the same endpoint for springboot
    public ResponseEntity<List<SimpleRestaurantDTO>> getByNameContains(@PathVariable String name){
        List<SimpleRestaurantDTO> restaurants = restaurantService.getByNameContains(name);
        return ResponseEntity.ok(restaurants);
    }
    @GetMapping("/search/type/{type}")
    public ResponseEntity<List<SimpleRestaurantDTO>> getByTypeContains(@PathVariable String type){
        List<SimpleRestaurantDTO> restaurants = restaurantService.getByTypeContains(type);
        return ResponseEntity.ok(restaurants);
    }

    // GET BY AVGPRICEPERSON Would be nice


    // Users probably should not be using this tbh, so maybe I take out? Well, maybe the app can use it?
    @PostMapping
    public ResponseEntity<Restaurant> create(@RequestBody Restaurant restaurant){
        Restaurant restaurantSaved = restaurantService.insert(restaurant);
            return ResponseEntity.ok(restaurantSaved);

    }

    @PutMapping("/put/{id}")
    public ResponseEntity<Restaurant> updateByID(@PathVariable Long id, Restaurant newData){
        Restaurant restaurantPut = restaurantService.updateByID(id, newData);
        return ResponseEntity.ok(restaurantPut);
    }

    @PatchMapping("/patch/{id}")
    public ResponseEntity<Restaurant> patch(@PathVariable Long id, @RequestBody Map<String, Object> changes){
        Restaurant restaurantPatched = restaurantService.patch(id, changes);
        return ResponseEntity.ok(restaurantPatched);
    }

    @DeleteMapping("/delete/{id}") // This didn't work without changing the mapping to what it is now (it used to be: /{id})
    public ResponseEntity<Void> delete(@PathVariable Long id){
        restaurantService.delete(id);
        return ResponseEntity.noContent().build(); // It returns a 204 no content found or deleted
    }


}
