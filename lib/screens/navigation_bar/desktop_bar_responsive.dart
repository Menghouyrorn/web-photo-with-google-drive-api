// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:theringphoto/admin/screens/profileAdmin.dart';
import 'package:theringphoto/screens/Profile.dart';
import 'package:theringphoto/screens/history.dart';
import 'package:theringphoto/staff/screen/profileStaff.dart';

// ignore: non_constant_identifier_names
AppBar DeskTopBar(BuildContext context, String test) {
  String byuser = test;
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0.5,
    backgroundColor: Colors.white,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                "HOME",
                style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Colors.blueGrey,
                    fontSize: 14),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => History(),
                    ));
              },
              child: const Text(
                "HISTORY",
                style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Colors.blueGrey,
                    fontSize: 14),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              onPressed: () {
                if (test == 'admin') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileAddmin(),
                      ));
                } else if (test == 'staff') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileStaff(),
                      ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Profile(),
                      ));
                }
              },
              child: const Text(
                "PROFILE",
                style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Colors.blueGrey,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
