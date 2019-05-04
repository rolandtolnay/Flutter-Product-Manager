import 'package:flutter/material.dart';

class Product {
  String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String userId;
  final String userEmail;
  final bool isFavorite;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.userId,
    @required this.userEmail,
    this.isFavorite = false,
  });

  Product.fromMap(Map<String, dynamic> map)
      : this.id = map['id'],
        this.title = map['title'],
        this.description = map['description'],
        this.price = map['price'],
        this.imageUrl = map['imageUrl'],
        this.userId = map['userId'],
        this.userEmail = map['userEmail'],
        this.isFavorite = map['isFavorite'] ?? false;

  Product.from(Product product, {bool isFavorite})
      : this.id = product.id,
        this.title = product.title,
        this.description = product.description,
        this.price = product.price,
        this.imageUrl = product.imageUrl,
        this.userId = product.userId,
        this.userEmail = product.userEmail,
        this.isFavorite = isFavorite ?? product.isFavorite;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'userEmail': userEmail,
      'userId': userId,
    };
  }
}
