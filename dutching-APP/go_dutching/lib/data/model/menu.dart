import 'menu_item.dart';

class Menu {
  final int id;
  final List<MenuItem> menuItems;

  Menu({required this.id, required this.menuItems});

  factory Menu.fromJson(Map<String, dynamic> json) {
    var list = json['menuItems'] as List;
    return Menu(
      id: json['id'],
      menuItems: list.map((i) => MenuItem.fromJson(i)).toList(),
    );
  }
}
