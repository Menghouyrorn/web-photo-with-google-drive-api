// ignore_for_file: unused_local_variable, duplicate_ignore

import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:localstorage/localstorage.dart';
import 'package:theringphoto/admin/screens/list_photo_admin.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/service/storeTokenUser.dart';
import 'package:theringphoto/widgets/getTokenFromGoogleDrive.dart';
import 'package:theringphoto/widgets/googleDriveApi.dart';
import 'package:theringphoto/widgets/responsive_utils.dart';
import 'package:theringphoto/widgets/showMessage.dart';
import 'package:theringphoto/widgets/typography.dart';
import 'package:googleapis/drive/v3.dart' as drive;
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ListAlbumsStaff extends StatefulWidget {
  const ListAlbumsStaff({super.key});

  @override
  State<ListAlbumsStaff> createState() => _ListAlbumsStaffState();
}

class _ListAlbumsStaffState extends State<ListAlbumsStaff> {
  List<dynamic> dataAlbums = [];
  String message = '';
  TextEditingController titlealbum = TextEditingController();
  TextEditingController linkalbums = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables
  late final accesstoken;
  final LocalStorage storeCurrentData = LocalStorage('Store_CurrentData');
  Map<String, dynamic> currentUser = {};
  Map datacurrentUserselect = {};

  Future<void> createFolderInFolder() async {
    final client = await clientViaServiceAccount(
        GoogleDriveApi.serviceAccountCredentials, GoogleDriveApi.scopes);

    final driveApi = drive.DriveApi(client);
    const parentId = '1GAq1AvaFhGBv8-7ERZPKxGwZXOGCqqOR';
    if (linkalbums.text != '') {
      try {
        final createdFile = await driveApi.files.list(
          q: "'$parentId' in parents",
        );
        final idFolder = linkalbums.text.substring(39, 72);
        for (final file in createdFile.files!) {
          if (file.id == idFolder) {
            final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
            final response = await http.post(Uri.parse(uri),
                headers: {'Authorization': 'Bearer $accesstoken'},
                body: jsonEncode(
                    {'idfolder': file.id, 'title': file.name, 'userid': 0}));
            final body = jsonDecode(response.body);
            if (body['message'] == 'success') {
              linkalbums.text = "";
              getDataFromApi();
              MessageDialog.showMessageDialog('Folder created success');
            } else {
              MessageDialog.showMessageDialog('Error');
            }
          }
        }
      } catch (e) {
        MessageDialog.showMessageDialog('Error creating folder: $e');
      } finally {
        client.close();
      }
    } else {
      MessageDialog.showMessageDialog('please input titile name');
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

  //get token when user login
  Future<void> getToken() async {
    try {
      final token = WebSessionStorageService.retrieveToken();
      accesstoken = token;
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // fetch data from backend
  Future<void> getDataFromApi() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
      final res = await http.get(Uri.parse(uri),
          headers: {'Authorization': 'Bearer $accesstoken'});
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          dataAlbums = json['Data'];
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> _updateFolderName(
      String folderid, int id, String foldername) async {
    try {
      final client = await clientViaServiceAccount(
          GoogleDriveApi.serviceAccountCredentials, GoogleDriveApi.scopes);

      var driveApi = drive.DriveApi(client);
      if (titlealbum.text.isNotEmpty) {
        await driveApi.files.update(
          drive.File()..name = foldername,
          folderid,
        );
        final uri = ApiConstants.bestUrl + ApiConstants.endpointsAlbums;
        final response = await http.put(Uri.parse(uri),
            headers: {'Authorization': 'Bearer $accesstoken'},
            body: jsonEncode(
                {'update': 'update', 'id': id, 'title': foldername}));
        final body = jsonDecode(response.body);

        MessageDialog.showMessageDialog('Folder Name Updated success');
        titlealbum.text = "";
        getDataFromApi();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (error) {
      MessageDialog.showMessageDialog('Error: $error');
    }
  }

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
    getToken();
    getDataFromApi();
    titlealbum.text = "";
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser.isNotEmpty) {
      if (storeCurrentData.getItem(currentUser['id'].toString()) == null) {
        currentUser['DataUser'] = [];
        storeCurrentData.setItem(currentUser['id'].toString(), currentUser);
      } else {
        datacurrentUserselect =
            storeCurrentData.getItem(currentUser['id'].toString());
        storeCurrentData.setItem(
            currentUser['id'].toString(), datacurrentUserselect);
      }
    }
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
    if (dataAlbums.isNotEmpty) {
      return Scaffold(
        body: Column(
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
                    // padding: const EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnsCount,
                      childAspectRatio: num,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: dataAlbums.length,
                    itemBuilder: (BuildContext context, int index) {
                      final title = dataAlbums[index]['title'];
                      final idalbum = dataAlbums[index]['idfolder'];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListPhotoAdmin(
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
                                              width: 90,
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
                                                  right: 0),
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: PopupMenuButton(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  constraints:
                                                      const BoxConstraints
                                                          .tightFor(
                                                          height: 120,
                                                          width: 230),
                                                  onSelected: (value) {},
                                                  itemBuilder: (context) {
                                                    return [
                                                      PopupMenuItem(
                                                        child: TextButton.icon(
                                                          onPressed: () {
                                                            downloadAlbums(
                                                                dataAlbums[
                                                                        index][
                                                                    'idfolder'],
                                                                dataAlbums[
                                                                        index]
                                                                    ['title']);
                                                          },
                                                          style: TextButton
                                                              .styleFrom(
                                                            fixedSize:
                                                                const Size(
                                                                    200, 50),
                                                            backgroundColor:
                                                                Colors.white,
                                                            elevation: 0,
                                                          ),
                                                          icon: const Icon(
                                                            Icons.download,
                                                            color: Colors.black,
                                                          ),
                                                          label: const Text(
                                                            "Download",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        // value: 'edit',
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child:
                                                            ElevatedButton.icon(
                                                          onPressed: () {
                                                            titlealbum.text =
                                                                dataAlbums[
                                                                        index]
                                                                    ['title'];
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0)), //this right here
                                                                  child:
                                                                      SizedBox(
                                                                    height: 400,
                                                                    width: 350,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          20),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(10.0),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                const Text(
                                                                                  "Update Album",
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                                                ),
                                                                                Container(
                                                                                  width: 30,
                                                                                  height: 30,
                                                                                  alignment: Alignment.topRight,
                                                                                  margin: const EdgeInsets.only(bottom: 15),
                                                                                  child: IconButton(
                                                                                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          TextFormField(
                                                                            controller:
                                                                                titlealbum,
                                                                            keyboardType:
                                                                                TextInputType.text,
                                                                            decoration:
                                                                                const InputDecoration(hintText: 'Title albums'),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            margin:
                                                                                const EdgeInsets.only(top: 10),
                                                                            alignment:
                                                                                Alignment.bottomRight,
                                                                            child:
                                                                                TextButton(
                                                                              onPressed: () {
                                                                                _updateFolderName(dataAlbums[index]['idfolder'], dataAlbums[index]['id'], titlealbum.text);
                                                                              },
                                                                              style: TextButton.styleFrom(padding: const EdgeInsets.all(20)),
                                                                              child: const Text(
                                                                                'Update',
                                                                                style: TextStyle(color: Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                40,
                                                                          ),
                                                                          Text(
                                                                              message,
                                                                              style: const TextStyle(color: Colors.green)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          style: TextButton
                                                              .styleFrom(
                                                            fixedSize:
                                                                const Size(
                                                                    200, 50),
                                                            backgroundColor:
                                                                Colors.white,
                                                            elevation: 0,
                                                          ),
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color: Colors.black,
                                                          ),
                                                          label: const Text(
                                                            "Edit album",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                      ),
                                                    ];
                                                  },
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Create Album",
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
                                    onPressed: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .pop(),
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
                          TextFormField(
                            controller: linkalbums,
                            keyboardType: TextInputType.text,
                            decoration:
                                const InputDecoration(hintText: 'Link Albums'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () {
                                createFolderInFolder();
                              },
                              style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(20)),
                              child: const Text(
                                'Add Albums',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text(message,
                              style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          label: const Icon(Icons.add),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: Text('Loading'),
      ),
    );
  }
}
