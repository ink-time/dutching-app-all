import 'menu.dart';

class Restaurant {
  final int id;
  final String name;
  final String? type;
  final double avgPricePerson;
  final String location;
  final String? imageUrl;
  final Menu? menu;

  Restaurant({
    required this.id,
    required this.name,
    this.type,
    required this.avgPricePerson,
    required this.location,
    this.imageUrl,
    this.menu,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'], // We can cast to string because ww should not be doing any operations with the id.
      name: json['name'],
      type: json['type'],
      // We use as num so it accepts either int or double from the JSON
      avgPricePerson: (json['avgPricePerson'] as num).toDouble(),
      location: json['location'],
      imageUrl: json['imageUrl'],
      // We map the menu only if it exists in the json
      // (this can be useful to differentiate from the DTO and the normal restaurant,
      // although Idk if I will ever use the complete restaurant here.)
      menu: json['menu'] != null ? Menu.fromJson(json['menu']) : null,
    );
  }
  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is Restaurant && runtimeType == other.runtimeType && id == other.id;

  // @override
  // int get hashCode => id.hashCode;
}
