import 'package:flutter/material.dart';
import 'package:product_manager/widgets/side_menu.dart';

import './tabs/crud.dart';
import './tabs/product_list.dart';
import '../widgets/side_menu.dart';

class ManageProductsPage extends StatelessWidget {
  //
  final Future<bool> Function() fetchProducts;

  const ManageProductsPage({Key key, this.fetchProducts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIconShown =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const SideMenu(),
        appBar: AppBar(
          title: const Text('Manage Products'),
          bottom: TabBar(tabs: <Widget>[
            Tab(
              text: 'Create',
              icon: isIconShown ? const Icon(Icons.create) : null,
            ),
            Tab(
              text: 'My Products',
              icon: isIconShown ? const Icon(Icons.list) : null,
            ),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            ProductCrudTab(),
            ProductListTab(fetchProducts: fetchProducts),
          ],
        ),
      ),
    );
  }
}
