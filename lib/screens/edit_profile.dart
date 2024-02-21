// ignore_for_file: unused_field, use_build_context_synchronously

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/service/storeTokenUser.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:theringphoto/widgets/googleDriveApi.dart';
import 'package:theringphoto/widgets/showMessage.dart';

// ignore: camel_case_types
class Edit_Profile extends StatefulWidget {
  const Edit_Profile({super.key});

  @override
  State<Edit_Profile> createState() => _Edit_ProfileState();
}

// ignore: camel_case_types
class _Edit_ProfileState extends State<Edit_Profile> {
  late String accessToken;
  bool isopen = false;
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController cofPassword = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  List<int>? _selectedFile;
  Uint8List? _bytesData;
  String? filename;
  final folderId = "1GAq1AvaFhGBv8-7ERZPKxGwZXOGCqqOR";
  Map<String, dynamic> currentUser = {};

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

  // update customer
  // ignore: non_constant_identifier_names
  Future<void> EditProfile(int idCustomer, String profile) async {
    if (newPassword.text.isEmpty && cofPassword.text.isEmpty) {
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
          MessageDialog.showMessageDialog('Edit profile success');
          setState(() {});
          Navigator.pop(context);
        } else {
          MessageDialog.showMessageDialog('error');
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    } else {
      if (newPassword.text == cofPassword.text) {
        try {
          final uri = ApiConstants.bestUrl + ApiConstants.endpointEditProfile;
          final data = {
            "id": idCustomer,
            "fname": fname.text,
            "lname": lname.text,
            "password": newPassword.text,
            "profile": profile
          };
          final res = await http.put(Uri.parse(uri),
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
              body: jsonEncode(data));
          final json = jsonDecode(res.body);
          if (json['message'] == 'success') {
            MessageDialog.showMessageDialog('Edit profile success');
            setState(() {});
            Navigator.pop(context);
          } else {
            MessageDialog.showMessageDialog('error');
          }
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
      } else {
        MessageDialog.showMessageDialog(
            'Password not equal, please input new password');
      }
    }
  }

  startWebFilePicker() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      final file = files![0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        setState(() {
          _bytesData = const Base64Decoder()
              .convert(reader.result.toString().split(",").last);
          _selectedFile = _bytesData;
        });
      });
      reader.readAsDataUrl(file);
      filename = file.name;
    });
  }

  Future<void> uploadPhotoToDrive(
      drive.DriveApi driveApi, Uint8List fileData, String folderId) async {
    try {
      final file = drive.File();
      file.parents = [folderId];
      file.name = filename;
      final stream = Stream<List<int>>.fromIterable([fileData.toList()]);

      // Upload file to Google Drive
      final test = await driveApi.files
          .create(file, uploadMedia: drive.Media(stream, fileData.length));
      EditProfile(currentUser['id'],
          "https://drive.google.com/uc?export=open&id=${test.id}");
      // ignore: avoid_print
      print('File uploaded successfully!');
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading file: $e');
    }
  }

  void runforRun() async {
    final client = await clientViaServiceAccount(
        GoogleDriveApi.serviceAccountCredentials, GoogleDriveApi.scopes);
    final driveApi = drive.DriveApi(client);
    final fileData = _bytesData;
    const folderid = "1O1YkDZKJygfw2xj-ePF4lcEFhIGFXfiW";
    await uploadPhotoToDrive(driveApi, fileData!, folderid);
    client.close();
  }

  @override
  void initState() {
    getToken();
    GetCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    num? widthcard = 50;
    num? heightcard = 90;
    double? sizeboxheight = 30;
    if (ResponsiveUtils.isMobile(context)) {
      widthcard = 90;
      heightcard = 70;
      sizeboxheight = 20;
    } else if (ResponsiveUtils.isDesktop(context)) {
      widthcard = 50;
      heightcard = 90;
      sizeboxheight = 30;
    } else if (ResponsiveUtils.isTablet(context)) {
      widthcard = 90;
      heightcard = 90;
      sizeboxheight = 20;
    }
    if (currentUser.isNotEmpty) {
      fname.text = currentUser['fname'];
      lname.text = currentUser['lname'];
      email.text = currentUser['email'];
      phone.text = currentUser['phone'];
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Container(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * (widthcard / 100),
            height: MediaQuery.of(context).size.height * (heightcard / 100),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Profile",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                    ),
                    //user profile
                    Material(
                      borderRadius: BorderRadius.circular(50),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          startWebFilePicker();
                        },
                        onHover: (value) {
                          setState(() {
                            isopen = value;
                          });
                        },
                        child: Column(
                          children: [
                            _bytesData != null
                                ? Stack(
                                    children: [
                                      Ink.image(
                                        image: MemoryImage(
                                          _bytesData!,
                                        ),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      isopen
                                          ? Positioned(
                                              top: 70,
                                              child: TextButton(
                                                onPressed: () {
                                                  startWebFilePicker();
                                                },
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    fixedSize:
                                                        const Size(100, 30)),
                                                child: const Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      Ink.image(
                                        image: NetworkImage(
                                          currentUser['profile'],
                                        ),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      isopen
                                          ? Positioned(
                                              top: 70,
                                              child: TextButton(
                                                onPressed: () {
                                                  startWebFilePicker();
                                                },
                                                style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    fixedSize:
                                                        const Size(100, 30)),
                                                child: const Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(
                                              height: 10,
                                            ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: sizeboxheight,
                    ),
                    //first name and last name input
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: fname,
                            decoration: const InputDecoration(
                              hintText: "Input fname",
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: lname,
                            decoration: const InputDecoration(
                              hintText: "Input lname",
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: sizeboxheight,
                    ),
                    //email input
                    TextFormField(
                      enabled: false,
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Input email",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    SizedBox(
                      height: sizeboxheight,
                    ),
                    //phone number input
                    TextFormField(
                      enabled: false,
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: "Input phone",
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    SizedBox(
                      height: sizeboxheight,
                    ),
                    //phone number input
                    TextFormField(
                      controller: newPassword,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: "Input New password",
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    SizedBox(
                      height: sizeboxheight,
                    ),
                    //phone number input
                    TextFormField(
                      controller: cofPassword,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: "Input Confirm Password",
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    SizedBox(
                      height: sizeboxheight,
                    ),
                    //Button submit
                    Container(
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(color: Colors.white),
                          ],
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            fixedSize: const Size(160, 45),
                            shadowColor: Colors.black),
                        onPressed: () {
                          if (_bytesData != null) {
                            runforRun();
                          } else {
                            EditProfile(
                                currentUser['id'], currentUser['profile']);
                          }
                          // runforRun();
                        },
                        child: const Text("Save"),
                      ),
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
      body: Center(
        child: Text(
          'no data',
        ),
      ),
    );
  }
}
