package com.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

import java.io.Serializable;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name= "restaurants")
@JsonIgnoreProperties(ignoreUnknown = true)
public class Restaurant implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "type", nullable = true)
    private String type;

    @Column(name = "avg_price_person", nullable = false)
    @JsonProperty("avg_price_person")
    private Double avgPricePerson;

    @Column(name = "location", nullable = false)
    private String location;

    @Column(name = "image_url", nullable = true)
    @JsonProperty("image_url")
    private String imageUrl;

    @OneToMany(mappedBy = "restaurant", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private Set<Menu> menus = new HashSet<>();

    @Transient // No quiero que se tenga en cuenta para la base de datos, pero tal vez será util en la api en elm futuro?
    private String url;

    public Restaurant(String name, String type, Double avgPricePerson, String location, String imageUrl) {
        this.name = name;
        this.type = type;
        this.avgPricePerson = avgPricePerson;
        this.location = location;
        this.imageUrl = imageUrl;
    }

    public Restaurant() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Double getAvgPricePerson() {
        return avgPricePerson;
    }

    public void setAvgPricePerson(Double avgPricePerson) {
        this.avgPricePerson = avgPricePerson;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Set<Menu> getMenus() {
        return menus;
    }

    public void setMenus(Set<Menu> menus) {
        this.menus = menus;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}


