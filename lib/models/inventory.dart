class Inventory {
  final int? id;
  final String name;
  final int color;

  Inventory({this.id, required this.name, required this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }
}
