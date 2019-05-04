import 'package:flutter/material.dart';
import 'package:product_manager/widgets/products/product_image.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/product.dart';
import '../scoped_models/main.dart';
import '../widgets/products/location_label.dart';
import '../widgets/products/product_label.dart';
import '../widgets/side_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.fetchProducts}) : super(key: key);

  final Future<bool> Function() fetchProducts;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //
  @override
  void initState() {
    super.initState();
    widget.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (_, __, MainModel model) {
        return Scaffold(
          drawer: const SideMenu(),
          appBar: AppBar(
            title: const Text('EasyList'),
            actions: <Widget>[
              IconButton(
                icon: Icon(_toggleFavoritesIcon(model.isShowingFavorites)),
                color: Colors.white,
                onPressed: () => model.toggleShowFavorites(),
              )
            ],
          ),
          body: ProductCards(model: model),
        );
      },
    );
  }

  IconData _toggleFavoritesIcon(bool isShowing) =>
      isShowing ? Icons.favorite : Icons.favorite_border;
}

class ProductCards extends StatelessWidget {
  //
  final MainModel model;
  final List<Product> products;

  ProductCards({this.model}) : products = model.displayedProducts;

  @override
  Widget build(BuildContext context) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return products.isEmpty
          ? const Center(child: Text('No products, please add'))
          : _buildListView();
    }
  }

  Widget _buildListView() {
    //
    Card buildProductItem(BuildContext context, int index) {
      final product = products[index];

      return Card(
        key: Key(product.title),
        child: Column(
          children: <Widget>[
            ProductImage(url: product.imageUrl),
            const SizedBox(height: 10.0),
            ProductTitleLabel(product),
            const SizedBox(height: 5.0),
            const LocationLabel('Union Square, San Francisco'),
            Text(product.userEmail),
            _buildButtonBar(context, product)
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: model.fetchProducts,
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: buildProductItem,
      ),
    );
  }

  ButtonBar _buildButtonBar(BuildContext context, Product product) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          color: Theme.of(context).accentColor,
          onPressed: () =>
              Navigator.pushNamed(context, '/product/${product.id}'),
        ),
        ScopedModelDescendant<MainModel>(
          builder: (_, __, MainModel model) {
            final icon =
                product.isFavorite ? Icons.favorite : Icons.favorite_border;

            return IconButton(
              icon: Icon(icon),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(product.id);
                model.toggleProductFavorite();
              },
            );
          },
        )
      ],
    );
  }
}
