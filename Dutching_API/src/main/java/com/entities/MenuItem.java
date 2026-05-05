package com.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

import java.io.Serializable;

@Entity
@Table(name= "menu_Items")
@JsonIgnoreProperties(ignoreUnknown = true)
public class MenuItem implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description", nullable = true)
    private String description;

    @Column(name = "unit_price", nullable = false)
    @JsonProperty("unit_price")
    private Double unitPrice;

    @Column(name = "main_type", nullable = true)
    @JsonProperty("main_type")
    private String mainType;

    @Column(name = "secondary_type", nullable = true)
    @JsonProperty("secondary_type")
    private String secondaryType;

    @ManyToOne
    @JoinColumn(name = "menu_Id")
    private Menu menu;

    public MenuItem(String name, String description, Double unitPrice, String mainType, String secondaryType, Menu menu) {
        this.name = name;
        this.description = description;
        this.unitPrice = unitPrice;
        this.mainType = mainType;
        this.secondaryType = secondaryType;
        this.menu = menu;
    }

    protected MenuItem() {
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(Double unitPrice) {
        this.unitPrice = unitPrice;
    }

    public String getMainType() {
        return mainType;
    }

    public void setMainType(String mainType) {
        this.mainType = mainType;
    }

    public String getSecondaryType() {
        return secondaryType;
    }

    public void setSecondaryType(String secondaryType) {
        this.secondaryType = secondaryType;
    }

    public Menu getMenu() {
        return menu;
    }

    public void setMenu(Menu menu) {
        this.menu = menu;
    }

}


