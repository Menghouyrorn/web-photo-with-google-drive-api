import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyTextStyle extends StatelessWidget {
   MyTextStyle({
    super.key,
    required this.name,
    required this.style,
  });

   String name;
   TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Tooltip(message: name, child: Text(name.length >22 ? "${name.substring(1,18)}..." :name, style: style)),
    );
  }
}