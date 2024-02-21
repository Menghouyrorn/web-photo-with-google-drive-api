// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
import 'package:theringphoto/widgets/typography.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:theringphoto/widgets/showMessage.dart';
import 'package:theringphoto/widgets/sendGrid.dart';
import 'package:theringphoto/widgets/googleDriveApi.dart';
import 'package:theringphoto/widgets/getTokenFromGoogleDrive.dart';

// ignore: must_be_immutable
class ListPhotoAdmin extends StatefulWidget {
  ListPhotoAdmin({super.key, required this.idalbum, required this.titlealbum});
  String idalbum;
  String? titlealbum;
  @override
  // ignore: library_private_types_in_public_api
  _ListPhotoAdminState createState() => _ListPhotoAdminState();
}

class _ListPhotoAdminState extends State<ListPhotoAdmin> {
  TextEditingController filename = TextEditingController();
  TextEditingController subject = TextEditingController();
  TextEditingController toemail = TextEditingController();
  bool isSelectionMode = true;
  bool isSelect = false;
  List staticData = [];
  Map<int, bool> selectedFlag = {};
  List selectList = [];
  final LocalStorage store = LocalStorage("app_test");
  final LocalStorage storeCurrentData = LocalStorage('Store_CurrentData');
  bool isHasData = false; // for loading
  List testforrun = [];
  List last = [];
  bool? isTest;
  String? datasent;
  List dataSendgrid = [];
  // ignore: unused_field
  List<int>? _selectedFile;
  List dataSearch = [];
  Uint8List? _bytesData;
  Map<String, dynamic> currentUser = {};
  Map datacurrentUserselect = {};
  String fileExtension = "";

  void reset() {
    subject.text = "";
    toemail.text = "";
  }

  String url = 'https://mail.google.com/mail';

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
      // filename = file.name;

      fileExtension = file.type.substring(6);
    });
  }

  Future<void> uploadPhotoToDrive(drive.DriveApi driveApi, Uint8List fileData,
      String folderId, String filename) async {
    try {
      final file = drive.File();
      file.parents = [folderId];
      file.name = "$filename.$fileExtension";
      final stream = Stream<List<int>>.fromIterable([fileData.toList()]);

      // Upload file to Google Drive
      await driveApi.files
          .create(file, uploadMedia: drive.Media(stream, fileData.length));
      fetchData();
      MessageDialog.showMessageDialog('File uploaded successfully!');
    } catch (e) {
      MessageDialog.showMessageDialog('Error uploading file: $e');
    }
  }

  // ignore: non_constant_identifier_names
  void UploadPhotoToGoogleDrive(String folderid) async {
    final client = await clientViaServiceAccount(
        GoogleDriveApi.serviceAccountCredentials, GoogleDriveApi.scopes);
    final driveApi = drive.DriveApi(client);
    final fileData = _bytesData;
    await uploadPhotoToDrive(driveApi, fileData!, folderid, filename.text);
    client.close();
  }

  // send to user email
  Future<void> sendEmail(String apiKey, String toEmail, String fromemail,
      String message, Map datacurrent) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'personalizations': [
        {
          'to': [
            {'email': toEmail}
          ]
        }
      ],
      'from': {'email': fromemail},
      'subject': 'Hello guy, This photo name that i send to you',
      'content': [
        {'type': 'text/plain', 'value': "Name : $message"}
      ],
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 202) {
      if (storeCurrentData.getItem(datacurrent['id'].toString()) != null) {
        Map datatest = storeCurrentData.getItem(datacurrent['id'].toString());
        datatest['DataUser'].addAll(datacurrent['DataUser']);

        storeCurrentData.setItem(datacurrent['id'].toString(), datatest);
      }
      MessageDialog.showMessageDialog('Email Send success');
      ClearAll();
      reset();
      Navigator.pop(context);
    } else {
      MessageDialog.showMessageDialog(
          'Failed to send email. Status code: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');
    }
  }

  //link to page email
  // ignore: no_leading_underscores_for_local_identifiers
  Future<void> launchLink(_url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(_url)) {
      // ignore: deprecated_member_use
      await launch(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }

  // send to admin email
  Future<void> sendToAdmin(
      String apiKey, String fromemail, String message, Map datacurrent) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'personalizations': [
        {
          'to': [
            {'email': 'menghouyrorn.it@gmail.com'}
          ]
        }
      ],
      'from': {'email': fromemail},
      'subject': "Hello admin, This photo name that i send to you",
      'content': [
        {'type': 'text/plain', 'value': "Name : $message"}
      ],
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 202) {
      // if (storeCurrentData.getItem(datacurrent['id'].toString()) != null) {
        Map datatest = storeCurrentData.getItem(datacurrent['id'].toString());
        print(datatest);
        datatest['DataUser'].addAll(datacurrent['DataUser']);
        storeCurrentData.setItem(datacurrent['id'].toString(), datatest);
        // storeCurrentData.setItem(datacurrent['id'].toString(), datatest);
        // print(storeCurrentData.getItem(datacurrent['id'].toString()));
      // }
      MessageDialog.showMessageDialog('Email Send To Admin success');
      ClearAll();
      reset();
      // Navigator.pop(context);
    } else {
      MessageDialog.showMessageDialog(
          'Failed to send email. Status code: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');
    }
  }

  Future<void> fetchData() async {
    // ignore: unnecessary_null_comparison
    if (widget.idalbum != null) {
      String? idAlbums = widget.idalbum;
      try {
        final accessToken = await TokenFromGoogleDrive.getAccessToken();
        final response = await http.get(
          Uri.parse(
              'https://www.googleapis.com/drive/v3/files?q=\'$idAlbums\' in parents'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        final body = response.body;
        setState(() {
          staticData = json.decode(body)['files'];
        });
      } catch (e) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> sendVerificationRequest(
      String apiKey, String email, String nickname, String fromName) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/verified_senders');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = {
      "nickname": nickname,
      "from_email": email,
      "from_name": fromName,
      "reply_to": "menghouyrorn.it@gmail.com",
      "reply_to_name": 'Menghouy Admin',
      "address": "kandal",
      "address2": "phnom penh",
      "city": "phnom penh",
      "country": "Cambodia",
      "zip": "203940",
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 405) {
      print('405 Method Not Allowed - Verify HTTP method and endpoint');
    } else if (response.statusCode == 201) {
      MessageDialog.showMessageDialog('Verification request sent successfully');
    } else {
      // ignore: avoid_print
      print(
          'Failed to send verification request. Status code: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');
    }
  }

  Future<void> fetdatafromSenderGrid() async {
    try {
      final url = Uri.parse('https://api.sendgrid.com/v3/verified_senders');
      final headers = {
        'Authorization': 'Bearer ${SendGridApi.apiKey}',
      };
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        dataSendgrid = jsonDecode(response.body)['results'];
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

  @override
  void initState() {
    GetCurrentUser();
    fetdatafromSenderGrid();
    fetchData();
    if (store.getItem('Data') == null) {
      store.setItem('Data', selectList);
      store.setItem('isSelect', true);
      store.setItem('isSelectTest', false);
    }
    if (staticData.isNotEmpty) {
      isSelect = store.getItem('isSelectTest');
      isSelectionMode = store.getItem('isSelect');
      testforrun = store.getItem('Data');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (storeCurrentData.getItem(currentUser['id'].toString()) != null) {
      datacurrentUserselect =
          storeCurrentData.getItem(currentUser['id'].toString());
      storeCurrentData.setItem(
          currentUser['id'].toString(), datacurrentUserselect);
    }
    // for responsive
    void check() {
      try {
        testforrun = store.getItem('Data');
        if (store.getItem('Data') == null) {
          store.setItem('Data', selectList);
          store.setItem('isSelect', true);
          store.setItem('isSelectTest', false);
        } else {
          selectList = testforrun;
          store.setItem('Data', testforrun);
          last = store.getItem('Data');
          if (last.isNotEmpty) {
            setState(() {
              store.setItem('isSelect', true);
              store.setItem('isSelectTest', true);
            });
          } else {
            setState(() {
              store.setItem('isSelectTest', false);
              store.setItem('isSelect', true);
            });
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }

    check();

    int columnsCount = 4;
    // ignore: unused_local_variable
    double iconSize = 45;
    double num = 3 / 3.4;
    double sizewidthbtn = 200;
    double sizeheightbtn = 50;
    double fontSize = 18;
    if (ResponsiveUtils.isMobile(context)) {
      columnsCount = 2;
      iconSize = 30;
      num = 3 / 3.8;
      sizewidthbtn = 150;
      sizeheightbtn = 40;
    } else if (ResponsiveUtils.isDesktop(context)) {
      columnsCount = 6;
      iconSize = 50;
      num = 3 / 2.8;
      fontSize = 12;
      // ignore: unused_local_variable
      sizewidthbtn = 200;
      // ignore: unused_local_variable
      sizeheightbtn = 50;
    }
    Widget? _buttonSend() {
      if (currentUser.isNotEmpty) {
        if (isSelectionMode) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(sizewidthbtn, sizeheightbtn),
                    backgroundColor: Colors.grey.withOpacity(0.7),
                  ),
                  onPressed: () {
                    datasent = selectList.map((e) => e['name']).toString();
                    print(datasent);
                    if (dataSendgrid.isNotEmpty && currentUser.isNotEmpty) {
                      dataSearch = dataSendgrid
                          .where((e) => e['from_email']!
                              .toLowerCase()
                              .contains(currentUser['email']))
                          .toList();
                      if (dataSearch.isNotEmpty) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Send To Email",
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
                                                  reset(),
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
                                        controller: toemail,
                                        keyboardType: TextInputType.text,
                                        decoration: const InputDecoration(
                                            hintText: 'to Email'),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        alignment: Alignment.bottomRight,
                                        child: TextButton(
                                          onPressed: () {
                                            currentUser['DataUser'] =
                                                selectList;
                                            sendEmail(
                                                SendGridApi.apiKey,
                                                toemail.text,
                                                currentUser['email'],
                                                datasent!,
                                                currentUser);
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(20),
                                            backgroundColor: Colors.blue[300],
                                          ),
                                          child: const Text(
                                            'Send To Email',
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
                      } else {
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
                                height: 200,
                                width: 500,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Please check your email to verify accout",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: fontSize),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                backgroundColor:
                                                    Colors.blue[300],
                                              ),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 100,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            alignment: Alignment.bottomRight,
                                            child: TextButton(
                                              onPressed: () {
                                                sendVerificationRequest(
                                                    SendGridApi.apiKey,
                                                    currentUser['email'],
                                                    currentUser['phone'],
                                                    currentUser['fname'] +
                                                        currentUser['lname']);
                                                launchLink(url);
                                                fetdatafromSenderGrid();
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                backgroundColor:
                                                    Colors.blue[300],
                                              ),
                                              child: const Text(
                                                'ok',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      // ignore: avoid_print
                      print('nodata');
                    }
                  },
                  child: const Text("SEND TO EMAIL"),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(sizewidthbtn, sizeheightbtn),
                  ),
                  onPressed: () {
                    datasent = selectList.map((e) => e['name']).toString();
                    if (dataSendgrid.isNotEmpty && currentUser.isNotEmpty) {
                      dataSearch = dataSendgrid
                          .where((e) => e['from_email']!
                              .toLowerCase()
                              .contains(currentUser['email']))
                          .toList();
                      if (dataSearch.isNotEmpty) {
                        currentUser['DataUser'] = selectList;
                        for (final test in selectList) {
                          test['date'] = DateTime.now();
                        }
                        sendToAdmin(SendGridApi.apiKey, currentUser['email'],
                            datasent!, currentUser);
                      } else {
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
                                height: 200,
                                width: 500,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Please check your email to verify accout",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: fontSize),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                backgroundColor:
                                                    Colors.blue[300],
                                              ),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 100,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            alignment: Alignment.bottomRight,
                                            child: TextButton(
                                              onPressed: () {
                                                sendVerificationRequest(
                                                    SendGridApi.apiKey,
                                                    currentUser['email'],
                                                    currentUser['phone'],
                                                    currentUser['fname'] +
                                                        currentUser['lname']);
                                                launchLink(url);
                                                fetdatafromSenderGrid();
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                backgroundColor:
                                                    Colors.blue[300],
                                              ),
                                              child: const Text(
                                                'ok',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      // ignore: avoid_print
                      print('no data');
                    }
                  },
                  child: const Text("SEND TO ADMIN"),
                ),
              ],
            ),
          );
        } else {
          return null;
        }
      }
    }

    //set loading
    // ignore: prefer_is_empty
    if (staticData.length < 0) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          title: Text(
            widget.titlealbum!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            last.isEmpty
                ? Container()
                : Row(
                    children: [
                      Text(
                        "${last.length} item select",
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        child: _buildSelectAllButton(),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        onPressed: () {
                          ClearAll();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => super.widget,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                    ],
                  ),
          ],
        ),
        body: const Center(
          child: Text("loading..."),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0)), //this right here
                    child: SizedBox(
                      height: 400,
                      width: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Upload Photo",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.topRight,
                                    margin: const EdgeInsets.only(bottom: 15),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
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
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () {
                                startWebFilePicker();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 164, 217, 255),
                                ),
                                child:
                                    Image.asset("lib/assets/images/upload.png"),
                                // child: Image.network("https://cdn.pixabay.com/photo/2016/01/03/00/43/upload-1118929_1280.png"),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  hintText: 'Title Photo'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.datetime,
                              decoration: const InputDecoration(
                                  hintText: 'Date',
                                  suffixIcon: Icon(Icons.calendar_today)),
                              onTap: () async {
                                // ignore: unused_local_variable
                                DateTime? picktimDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              alignment: Alignment.bottomRight,
                              child: TextButton(
                                onPressed: () {
                                  // print(widget.idalbum);
                                  UploadPhotoToGoogleDrive(widget.idalbum);
                                },
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(20)),
                                child: const Text(
                                  'Upload',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
          label: const Icon(Icons.add),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            child: isSelect
                ? IconButton(
                    onPressed: () {
                      ClearAll();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => super.widget,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.black,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  ),
          ),
          title: Text(
            widget.titlealbum!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            last.isEmpty
                ? Container()
                : Row(
                    children: [
                      Text(
                        "${last.length} item select",
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        child: _buildSelectAllButton(),
                      ),
                      const SizedBox(
                        width: 20,
                      )
                    ],
                  ),
          ],
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnsCount,
                childAspectRatio: num,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: staticData.length,
              itemBuilder: (item, index) {
                selectedFlag[index] = selectedFlag[index] ?? false;
                bool? isSelected = selectedFlag[index];
                final title = staticData[index]["name"];
                final url =
                    "https://drive.google.com/uc?export=open&id=${staticData[index]['id']}";
                // final date = staticData[index]['date'];
                return InkWell(
                  onTap: () {
                    // print('je;;');
                  },
                  child: Card(
                    elevation: 0,
                    // shape: ,
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: isSelectionMode
                              ? IconButton(
                                  onPressed: () {
                                    onTap(isSelected, index);
                                  },
                                  icon: Icon(isSelected!
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank),
                                )
                              : Container(),
                        ),
                        Align(
                          child: SizedBox(
                            width: 180,
                            height: 110,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(url),
                                  colorFilter: isSelected!
                                      ? ColorFilter.mode(
                                          Colors.blue.withOpacity(0.6),
                                          BlendMode.color)
                                      : const ColorFilter.mode(
                                          Colors.transparent, BlendMode.color),
                                ),
                                // color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          child: SizedBox(
                            width: 180,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyTextStyle(
                                      name: title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 14)),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyTextStyle(
                                        name: 'Date : 2023',
                                        style: const TextStyle(
                                          color: Color(0xff7D7878),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.download,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
              shrinkWrap: true,
            )
          ],
        ),
        bottomNavigationBar: _buttonSend(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0)), //this right here
                    child: SizedBox(
                      height: 400,
                      width: 350,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Upload Photo",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.topRight,
                                    margin: const EdgeInsets.only(bottom: 15),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
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
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () {
                                startWebFilePicker();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 164, 217, 255),
                                ),
                                child:
                                    Image.asset("lib/assets/images/upload.png"),
                                // child: Image.network("https://cdn.pixabay.com/photo/2016/01/03/00/43/upload-1118929_1280.png"),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: filename,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  hintText: 'Title Photo'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.datetime,
                              decoration: const InputDecoration(
                                  hintText: 'Date',
                                  suffixIcon: Icon(Icons.calendar_today)),
                              onTap: () async {
                                // ignore: unused_local_variable
                                DateTime? picktimDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              alignment: Alignment.bottomRight,
                              child: TextButton(
                                onPressed: () {
                                  UploadPhotoToGoogleDrive(widget.idalbum);
                                },
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.all(20)),
                                child: const Text(
                                  'Upload',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
          label: const Icon(Icons.add),
        ),
      );
    }
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      if (isSelected) {
        selectList.remove(staticData[index]);
      } else {
        selectList.add(staticData[index]);
      }

      isSelect = selectedFlag.containsValue(store.getItem('isSelectTest'));
    });
  }

  void onOpenSelect() {
    setState(() {
      isSelectionMode = selectedFlag.containsValue(store.getItem('isSelect'));
    });
  }

  Widget? _buildSelectAllButton() {
    // ignore: unused_local_variable
    bool isFalseAvailable =
        selectedFlag.containsValue(store.getItem('isSelect'));
    if (isSelectionMode) {
      return IconButton(
        onPressed: _selectAll,
        icon: const Icon(
          Icons.select_all,
          color: Colors.black,
        ),
      );
    } else {
      return null;
    }
  }

  void _selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    // setState(() {
    isSelectionMode = selectedFlag.containsValue(store.getItem('isSelect'));
    // });
    if (isSelectionMode) {
      // ignore: unnecessary_null_comparison
      if (selectList != null) {
        selectList = [];
        if (testforrun.length < staticData.length) {
          testforrun = [];
          selectList.addAll(staticData);
        } else {
          selectList.addAll(testforrun);
        }
        try {
          if (store.getItem('Data') == null) {
            store.setItem('Data', selectList);
            store.setItem('isSelect', false);
          } else {
            selectList.addAll(testforrun);
            store.setItem('Data', selectList);
            last = store.getItem('Data');
            // ignore: prefer_is_empty
            if (last.length > 0) {
              setState(() {
                store.setItem('isSelect', true);
              });
            } else {
              setState(() {
                store.setItem('isSelect', false);
              });
            }
          }
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }
      }
    } else {
      selectList.clear();
    }
  }

  // ignore: non_constant_identifier_names
  void ClearAll() {
    store.deleteItem('Data');
    store.deleteItem('isSelect');
    store.deleteItem('isSelectTest');
    store.clear();
    bool isFalseAvailable = selectedFlag.containsValue(true);
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = store.getItem('isSelect') ?? false;
    });
    setState(() {
      selectList = store.getItem('Data') ?? [];
      isSelect = store.getItem('isSelectTest') ?? false;
      bool isFalseAvailable = selectedFlag.containsValue(false);
      selectedFlag.updateAll((key, value) => isFalseAvailable);
      isSelectionMode = store.getItem('isSelect') ?? true;
      last = [];
    });
    store.setItem('Data', []);
    store.setItem('isSelect', true);
    store.setItem('isSelectTest', true);
  }
}
