package com.dto;

public class SimpleRestaurantDTO {
    private Long id;
    private String name;
    private String type;
    private Double avgPricePerson;
    private String location;
    private String imageUrl;

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

}
