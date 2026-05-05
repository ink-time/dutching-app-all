package com.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.io.Serializable;
import java.util.List;

@Entity
@Table(name= "order_items")
@JsonIgnoreProperties(ignoreUnknown = true)
public class OrderItem implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name= "table_id", nullable = false)
    private TableGroup table;

    @ManyToOne
    @JoinColumn(name = "menu_item_id", nullable = false)
    private MenuItem menuItem;

    @Column(name = "quantity", nullable = true)
    private Integer quantity;

    @Column(name = "historical_unit_price", nullable = false)
    private Double historicUnitPrice;

    @ManyToMany
    @JoinTable(name = "order_item_users",
    joinColumns = @JoinColumn( name ="order_item_id"),
    inverseJoinColumns = @JoinColumn(name = "user_id"))
    private List<User> users;

    public OrderItem(TableGroup table, MenuItem menuItem, Integer quantity, Double historicUnitPrice, List<User> users) {
        this.table = table;
        this.menuItem = menuItem;
        this.quantity = quantity;
        this.historicUnitPrice = historicUnitPrice;
        this.users = users;
    }
    public OrderItem(){
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public TableGroup getTable() {
        return table;
    }

    public void setTable(TableGroup table) {
        this.table = table;
    }

    public MenuItem getMenuItem() {
        return menuItem;
    }

    public void setMenuItem(MenuItem menuItem) {
        this.menuItem = menuItem;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Double getHistoricUnitPrice() {
        return historicUnitPrice;
    }

    public void setHistoricUnitPrice(Double historicUnitPrice) {
        this.historicUnitPrice = historicUnitPrice;
    }

    public List<User> getUsers() {
        return users;
    }

    public void setUsers(List<User> users) {
        this.users = users;
    }
}


