import 'package:hive/hive.dart';

part 'toy.g.dart';

@HiveType(typeId: 1)
class Toy extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final int stockQuantity;

  @HiveField(6)
  final String? imageUrl;

  Toy({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.stockQuantity,
    this.imageUrl,
  });

  factory Toy.fromJson(Map<String, dynamic> json) {
    return Toy(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
    };
  }
}
