import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:theringphoto/admin/screens/home_screen.dart';
import 'package:theringphoto/screens/home_screen.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/service/storeTokenUser.dart';
import 'package:theringphoto/staff/screen/home_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:theringphoto/widgets/showMessage.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  Map<String, dynamic> user = {};
  Map<String, dynamic> currentUser = {};

  @override
  void initState() {
    final token = WebSessionStorageService.retrieveToken();
    if (token != null) {
      GetCurrentUser();
    }
    super.initState();
  }

  // ignore: non_constant_identifier_names
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

  // ignore: non_constant_identifier_names
  Future<void> UserSignIn() async {
    try {
      final data = {"phone": phone.text, 'password': password.text};
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsLogin;
      final res = await http.post(Uri.parse(uri), body: jsonEncode(data));
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        phone.text = "";
        password.text = "";
        WebSessionStorageService.storeToken(json['Data']['token']);
        final storedToken = WebSessionStorageService.retrieveToken();
        // ignore: avoid_print
        print('Login Success');
        if (storedToken != null) {
          user = json['Data']['user'];
          if (user['role'] == 'admin') {
            // ignore: use_build_context_synchronously
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomeAdmin(),
                ));
          } else if (user['role'] == 'staff') {
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
      }else{
        MessageDialog.showMessageDialog('Error, Please check your phone number or password');
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // padding: const EdgeInsets.only(top: 100),
              height: 350,
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('lib/assets/images/logo.jpg'),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: const Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Login",
                        style:
                            TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Enter your phone number associated with account below and well send your passcode",
                        // ignore: use_full_hex_values_for_flutter_colors
                        style: TextStyle(color: Color(0xFFf1B2D45)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ('Please fill the text');
                          } else {
                            return null;
                          }
                        },
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            hintText: 'Enter your phone number'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ('Please fill the text');
                          } else {
                            return null;
                          }
                        },
                        controller: password,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'Enter password'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          UserSignIn();
                        },
                        child: const SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                "Confirm",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
