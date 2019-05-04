import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/home.dart';
import './pages/manage_products.dart';
import './pages/product_detail.dart';
import './scoped_models/main.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // // Use to debug tap gesture recognizers
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  //
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //
  final _model = MainModel();
  bool get _isAuthenticated => _model.isAuthenticated.value;

  @override
  void initState() {
    super.initState();
    _model.attemptLocalAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    //
    final themeData = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.deepOrange,
      accentColor: Colors.deepPurple,
      buttonColor: Colors.deepPurpleAccent,
    );

    return ScopedModel<MainModel>(
      model: _model,
      child: StreamBuilder<bool>(
          stream: _model.isAuthenticated,
          initialData: _isAuthenticated,
          builder: (context, snapshot) {
            print('isAuthenticated snapshot: ${snapshot.data}');
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeData,
              routes: {
                '/': (_) =>
                    _buildPage(HomePage(fetchProducts: _model.fetchProducts)),
                '/manage_products': (_) => _buildPage(
                    ManageProductsPage(fetchProducts: _model.fetchProducts)),
              },
              onGenerateRoute: _onGenerateRoute,
              onUnknownRoute: _onUnknownRoute,
            );
          }),
    );
  }

// called when onGenerateRoute returns null
  Route _onUnknownRoute(RouteSettings settings) {
    //
    return MaterialPageRoute(
      builder: (_) => _buildPage(HomePage(fetchProducts: _model.fetchProducts)),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    //
    final pathElements = settings.name.split('/');
    if (pathElements.first != '' || pathElements[1] != 'product') return null;

    final id = pathElements[2];
    final product = _model.allProducts
        .firstWhere((product) => product.id == id, orElse: () => null);
    if (product == null) return null;

    return MaterialPageRoute(
      builder: (_) => _buildPage(ProductDetailPage(product)),
    );
  }

  Widget _buildPage(Widget page) {
    return _isAuthenticated ? page : AuthPage();
  }
}
