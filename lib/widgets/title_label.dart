import 'package:flutter/material.dart';

class TitleLabel extends StatelessWidget {
  const TitleLabel(this.title, {Key key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'Oswald',
        ));
  }
}
