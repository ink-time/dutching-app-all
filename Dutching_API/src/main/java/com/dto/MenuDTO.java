package com.dto;

import com.entities.MenuItem;
import com.entities.Restaurant;
import jakarta.persistence.*;

import java.io.Serializable;
import java.util.List;

public class MenuDTO {
    private Long id;
    private List<MenuItemDTO> menuItems;



    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public List<MenuItemDTO> getMenuItems() {
        return menuItems;
    }

    public void setMenuItems(List<MenuItemDTO> menuItemsDTO) {
        this.menuItems = menuItemsDTO;
    }
}


