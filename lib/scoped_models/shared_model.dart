import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:product_manager/model/auth.dart';
import 'package:product_manager/scoped_models/url_builder.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/product.dart';
import '../model/user.dart';

const _headers = {'Content-Type': 'application/json'};

mixin SharedModel on Model {
  //
  List<Product> _products = [];
  String _selectedProductId;
  User _authenticatedUser;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _stopLoading() {
    _selectedProductId = null;
    _isLoading = false;
    notifyListeners();
  }
}

mixin ProductModel on SharedModel {
  //
  bool _isShowingFavorites = false;

  List<Product> get allProducts => List.from(_products);

  List<Product> get displayedProducts => _isShowingFavorites
      ? _products.where((product) => product.isFavorite).toList()
      : List.from(_products);

  List<Product> get userProducts => _products
      .where((product) => product.userId == _authenticatedUser.id)
      .toList();

  Product get selectedProduct {
    if (_selectedProductId == null) return null;
    return _products.firstWhere(
      (product) => product.id == _selectedProductId,
      orElse: () => null,
    );
  }

  bool get isShowingFavorites => _isShowingFavorites;

  ProductUrlBuilder get _urlBuilder =>
      ProductUrlBuilder(token: _authenticatedUser.token);

  Future<bool> fetchProducts() async {
    //
    _isLoading = true;
    try {
      final response = await http.get(_urlBuilder.productsUrl);

      final Map<String, dynamic> data = json.decode(response.body);
      if (data != null) {
        _products = data.entries.map((entry) {
          final favoritedBy = entry.value['favoritedBy'];
          final isFavorite = favoritedBy != null
              ? (favoritedBy as Map<String, dynamic>)
                  .containsKey(_authenticatedUser.id)
              : false;

          final productData = <String, dynamic>{
            'id': entry.key,
            'isFavorite': isFavorite,
            ...entry.value
          };
          return Product.fromMap(productData);
        }).toList();
      }
      _stopLoading();

      return true;
    } catch (error) {
      print(error.toString());
      _stopLoading();
      return false;
    }
  }

  Future<bool> addProduct({
    String title,
    String description,
    double price,
    String imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    final product = Product(
      title: title,
      description: description,
      price: price,
      imageUrl:
          'https://www.capetownetc.com/wp-content/uploads/2018/06/Choc_1.jpeg',
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
    );
    try {
      final response = await http.post(
        _urlBuilder.productsUrl,
        body: json.encode(product.toMap()),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      product.id = data['name'];
      _products.add(product);
      _stopLoading();

      return true;
    } catch (error) {
      print(error.toString());
      _stopLoading();
      return false;
    }
  }

  Future<bool> deleteProduct() async {
    //
    _products.remove(selectedProduct);
    try {
      await http.delete(_urlBuilder.productUrl(productId: _selectedProductId));
      _stopLoading();

      return true;
    } catch (error) {
      print(error.toString());
      _stopLoading();
      return false;
    }
  }

  Future<bool> updateProduct({
    String title,
    String description,
    double price,
    String imageUrl,
  }) async {
    //
    _isLoading = true;
    notifyListeners();

    final product = Product(
      id: selectedProduct.id,
      title: title,
      description: description,
      price: price,
      imageUrl:
          'https://www.capetownetc.com/wp-content/uploads/2018/06/Choc_1.jpeg',
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.userId,
      isFavorite: selectedProduct.isFavorite,
    );
    try {
      await http.put(
        _urlBuilder.productUrl(productId: _selectedProductId),
        body: json.encode(product.toMap()),
      );

      _products[_products.indexOf(selectedProduct)] = product;
      _stopLoading();

      return true;
    } catch (e) {
      print(e.toString());
      _stopLoading();
      return false;
    }
  }

  void selectProduct(String id) {
    _selectedProductId = id;
  }

  Future<bool> toggleProductFavorite() async {
    final isFavorite = !selectedProduct.isFavorite;

    final product = Product.from(selectedProduct, isFavorite: isFavorite);
    _products[_products.indexOf(selectedProduct)] = product;
    notifyListeners();

    http.Response response;
    if (isFavorite) {
      response = await http.put(
        _urlBuilder.favoriteProductUrl(
          productId: _selectedProductId,
          userId: _authenticatedUser.id,
        ),
        body: json.encode(true),
      );
    } else {
      response = await http.delete(
        _urlBuilder.favoriteProductUrl(
          productId: _selectedProductId,
          userId: _authenticatedUser.id,
        ),
      );
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final product = Product.from(selectedProduct, isFavorite: !isFavorite);
      _products[_products.indexOf(selectedProduct)] = product;
      notifyListeners();
      return false;
    }
    _selectedProductId = null;
    return true;
  }

  void toggleShowFavorites() {
    _isShowingFavorites = !_isShowingFavorites;
    notifyListeners();
    _selectedProductId = null;
  }
}

mixin UserModel on SharedModel {
  //
  Timer _authTimer;
  final BehaviorSubject<bool> _isAuthenticatedPublisher =
      BehaviorSubject<bool>.seeded(false);

  ValueObservable<bool> get isAuthenticated => _isAuthenticatedPublisher;

  Future<Map<String, dynamic>> authenticate(
      {String email, String password, AuthMode authMode}) async {
    //
    _isLoading = true;
    notifyListeners();

    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    final url = _urlFor(authMode);
    final response =
        await http.post(url, body: json.encode(authData), headers: _headers);

    _stopLoading();
    final body = json.decode(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      return {'success': false, 'message': body['error']['message']};
    } else {
      _authenticatedUser = User(
        id: body['localId'],
        email: email,
        token: body['idToken'],
      );
      print('Logged in user: $_authenticatedUser');

      final tokenExpireSeconds = int.parse(body['expiresIn']);
      _setAuthTimeout(tokenExpireSeconds);
      final tokenExpireDate =
          DateTime.now().add(Duration(seconds: tokenExpireSeconds));

      final storage = FlutterSecureStorage();
      storage.write(key: _StorageKeys.token, value: _authenticatedUser.token);
      storage.write(key: _StorageKeys.userId, value: _authenticatedUser.id);
      storage.write(key: _StorageKeys.email, value: _authenticatedUser.email);
      storage.write(
          key: _StorageKeys.tokenExpireDate,
          value: tokenExpireDate.toIso8601String());

      _isAuthenticatedPublisher.add(true);

      return {'success': true};
    }
  }

  Future<bool> attemptLocalAuthentication() async {
    //
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: _StorageKeys.token);
    if (token != null) {
      final now = DateTime.now();
      final tokenExpireDateString =
          await storage.read(key: _StorageKeys.tokenExpireDate);
      final tokenExpireDate = DateTime.parse(tokenExpireDateString);
      if (tokenExpireDate.isAfter(now)) {
        final tokenTimeout = tokenExpireDate.difference(now).inSeconds;
        _setAuthTimeout(tokenTimeout);

        final userId = await storage.read(key: _StorageKeys.userId);
        final email = await storage.read(key: _StorageKeys.email);
        _authenticatedUser = User(id: userId, email: email, token: token);

        _isAuthenticatedPublisher.add(true);

        return true;
      }
    }
    return false;
  }

  void logout() async {
    _authenticatedUser = null;
    if (_authTimer != null) _authTimer.cancel();
    _isAuthenticatedPublisher.add(false);

    final storage = FlutterSecureStorage();
    await storage.delete(key: _StorageKeys.token);
    await storage.delete(key: _StorageKeys.userId);
    await storage.delete(key: _StorageKeys.email);
    await storage.delete(key: _StorageKeys.tokenExpireDate);

    print('Logged out user.');
  }

  void _setAuthTimeout(int timeout) {
    print('setAuthTimeout with $timeout');
    // _authTimer = Timer(Duration(milliseconds: timeout * 2), logout);
    _authTimer = Timer(Duration(seconds: timeout), logout);
  }

  String _urlFor(AuthMode mode) {
    return mode == AuthMode.Login
        ? AuthUrlBuilder().loginUrl
        : AuthUrlBuilder().signupUrl;
  }
}

class _StorageKeys {
  static const token = 'token';
  static const userId = 'userId';
  static const email = 'email';
  static const tokenExpireDate = 'tokenExpireDate';
}
