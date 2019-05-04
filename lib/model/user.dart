import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String token;

  const User({@required this.id, @required this.email, @required this.token});
}
