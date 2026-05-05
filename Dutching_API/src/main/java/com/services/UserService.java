package com.services;

import com.entities.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import com.repositories.jpa.IUserRepository;


import java.util.List;
import java.util.Map;

@Service
public class UserService {
    private static final Logger log = LoggerFactory.getLogger(UserService.class);
    private final IUserRepository userRepository;
    // Here we have the logic, so the way we want the methods to work.
    // We can also have all the conditions that we use to make the methods more solid, and harder to brak in production.
    // We have to create controls or validations that check if the user that is asking for the information is in a certain
    // privilege group

    public UserService(IUserRepository userRepository){
        this.userRepository = userRepository;
    }
    public List<User> getAll(){
        return userRepository.findAll();
    }

    public List<User> getByUserName(String nombre){
        return userRepository.findByUserName(nombre);
    }

    public User getByEmail(String email){
        return userRepository.findByEmail(email);
    }

    public User getByID(Long id){
        return userRepository.findById(id).orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

    }
    // Creating employee
    public User insert(User user){
        return userRepository.save(user);
    }

    // Total update (PUT)
    public User updateByID(Long id, User datosNuevos){
        User user = getByID(id);
        user.setUserName(datosNuevos.getUserName());
        user.setEmail(datosNuevos.getEmail());
        user.setProfilePic(datosNuevos.getProfilePic());
        return userRepository.save(user);
    }

    // Partial update (PATCH)
    public User patch(Long id, Map<String, Object> changes){
        User user = getByID(id);
        if(changes.containsKey("userName")){
            user.setUserName((String) changes.get("userName"));

        }
        if(changes.containsKey("email")){
            user.setEmail((String) changes.get("email"));
        }
        if(changes.containsKey("profilePic")){
            user.setProfilePic((String) changes.get("profilePic"));
        }

        return userRepository.save(user);

    }


    public void delete(Long id){userRepository.deleteById(id);
    }
}
