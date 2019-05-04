import 'package:meta/meta.dart';
import './api_key.dart';

// Update the variables below with your Firebase project details

// Firebase API key assigned to your project
const _apiKey = firebaseApiKey;
// URL of the Real-Time database (NOT Firestore)
// Example: https://<your-project-name>.firebaseio.com
const _databaseUrl = firebaseDBUrl;

class AuthUrlBuilder {
  static const _baseUrl =
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty';

  String get signupUrl => '$_baseUrl/signupNewUser?key=$_apiKey';
  String get loginUrl => '$_baseUrl/verifyPassword?key=$_apiKey';
}

class ProductUrlBuilder {
  final String _token;

  const ProductUrlBuilder({@required String token}) : _token = token;

  static const _productsUrl = '$_databaseUrl/products';

  String get productsUrl => '$_productsUrl.json?auth=$_token';

  String productUrl({@required String productId}) =>
      '$_productsUrl/$productId.json?auth=${_token}';

  String favoriteProductUrl({
    @required String productId,
    @required String userId,
  }) {
    return '$_productsUrl/$productId/favoritedBy/$userId.json?auth=$_token';
  }
}
