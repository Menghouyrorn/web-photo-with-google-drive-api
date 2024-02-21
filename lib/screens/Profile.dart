// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:theringphoto/screens/edit_profile.dart';
import 'package:theringphoto/screens/login.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/service/storeTokenUser.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> currentUser = {};

  // ignore: non_constant_identifier_names
  Future<void> GetCurrentUser() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointCurrentUser;
      final res = await http.get(Uri.parse(uri));
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          currentUser = json['Data'];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  void initState() {
    GetCurrentUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SizedBox(
              width: 500,
              child: Card(
                elevation: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ProfileAddmin',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.5,
                        color: Color(0xff1a2d45),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(currentUser['profile']),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      currentUser['fname'] + " " + currentUser['lname'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: Color(0xff1a2d45),
                      ),
                    ),
                    Text(
                      currentUser['email'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: Color(0xff1a2d45),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: const Color.fromARGB(73, 27, 45, 69),
                          fixedSize: const Size(100, 30)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Edit_Profile(),
                            ));
                      },
                      child: const Text(
                        "Edit",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      textColor: const Color(0xff1a2d45),
                      leading: const Icon(
                        Icons.attribution_outlined,
                        color: Color(0xff1a2d45),
                      ),
                      title: const Text('About Photo'),
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                    ),
                    ListTile(
                      textColor: const Color(0xff1a2d45),
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xff1a2d45),
                      ),
                      title: const Text('Logout'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: SizedBox(
                                width: 400,
                                height: 200,
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 50),
                                        child: Text(
                                          'Are you sure you want to logOut?',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 30, left: 80, right: 80),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ButtonStyle(
                                                  padding:
                                                      const MaterialStatePropertyAll(
                                                          EdgeInsets.all(20)),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.grey[400])),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                WebSessionStorageService
                                                    .clearToken();

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginForm(),
                                                  ),
                                                );
                                              },
                                              style: ButtonStyle(
                                                  padding:
                                                      const MaterialStatePropertyAll(
                                                          EdgeInsets.all(20)),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.red[400])),
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return const Scaffold(
      body: Center(child: Text('no data')),
    );
  }
}
