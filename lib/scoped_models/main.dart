import 'package:scoped_model/scoped_model.dart';
import './shared_model.dart';

class MainModel extends Model with SharedModel, ProductModel, UserModel {}
