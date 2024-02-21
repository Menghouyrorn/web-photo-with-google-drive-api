import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theringphoto/admin/screens/home_screen.dart';
import 'package:theringphoto/screens/home_screen.dart';
import 'package:theringphoto/screens/login.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/service/storeTokenUser.dart';
import 'package:http/http.dart' as http;
import 'package:theringphoto/staff/screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> user = {};
  Map<String, dynamic> currentUser = {};
  @override
  void initState() {
    final token = WebSessionStorageService.retrieveToken();
    if (token != null) {
      GetCurrentUser();
    }
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginForm(),
        ),
      );
    });
  }

  Future<void> GetCurrentUser() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointCurrentUser;
      final res = await http.get(Uri.parse(uri));
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          currentUser = json['Data'];
          if (currentUser != {}) {
            if (currentUser['role'] == 'admin') {
              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomeAdmin(),
                  ));
            } else if (currentUser['role'] == 'staff') {
              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreenStaff(),
                  ));
            } else {
              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ));
            }
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  image: DecorationImage(
                      image: AssetImage('lib/assets/images/logo.jpg'))),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'PHOTO',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
