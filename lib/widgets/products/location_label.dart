import 'package:flutter/material.dart';

class LocationLabel extends StatelessWidget {
  final String location;

  const LocationLabel(this.location, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(location),
    );
  }
}
