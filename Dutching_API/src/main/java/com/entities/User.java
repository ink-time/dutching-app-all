package com.entities;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

import java.io.Serializable;

@Entity
@Table(name= "users")
public class User implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "user_name", nullable = false)
    @JsonProperty("user_name")
    private String userName;

    @Column(name = "profile_pic", nullable = true)
    @JsonProperty("profile_pic")
    private String profilePic;

    @Column(name = "email", nullable = false)
    private String email;

    public User(String userName, String profilePic, String email) {
        this.userName = userName;
        this.profilePic = profilePic;
        this.email = email;
    }

    protected User() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getProfilePic() {
        return profilePic;
    }

    public void setProfilePic(String profilePic) {
        this.profilePic = profilePic;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}


