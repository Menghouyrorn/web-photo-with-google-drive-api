import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
AppBar MobileBar() {
  return AppBar(
    iconTheme: const IconThemeData(color: Colors.black),
    automaticallyImplyLeading: false,
    elevation: 0.5,
    backgroundColor: Colors.white,
    //  backgroundColor: Colors.white,
    title: const Row(
      children: [
        //logo
        Padding(
          padding: EdgeInsets.all(0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('lib/assets/images/logo.jpg'),
              ),
              SizedBox(
                width: 30,
              ),
              Text(
                'The Ring Cambodia',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w100,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        // Drawer
      ],
    ),
  );
}
