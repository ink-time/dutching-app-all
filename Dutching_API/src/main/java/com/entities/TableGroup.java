package com.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

@Entity
@Table(name= "tables")
@JsonIgnoreProperties(ignoreUnknown = true)
public class TableGroup implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "start_Hour", nullable = false)
    @JsonProperty("start_hour")
    private Timestamp startHour;

    @Column(name = "end_Hour", nullable = true)
    @JsonProperty("end_hour")
    private Timestamp endHour;

    @Column(name = "table_Code", nullable = true)
    @JsonProperty("table_code")
    private String tableCode; // Starts as null, but gets saved for history's sake?

    @ManyToOne
    @JoinColumn(name= "restaurant_Id", nullable = false)
    private Restaurant restaurant;

    @ManyToOne
    @JoinColumn(name= "menu_Id", nullable = false)
    private Menu menu;

    // YOU HAVE TO CREATE THE TABLE ENTITY LOVE
    @ManyToMany
    @JoinTable(name = "table_Participants",
    joinColumns = @JoinColumn(name ="table_Id"),
    inverseJoinColumns = @JoinColumn(name = "user_Id"))
    private List<User> users;

    @OneToMany(mappedBy = "table", cascade = CascadeType.ALL)
    private List<OrderItem> orderItems;

    // It is created without the endHour? Or maybe it is created once the table is closed in the front?
    public TableGroup(String name, Timestamp startHour, Timestamp endHour, String tableCode, Restaurant restaurant, Menu menu, List<User> users) {
        this.name = name;
        this.startHour = startHour;
        this.endHour = endHour;
        this.tableCode = tableCode;
        this.users = users;
        this.restaurant = restaurant;
        this.menu = menu;
    }

    protected TableGroup() {
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

    public Timestamp getStartHour() {
        return startHour;
    }

    public void setStartHour(Timestamp startHour) {
        this.startHour = startHour;
    }

    public Timestamp getEndHour() {
        return endHour;
    }

    public void setEndHour(Timestamp endHour) {
        this.endHour = endHour;
    }

    public String getTableCode() {
        return tableCode;
    }

    public void setTableCode(String tableCode) {
        this.tableCode = tableCode;
    }

    public List<User> getUsers() {
        return users;
    }

    public void setUsers(List<User> users) {
        this.users = users;
    }

    public Restaurant getRestaurant() {
        return restaurant;
    }

    public void setRestaurant(Restaurant restaurant) {
        this.restaurant = restaurant;
    }

    public Menu getMenu() {
        return menu;
    }

    public void setMenu(Menu menu) {
        this.menu = menu;
    }
}


