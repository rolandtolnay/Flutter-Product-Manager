import 'package:flutter/material.dart';
import 'package:product_manager/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Chose'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage products'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/manage_products'),
          ),
          const SizedBox(height: 40.0),
          ScopedModelDescendant<MainModel>(builder: (_, __, model) {
            return ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.exit_to_app),
              onTap: () {
                model.logout();
                Navigator.of(context).pushReplacementNamed('/');
              },
            );
          })
        ],
      ),
    );
  }
}
