import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './crud.dart';
import '../../scoped_models/main.dart';

class ProductListTab extends StatefulWidget {
  const ProductListTab({Key key, this.fetchProducts}) : super(key: key);

  final Future<bool> Function() fetchProducts;

  @override
  _ProductListTabState createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab> {
  @override
  void initState() {
    super.initState();
    widget.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    //
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        //
        Widget _buildItem(BuildContext context, int index) {
          final product = model.userProducts[index];

          return Dismissible(
            key: Key(product.title),
            background: Container(color: Colors.red),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              model.selectProduct(product.id);
              model.deleteProduct();
            },
            confirmDismiss: (_) =>
                showDialog(context: context, builder: _buildConfirmDialog),
            child: _ProductTile(index: index, model: model),
          );
        }

        return ListView.builder(
          itemBuilder: _buildItem,
          itemCount: model.userProducts.length,
        );
      },
    );
  }

  AlertDialog _buildConfirmDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Are you sure you want to delete this product?'),
      content: const Text('This action cannot be undone'),
      actions: <Widget>[
        FlatButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context, false)),
        FlatButton(
            child: const Text('CONTINUE'),
            onPressed: () => Navigator.pop(context, true))
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    Key key,
    @required this.index,
    @required this.model,
  }) : super(key: key);

  final int index;
  final MainModel model;

  @override
  Widget build(BuildContext context) {
    final product = model.allProducts[index];
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(product.imageUrl),
          ),
          title: Text(product.title),
          subtitle: Text('\$${product.price}'),
          trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                model.selectProduct(product.id);
                await Navigator.push(
                    context, MaterialPageRoute(builder: _buildEditPage));
                model.selectProduct(null);
              }),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildEditPage(_) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: ProductCrudTab(),
    );
  }
}
