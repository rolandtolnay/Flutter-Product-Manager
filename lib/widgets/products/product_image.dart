import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({Key key, @required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      image: NetworkImage(url),
      height: 300.0,
      fit: BoxFit.cover,
      placeholder: const AssetImage('assets/food.jpg'),
    );
  }
}
