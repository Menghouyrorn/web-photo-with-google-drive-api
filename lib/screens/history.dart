// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:theringphoto/service/apiconstans.dart';
import 'package:theringphoto/widgets/typography.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Map<String, dynamic> currentUser = {};

  List DataHistory = [];
  final LocalStorage storeCurrentData = LocalStorage('Store_CurrentData');

  Future<void> GetCurrentUser() async {
    try {
      final uri = ApiConstants.bestUrl + ApiConstants.endpointCurrentUser;
      final res = await http.get(Uri.parse(uri));
      final json = jsonDecode(res.body);

      if (json['message'] == 'success') {
        setState(() {
          currentUser = json['Data'];
        });
        setState(() {});
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  void initState() {
    // if(DateTime.now().microsecond == 1){
    //   storeCurrentData.clear();
    // }
    super.initState();
    GetCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser.isNotEmpty) {
      DataHistory =
          storeCurrentData.getItem(currentUser['id'].toString())['DataUser'];
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: MyTextStyle(
                  name: "History",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: DataHistory.length,
                itemBuilder: (context, index) {
                  final data = DataHistory[index];
                  final id = data['id'];
                  final name = data['name'];
                  String? date;
                  String? time;
                  if (data['date'] != null) {
                    date = DateFormat.yMd().format(data['date']);
                    time = DateFormat.jm().format(data['date']);
                  } else {
                    date = DateFormat.yMd().format(DateTime.now());
                    time = DateFormat.jm().format(DateTime.now());
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    child: Column(
                      children: [
                        ListTile(
                          mouseCursor: SystemMouseCursors.click,
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                "https://drive.google.com/uc?export=open&id=$id"),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            date,
                            style: const TextStyle(
                              color: Color(0xff7D7878),
                            ),
                          ),
                          trailing: Text(
                            time,
                            style: const TextStyle(
                              color: Color(0xff7D7878),
                            ),
                          ),
                        ),
                        const Divider(
                          height: 4,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return const Scaffold(
        body: Text('loading...'),
      );
    }
  }
}
