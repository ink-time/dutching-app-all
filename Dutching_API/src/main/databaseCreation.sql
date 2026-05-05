CREATE TABLE users (
id BIGSERIAL PRIMARY KEY,
user_Name VARCHAR (100) NOT NULL,
profile_Pic VARCHAR (200),
email VARCHAR (150) NOT NULL UNIQUE
);


CREATE TABLE restaurants (
id BIGSERIAL PRIMARY KEY,
type VARCHAR (200) NOT NULL,
name VARCHAR (200) NOT NULL,
avg_Price_Person NUMERIC (10, 2) NOT NULL,
location VARCHAR (200) NOT NULL,
image_Url VARCHAR (260)
);


CREATE TABLE menus (
id BIGSERIAL PRIMARY KEY,
active BOOLEAN NOT NULL,
restaurant_Id BIGINT NOT NULL,
constraint fk_restaurants_1 FOREIGN KEY (restaurant_Id) REFERENCES restaurants (id) ON DELETE CASCADE
);

CREATE TABLE menu_Items (
id BIGSERIAL PRIMARY KEY,
name VARCHAR (200) NOT NULL,
description VARCHAR (400),
main_Type VARCHAR (50),
secondary_Type VARCHAR (70),
unit_Price DECIMAL (14, 2) NOT NULL CHECK (unit_Price >= 0),
menu_Id BIGINT NOT NULL,
constraint fk_menus_1 FOREIGN KEY (menu_Id) REFERENCES menus (id) ON DELETE CASCADE
);


CREATE TABLE tables (
id BIGSERIAL PRIMARY KEY,
name VARCHAR (100),
start_Hour TIMESTAMP NOT NULL,
end_Hour TIMESTAMP NOT NULL,
table_Code VARCHAR(6) UNIQUE,
restaurant_Id BIGINT NOT NULL,
menu_Id BIGINT NOT NULL,
constraint fk_restaurants_2 FOREIGN KEY (restaurant_Id) REFERENCES restaurants (id) ON DELETE CASCADE,
constraint fk_menus_2 FOREIGN KEY (menu_Id) REFERENCES menus (id) ON DELETE CASCADE
);

CREATE TABLE table_Participants (
    table_Id BIGINT NOT NULL,
    user_Id BIGINT NOT NULL,
    PRIMARY KEY (table_Id, user_Id),
    CONSTRAINT fk_tables_1 FOREIGN KEY (table_Id) REFERENCES tables(id) ON DELETE CASCADE,
    CONSTRAINT fk_users_1 FOREIGN KEY (user_Id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE order_Items (
    id BIGSERIAL PRIMARY KEY,
    table_Id BIGINT NOT NULL,
    menu_Item_Id BIGINT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    historical_Unit_Price NUMERIC(10, 2) NOT NULL CHECK (historical_Unit_Price >= 0),
    CONSTRAINT fk_tables_2 FOREIGN KEY (table_Id) REFERENCES tables(id) ON DELETE CASCADE,
    CONSTRAINT fk_menu_items_1 FOREIGN KEY (menu_Item_Id) REFERENCES menu_Items(id)
);

CREATE TABLE order_Item_Users (
    order_Item_Id BIGINT NOT NULL,
    user_Id BIGINT NOT NULL,
    PRIMARY KEY (order_Item_Id, user_Id),
    CONSTRAINT fk_order_items_1 FOREIGN KEY (order_Item_Id) REFERENCES order_Items(id) ON DELETE CASCADE,
    CONSTRAINT fk_users_2 FOREIGN KEY (user_Id) REFERENCES users(id) ON DELETE CASCADE
);