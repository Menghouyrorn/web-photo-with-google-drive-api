// ignore_for_file: avoid_print, duplicate_ignore, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/service/storeTokenUser.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:theringphoto/widgets/showMessage.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  List<dynamic> dataAlbum = [];
  List<dynamic> dataAlbumUpdate = [];
  List<dynamic> dataAlbumsLast = [];
  List<dynamic> selectData = [];
  List<dynamic> foundData = [];
  List<dynamic> result = [];
  List<dynamic> resultLast = [];
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confPassword = TextEditingController();
  late String accessToken;
  Map<String, dynamic> currentUser = {};
  List<dynamic> customerUser = [];
  List lastUpdate = [];
  List dataAllUser = [];
  //get token
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

  Future<void> getDataFromApi() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
      final res = await http.get(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accessToken'});
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        for (final data in json['Data']) {
          if (data['userid'] == 0) {
            setState(() {
              dataAlbum.add(data);
            });
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> getDataAlbumsForUpdate() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
      final res = await http.get(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accessToken'});
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          dataAlbumUpdate = json['Data'];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // for get current user
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

  Future<void> GetCustomerData() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsCustomer;
      final res = await http.get(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accessToken'});
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          customerUser = json['Data'];
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

  // delete customer
  Future<void> DeleteCustomer(int idCusomter) async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsCustomer;
      final data = {"id": idCusomter};
      final res = await http.delete(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accessToken'},
          body: jsonEncode(data));
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        // ignore: avoid_print
        MessageDialog.showMessageDialog('Delete customer success');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        GetCustomerData();
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  void reset() {
    fname.text = "";
    lname.text = "";
    email.text = "";
    phone.text = "";
    password.text = "";
  }

  @override
  void initState() {
    getToken();
    super.initState();
    GetCurrentUser();
    getDataFromApi();
    getDataAlbumsForUpdate();
    GetCustomerData();
    GetAllDataUser();
  }

  @override
  Widget build(BuildContext context) {
    // for add folder to customer
    Future<void> addFoldertoCustomer(int userid) async {
      if (selectData.isNotEmpty) {
        for (int i = 0; i < selectData.length; i++) {
          try {
            final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
            int idtitle = selectData[i]['id'];
            final data = {
              "update": "updateUserid",
              "userid": userid,
              "id": idtitle
            };
            final res = await http.put(Uri.parse(uri),
                headers: {
                  'Authorization': 'Bearer $accessToken',
                },
                body: jsonEncode(data));
            final json = jsonDecode(res.body);
            if (json['message'] == 'success') {
              print('Create success');
            } else {
              print('error');
            }
          } catch (e) {
            // ignore: avoid_print
            print(e);
          }
        }
      }
    }

    //update foldet to customer
    Future<void> updateFoldertoCustomer(int userid) async {
      if (lastUpdate.isNotEmpty) {
        for (int i = 0; i < lastUpdate.length; i++) {
          try {
            int userid = 0;
            final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
            int idalbums = lastUpdate[i]['id'];
            final data = {
              "update": "updateUserid",
              "userid": userid,
              "id": idalbums
            };
            final res = await http.put(Uri.parse(uri),
                headers: {
                  'Authorization': 'Bearer $accessToken',
                },
                body: jsonEncode(data));
            final json = jsonDecode(res.body);
            if (json['message'] == 'success') {
              print('Update success');
            } else {
              print('error');
            }
          } catch (e) {
            // ignore: avoid_print
            print(e);
          }
        }
      }
      for (int i = 0; i < selectData.length; i++) {
        try {
          final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
          int idalbums = selectData[i]['id'];
          final data = {
            "update": "updateUserid",
            "userid": userid,
            "id": idalbums
          };
          final res = await http.put(Uri.parse(uri),
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(data));
          final json = jsonDecode(res.body);
          if (json['message'] == 'success') {
            print('Update success');
          } else {
            print('error');
          }
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
      }
    }

    bool isExistingEmail(String newEmail) {
      return dataAllUser.any((e) => e['email'] == newEmail);
    }

    bool isExistingPhone(String newphone) {
      return dataAllUser.any((e) => e['phone'] == newphone);
    }

    // for create customer
    Future<void> CreateCustomer() async {
      if (fname.text.isNotEmpty &&
          lname.text.isNotEmpty &&
          email.text.isNotEmpty &&
          phone.text.isNotEmpty &&
          password.text.isNotEmpty) {
        if (dataAllUser.isNotEmpty) {
          if (isExistingEmail(email.text) || isExistingPhone(phone.text)) {
            MessageDialog.showMessageDialog(
                'Email or phone is has,Please input new email and phone');
          } else {
            try {
              final uri = ApiConstants.bestUrl + ApiConstants.endpointsCustomer;
              final data = {
                "fname": fname.text,
                "lname": lname.text,
                "email": email.text,
                "phone": phone.text,
                "password": password.text
              };
              final res = await http.post(Uri.parse(uri),
                  headers: {
                    'Authorization': 'Bearer $accessToken',
                  },
                  body: jsonEncode(data));
              final json = jsonDecode(res.body);
              if (json['message'] == 'success') {
                GetCustomerData();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                addFoldertoCustomer(json['Data']['id']);
                MessageDialog.showMessageDialog('create customer success');
                reset();
              } else {
                MessageDialog.showMessageDialog('error');
              }
            } catch (e) {
              // ignore: avoid_print
              print(e);
            }
          }
        }
      } else {
        MessageDialog.showMessageDialog('Please Input Data');
      }
    }

    // update customer
    Future<void> UpdateCustomer(int idCustomer, String profile) async {
      if (newPassword.text.isEmpty && confPassword.text.isEmpty) {
        try {
          final uri = ApiConstants.bestUrl + ApiConstants.endpointEditProfile;
          final data = {
            "id": idCustomer,
            "fname": fname.text,
            "lname": lname.text,
            "profile": profile
          };
          final res = await http.put(Uri.parse(uri),
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(data));
          final json = jsonDecode(res.body);
          if (json['message'] == 'success') {
            GetCustomerData();
            getDataAlbumsForUpdate();
            updateFoldertoCustomer(json['Data']['id']);
            MessageDialog.showMessageDialog('update customer success');
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
            reset();
          } else {
            MessageDialog.showMessageDialog('error');
          }
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
      } else {
        if (newPassword.text == confPassword.text) {
          try {
            final uri = ApiConstants.bestUrl + ApiConstants.endpointEditProfile;
            final data = {
              "id": idCustomer,
              "fname": fname.text,
              "lname": lname.text,
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
              GetCustomerData();
              getDataAlbumsForUpdate();
              updateFoldertoCustomer(json['Data']['id']);
              MessageDialog.showMessageDialog('update customer success');
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              reset();
            } else {
              MessageDialog.showMessageDialog('error');
            }
          } catch (e) {
            // ignore: avoid_print
            print(e);
          }
        } else {
          MessageDialog.showMessageDialog(
              'Password not equal,Please input new password');
        }
      }
    }

    showDialogtest(int idCusomter, String firstname, String lastname,
        String emailCusomter, String phonenumber, String profile) {
      dataAlbumsLast = [];
      fname.text = firstname;
      lname.text = lastname;
      email.text = emailCusomter;
      phone.text = phonenumber;
      List<dynamic> finalData = [];

      for (int i = 0; i < dataAlbumUpdate.length; i++) {
        if (dataAlbumUpdate[i]['userid'] == idCusomter) {
          finalData.add(dataAlbumUpdate[i]);
        }
      }

      if (dataAlbumUpdate.isNotEmpty) {
        for (final data in dataAlbumUpdate) {
          if (data['userid'] == 0 || data['userid'] == idCusomter) {
            dataAlbumsLast.add(data);
          }
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
                              "Update Customer",
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
                                  dataAlbumsLast = [],
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
                        decoration:
                            const InputDecoration(hintText: 'First Name'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: lname,
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(hintText: 'Last Name'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(hintText: 'Email'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: phone,
                        keyboardType: TextInputType.text,
                        decoration:
                            const InputDecoration(hintText: 'phone number'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: newPassword,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            hintText: 'Input New password'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: confPassword,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                            hintText: 'Input confirm Password'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: MultiSelectDialogField(
                          searchable: true,
                          searchIcon: const Icon(Icons.search),
                          searchHint: 'Search albums',
                          initialValue: finalData,
                          items: dataAlbumsLast
                              .map((e) => MultiSelectItem(e, e['title']))
                              .toList(),
                          listType: MultiSelectListType.CHIP,
                          onConfirm: (values) {
                            selectData = values;
                            for (final data in selectData) {
                              finalData
                                  .removeWhere((e) => e['id'] == data['id']);
                            }
                            lastUpdate = finalData;
                          },
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
                            UpdateCustomer(idCusomter, profile);
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
              "Customer",
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
                    "Customer",
                    style: TextStyle(
                      fontSize: fontsizecolumn,
                      fontWeight: FontWeight.bold,
                    ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Create Customer",
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
                                              onPressed: () => {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop(),
                                              },
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
                                      controller: email,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                          hintText: 'Email'),
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
                                    Center(
                                      child: MultiSelectDialogField(
                                        searchable: true,
                                        searchIcon: const Icon(Icons.search),
                                        searchHint: 'Search albums',
                                        items: dataAlbum
                                            .map((e) =>
                                                MultiSelectItem(e, e['title']))
                                            .toList(),
                                        listType: MultiSelectListType
                                            .CHIP, // Display selected items as chips
                                        onConfirm: (values) {
                                          selectData = values;
                                          setState(() {});
                                        },
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
                                          CreateCustomer();
                                          // addFoldertoCustomer(currentUser['id']);
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(20),
                                          backgroundColor: Colors.blue[300],
                                        ),
                                        child: const Text(
                                          'Create',
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
                rows: customerUser
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              e['fname'] + " " + e['lname'],
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
                                                  e['email'],
                                                  e['phone'],
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
                                              "Edit Customer",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              DeleteCustomer(e['id']);
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
