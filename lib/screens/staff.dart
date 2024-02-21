// ignore_for_file: avoid_print, duplicate_ignore, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:theringphoto/widgets/showMessage.dart';

import '../service/storeTokenUser.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  List<dynamic> dataAlbum = [];
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confPassword = TextEditingController();
  Map<String, dynamic> currentUser = {};
  List<dynamic> staffUser = [];
  late String accessToken;
  List dataAllUser = [];

  void reset() {
    fname.text = "";
    lname.text = "";
    email.text = "";
    phone.text = "";
    password.text = "";
  }

  @override
  void initState() {
    super.initState();
    getToken();
    getCurrentUser();
    getStaffData();
    GetAllDataUser();
  }

  Future<void> getToken() async {
    try {
      final token = WebSessionStorageService.retrieveToken();
      if (token != null) {
        accessToken = token;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsStaff;
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

  Future<void> getStaffData() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsStaff;
      final res = await http.get(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accessToken'});
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          staffUser = json['Data'];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> GetAllDataUser() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointGetAllUser;
      final res = await http.get(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accessToken'});
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          dataAllUser = json['Data'];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  bool isExistingEmail(String newEmail) {
    return dataAllUser.any((e) => e['email'] == newEmail);
  }

  bool isExistingPhone(String newphone) {
    return dataAllUser.any((e) => e['phone'] == newphone);
  }

  Future<void> createStaff() async {
    if (dataAllUser.isNotEmpty) {
      if (isExistingEmail(email.text) || isExistingPhone(phone.text)) {
        MessageDialog.showMessageDialog(
            'Email or phone is has,Please input new email or phone');
      } else {
        try {
          final uri = ApiConstants.bestUrl + ApiConstants.endpointsStaff;
          final data = {
            'fname': fname.text,
            'lname': lname.text,
            'phone': phone.text,
            'email': email.text,
            'password': password.text
          };
          final res = await http.post(Uri.parse(uri),
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(data));
          final json = jsonDecode(res.body);
          if (json['message'] == 'success') {
            getStaffData();
            Navigator.pop(context);
            MessageDialog.showMessageDialog('Created staff success');
            reset();
          } else {
            MessageDialog.showMessageDialog('Created faild');
          }
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
      }
    }
  }

  Future<void> updateStaff(int idStaff, String profile) async {
    if (newPassword.text.isEmpty && confPassword.text.isEmpty) {
      try {
        final uri = ApiConstants.bestUrl + ApiConstants.endpointEditProfile;
        final data = {
          "id": idStaff,
          'fname': fname.text,
          'lname': lname.text,
          "profile": profile
        };
        final res = await http.put(Uri.parse(uri),
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(data));
        final json = jsonDecode(res.body);
        if (json['message'] == 'success') {
          getStaffData();
          Navigator.pop(context);
          MessageDialog.showMessageDialog('Updated staff success');
          reset();
        } else {
          MessageDialog.showMessageDialog('error');
        }
      } catch (e) {
        print(e);
      }
    } else {
      if (newPassword.text == confPassword.text) {
        try {
          final uri = ApiConstants.bestUrl + ApiConstants.endpointEditProfile;
          final data = {
            "id": idStaff,
            'fname': fname.text,
            'lname': lname.text,
            'password': newPassword.text,
            "profile": profile
          };
          final res = await http.put(Uri.parse(uri),
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(data));
          final json = jsonDecode(res.body);
          if (json['message'] == 'success') {
            getStaffData();
            Navigator.pop(context);
            MessageDialog.showMessageDialog('Updated staff success');
            reset();
          } else {
            MessageDialog.showMessageDialog('error');
          }
        } catch (e) {
          print(e);
        }
      } else {
        MessageDialog.showMessageDialog(
            'Password not equal,Please input new password');
      }
    }
  }

  Future<void> deleteStaff(int idStaff) async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsCustomer;
      final data = {"id": idStaff};
      final res = await http.delete(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accessToken'},
          body: jsonEncode(data));
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        MessageDialog.showMessageDialog('Delete staff success');
        Navigator.pop(context);
        getStaffData();
      }
    } catch (e) {
      print(e);
    }
  }

  showDialogtest(int idStaff, String firstname, String lastname,
      String phonenumber, String emailCusomter, String profile) {
    fname.text = firstname;
    lname.text = lastname;
    phone.text = phonenumber;
    email.text = emailCusomter;
    List<dynamic> finalData = [];

    for (int i = 0; i < dataAlbum.length; i++) {
      if (dataAlbum[i]['userid'] == idStaff) {
        setState(() {
          finalData.add(dataAlbum[i]);
        });
      }
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10.0,
              ),
            ), //this right here
            child: SizedBox(
              height: 700,
              width: 550,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Update staff",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.topRight,
                            margin: const EdgeInsets.only(bottom: 15),
                            child: IconButton(
                              onPressed: () => {
                                reset(),
                                Navigator.of(context, rootNavigator: true)
                                    .pop(),
                              },
                              disabledColor: Colors.black,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              icon: const Icon(Icons.clear),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: fname,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'First Name'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: lname,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'Last Name'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      enabled: false,
                      controller: phone,
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration(hintText: 'Phone Number'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      enabled: false,
                      controller: email,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'Email'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: newPassword,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: 'Input New password',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: confPassword,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: 'Input Confirm Password',
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          // addFoldertoCustomer(currentUser['id']);
                          updateStaff(idStaff, profile);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.blue[300],
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    num? widthrespon = 90;
    // num? heightrespon = 95;
    double? fontsizetitle = 28;
    double? fontsizecolumn = 18;
    double? fontsizerow = 14;
    double? iconsize = 24;
    double? paddingleft = 65;
    double? paddingright = 45;
    if (ResponsiveUtils.isMobile(context)) {
      widthrespon = 100;
      // heightrespon = 90;
      fontsizecolumn = 10;
      fontsizetitle = 12;
      fontsizerow = 9;
      iconsize = 14;
      paddingleft = 25;
      paddingright = 15;
    } else if (ResponsiveUtils.isDesktop(context)) {
      widthrespon = 90;
      // heightrespon = 90;
      fontsizetitle = 28;
      fontsizecolumn = 18;
      fontsizerow = 14;
      iconsize = 24;
      paddingleft = 100;
      paddingright = 65;
    } else if (ResponsiveUtils.isTablet(context)) {
      widthrespon = 90;
      // heightrespon = 95;
      fontsizetitle = 24;
      fontsizecolumn = 18;
      fontsizerow = 14;
      iconsize = 18;
      paddingleft = 60;
      paddingright = 45;
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12, left: 20),
            alignment: Alignment.topLeft,
            child: Text(
              "Staff",
              style: TextStyle(
                  fontSize: fontsizetitle, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding: EdgeInsets.only(
              left: paddingleft,
              right: paddingright,
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (widthrespon / 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Staff",
                    style: TextStyle(
                        fontSize: fontsizecolumn, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      reset();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0)), //this right here
                            child: SizedBox(
                              height: 600,
                              width: 550,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Create Staff",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            alignment: Alignment.topRight,
                                            margin: const EdgeInsets.only(
                                                bottom: 15),
                                            child: IconButton(
                                              onPressed: () => Navigator.of(
                                                      context,
                                                      rootNavigator: true)
                                                  .pop(),
                                              disabledColor: Colors.black,
                                              highlightColor:
                                                  Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              icon: const Icon(Icons.clear),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      controller: fname,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                          hintText: 'First Name'),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      controller: lname,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                          hintText: 'Last Name'),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      controller: phone,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                          hintText: 'phone number'),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      controller: email,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                          hintText: 'Email'),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      controller: password,
                                      obscureText: true,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      decoration: const InputDecoration(
                                          hintText: 'Password'),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      alignment: Alignment.bottomRight,
                                      child: TextButton(
                                        onPressed: () {
                                          createStaff();
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(20),
                                          backgroundColor: Colors.blue[300],
                                        ),
                                        child: const Text(
                                          'Create Staff',
                                          style: TextStyle(color: Colors.black),
                                        ),
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
                    icon: Icon(
                      Icons.person_add_alt_outlined,
                      size: iconsize,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * (widthrespon / 100),
            child: const Divider(),
          ),
          // SizedBox(
          //   height: 5,
          // ),
          Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * (widthrespon / 100),
              // height: MediaQuery.of(context).size.height * (heightrespon / 100),
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      "Username",
                      style: TextStyle(
                          fontSize: fontsizecolumn,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Phone Number",
                      style: TextStyle(
                          fontSize: fontsizecolumn,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Email",
                      style: TextStyle(
                          fontSize: fontsizecolumn,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: staffUser
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              e['fname'] + e['lname'],
                              style: TextStyle(fontSize: fontsizerow),
                            ),
                          ),
                          DataCell(
                            Text(
                              e['phone'],
                              style: TextStyle(fontSize: fontsizerow),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e['email'],
                                  style: TextStyle(fontSize: fontsizerow),
                                ),
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: PopupMenuButton(
                                    padding: const EdgeInsets.all(0),
                                    constraints: const BoxConstraints.tightFor(
                                        height: 110, width: 200),
                                    onSelected: (value) {},
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              showDialogtest(
                                                  e['id'],
                                                  e['fname'],
                                                  e['lname'],
                                                  e['phone'],
                                                  e['email'],
                                                  e['profile']);
                                            },
                                            style: TextButton.styleFrom(
                                                fixedSize: const Size(200, 40),
                                                backgroundColor: Colors.white,
                                                elevation: 0),
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.black,
                                            ),
                                            label: const Text(
                                              "Edit Staff",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              deleteStaff(e['id']);
                                            },
                                            style: TextButton.styleFrom(
                                              fixedSize: const Size(200, 40),
                                              backgroundColor: Colors.white,
                                              elevation: 0,
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline_outlined,
                                              color: Colors.black,
                                            ),
                                            label: const Text(
                                              "Delete Customer",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          // value: 'edit',
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
