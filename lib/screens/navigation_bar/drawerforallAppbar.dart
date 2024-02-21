// ignore_for_file: file_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:theringphoto/admin/screens/profileAdmin.dart';
import 'package:theringphoto/screens/Profile.dart';
import 'package:theringphoto/screens/history.dart';
import 'package:theringphoto/staff/screen/profileStaff.dart';

// ignore: non_constant_identifier_names
Drawer DrawerTest(BuildContext context, String test) {
  String byuser = test;
  return Drawer(
    backgroundColor: Colors.grey[100],
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('HOME'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('HISTORY'),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => History()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('PROFILE'),
          onTap: () {
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
        ),
      ],
    ),
  );
}
