class Category {
  final int? id;
  final String name;
  final String colorHex; // เก็บสีเป็น Hex String เช่น "#FF0000" [cite: 75]
  final String iconKey;  // เก็บชื่อไอคอน [cite: 76]

  Category({this.id, required this.name, required this.colorHex, required this.iconKey});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_key': iconKey,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorHex: map['color_hex'],
      iconKey: map['icon_key'],
    );
  }
}

// alias for previous name (if any code referenced CategoryModel)
typedef CategoryModel = Category;