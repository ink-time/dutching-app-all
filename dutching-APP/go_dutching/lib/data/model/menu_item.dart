class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double unitPrice;
  final String? mainType;
  final String? secondaryType;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.unitPrice,
    this.mainType,
    this.secondaryType,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      mainType: json['mainType'],
      secondaryType: json['secondaryType'],
    );
  }
}
