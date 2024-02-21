// ignore_for_file: file_names

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:theringphoto/screens/listPhoto.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/service/storeTokenUser.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
import 'package:theringphoto/widgets/showMessage.dart';
import 'package:theringphoto/widgets/typography.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:theringphoto/widgets/getTokenFromGoogleDrive.dart';

class ListAlbums extends StatefulWidget {
  const ListAlbums({super.key});

  @override
  State<ListAlbums> createState() => _ListAlbumsState();
}

class _ListAlbumsState extends State<ListAlbums> {
  List<dynamic> staticdataalbums = [];
  bool isHasData = false;
  Map<String, dynamic> currentUser = {};
  List<dynamic> finalData = [];
  final LocalStorage storeCurrentData = LocalStorage('Store_CurrentData');
  // ignore: prefer_typing_uninitialized_variables
  late final accesstoken;

  Future<void> getToken() async {
    try {
      final token = WebSessionStorageService.retrieveToken();
      accesstoken = token;
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

  Future<void> _getdataalbum() async {
    try {
      final url = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
      final uri = Uri.parse(url);
      final respone = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accesstoken'},
      );
      final body = jsonDecode(respone.body);
      // print(body['Data']);
      final result = body['Data'];

      setState(() {
        staticdataalbums = result;
      });
      if (staticdataalbums.isNotEmpty && currentUser.isNotEmpty) {
        for (int i = 0; i < staticdataalbums.length; i++) {
          if (currentUser['id'] == staticdataalbums[i]['userid']) {
            setState(() {
              finalData.add(staticdataalbums[i]);
            });
          }
        }
      }
      isHasData = true;
      //  print(staticdataalbums);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // download data folder
  Future<void> downloadAlbums(String folderid, String foldername) async {
    try {
      final accessToken = await TokenFromGoogleDrive.getAccessToken();
      downloadFolderAsZip(folderid, accessToken, foldername);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // download as zip folder
  Future<void> downloadFolderAsZip(
      String folderId, String accessToken, String foldername) async {
    const apiUrl = 'https://www.googleapis.com/drive/v3/files';
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json'
    };
    try {
      final fileListResponse = await http.get(
        Uri.parse(
            '$apiUrl?q=\'$folderId\' in parents&fields=files(id, name, mimeType)'),
        headers: headers,
      );

      final fileList = json.decode(fileListResponse.body)['files'];
      final archive = Archive();
      for (var file in fileList) {
        if (file['mimeType'] != 'application/vnd.google-apps.folder') {
          final fileId = file['id'];
          final fileName = file['name'];

          final fileDownloadResponse = await http.get(
            Uri.parse('$apiUrl/$fileId?alt=media'),
            headers: headers,
          );

          archive.addFile(ArchiveFile(
            fileName,
            fileDownloadResponse.bodyBytes.length,
            fileDownloadResponse.bodyBytes,
          ));
        }
      }

      final List<int>? zipBytes = ZipEncoder().encode(archive);
      final blob = Blob([zipBytes]);
      // ignore: unused_local_variable
      final anchorElement =
          AnchorElement(href: Url.createObjectUrlFromBlob(blob))
            ..setAttribute('download', '$foldername.zip')
            ..click();
      MessageDialog.showMessageDialog('Folder downloaded as zip successfully.');
    } catch (e) {
      MessageDialog.showMessageDialog('Error downloading folder as zip: $e');
    }
  }

  @override
  void initState() {
    GetCurrentUser();
    getToken();
    _getdataalbum();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser.isNotEmpty) {
      if (storeCurrentData.getItem(currentUser['id'].toString()) == null) {
        currentUser['DataUser'] = [];
        storeCurrentData.setItem(currentUser['id'].toString(), currentUser);
      }
    }

    // ignore: unused_local_variable
    Uri currentUri = Uri.base;
    int columnsCount = 6;
    // ignore: unused_local_variable
    double iconSize = 45;
    // ignore: unused_local_variable
    double? sizefonttest = 12;
    double num = 3 / 4.5;
    if (ResponsiveUtils.isMobile(context)) {
      columnsCount = 3;
      iconSize = 30;

      sizefonttest = 10;
      num = 3 / 4.5;
    } else if (ResponsiveUtils.isDesktop(context)) {
      columnsCount = 8;
      // iconSize = 50;
      sizefonttest = 12;
      num = 3 / 3;
    }

    if (isHasData != true) {
      return const Scaffold(
        body: Center(child: Text('Loading ...')),
      );
    } else {
      return Material(
        child: Column(
          children: [
            Container(
              height: 70,
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10, left: 20),
              child: const Text(
                "Album",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnsCount,
                      childAspectRatio: num,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: finalData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final title = finalData[index]['title'];
                      final idalbum = finalData[index]['idfolder'];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListPhoto(
                                  idalbum: idalbum, titlealbum: title),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.all(0),
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/OneDrive_Folder_Icon.svg/2048px-OneDrive_Folder_Icon.svg.png"),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                child: SizedBox(
                                  width: 120,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              width: 100,
                                              color: Colors.transparent,
                                              child: MyTextStyle(
                                                name: title,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: sizefonttest,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: SizedBox(
                                                width: 10,
                                                height: 10,
                                                child: Tooltip(
                                                  message: 'download',
                                                  child: IconButton(
                                                    onPressed: () {
                                                      downloadAlbums(
                                                          finalData[index]
                                                              ['idfolder'],
                                                          finalData[index]
                                                              ['title']);
                                                    },
                                                    disabledColor: Colors.black,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    // hoverColor:
                                                    //     Colors.transparent,
                                                    // focusColor:
                                                    //     Colors.transparent,
                                                    splashColor:
                                                        Colors.transparent,
                                                    // style: IconButton.styleFrom(
                                                    //   splashFactory: ,
                                                    // ),
                                                    icon: const Icon(
                                                      Icons.download,
                                                      size: 16,
                                                      color: Colors.black,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(0),
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
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    },
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
