import 'dart:async';

import 'package:flutter/material.dart';
import 'package:product_manager/widgets/products/product_image.dart';

import '../model/product.dart';
import '../widgets/products/location_label.dart';
import '../widgets/products/product_label.dart';
import '../widgets/title_label.dart';

class ProductDetailPage extends StatelessWidget {
  //
  final Product product;

  const ProductDetailPage(this.product);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Column(
          children: <Widget>[
            ProductImage(url: product.imageUrl),
            const SizedBox(height: 20.0),
            const LocationLabel('Union Square, San Francisco'),
            const SizedBox(height: 12.0),
            TitleLabel(product.title),
            ProductPriceLabel(product.price),
            const SizedBox(height: 12.0),
            _buildDescription(),
            const SizedBox(height: 12.0),
            Text('id: ${product.id}'),
          ],
        ),
      ),
    );
  }

  Container _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(product.description,
          style: const TextStyle(
            fontFamily: 'Oswald',
            color: Colors.grey,
            fontSize: 18.0,
          )),
    );
  }
}
