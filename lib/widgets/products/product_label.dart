import 'package:flutter/material.dart';
import '../title_label.dart';
import '../../model/product.dart';

class ProductTitleLabel extends StatelessWidget {
  final Product product;

  const ProductTitleLabel(this.product, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TitleLabel(product.title),
        SizedBox(width: 8.0),
        ProductPriceLabel(product.price),
      ],
    );
  }
}

class ProductPriceLabel extends StatelessWidget {
  const ProductPriceLabel(this.price, {Key key}) : super(key: key);

  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text('\$$price',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          )),
    );
  }
}
