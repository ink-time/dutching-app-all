package com.controllers.jpa;

import com.entities.User;
import com.entities.User;
import org.springframework.web.bind.annotation.*;
import com.services.UserService;

import java.util.List;
import java.util.Map;

// PUT is used to update a whole element, like a whole employee in the database, and not one of the attributes of an employee
// PATCH is used to modify one attribute, or element from an employee, not the whole employee.
@RestController
@RequestMapping("/user")
public class UserController {
    private final UserService userService;
    public UserController(UserService userService){
        this.userService = userService;

    }
    @GetMapping
    public List<User> getAll(){
    return userService.getAll();
    }

    @GetMapping(value="/{id}")
    //@RequestMapping(value="/{id}", method = RequestMethod.GET)
    //@ResponseBody
    public User getByID(@PathVariable Long id){
        return userService.getByID(id);
    }

    @GetMapping("Nombre/{userName}") //If these have the same structure as the idGetMapping, it will not work, because both mappings have the same endpoint for springboot
    public List<User> getByNombre(@RequestBody String userName){
        return userService.getByUserName(userName);
    }
    @GetMapping("Puesto/{email}")
    public User getByEmail(@RequestBody String email){
        return userService.getByEmail(email);
    }


    @PostMapping
    public User create(@RequestBody User user){
            return userService.insert(user);
    }

    @PutMapping("/put/{id}")
    public User updateByID(@PathVariable Long id, User newData){
        return userService.updateByID(id, newData);
    }

    @PatchMapping("/patch/{id}")
    public User patch(@PathVariable Long id, @RequestBody Map<String, Object> changes){
        return userService.patch(id, changes);
    }

    @DeleteMapping("/delete/{id}") // This didn't work without changing the mapping to what it is now (it used to be: /{id})
    public void delete(@PathVariable Long id){
        userService.delete(id);
    }



}
