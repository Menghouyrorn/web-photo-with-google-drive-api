import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:theringphoto/screens/preview_photo/listDataFromGoogleCalender.dart';
import 'package:theringphoto/widgets/getTokenFromGoogleDrive.dart';
import 'package:theringphoto/widgets/googleCalendar.dart';

class GetDataFromCalender extends StatefulWidget {
  const GetDataFromCalender({super.key});

  @override
  State<GetDataFromCalender> createState() => _GetDataFromCalenderState();
}

class _GetDataFromCalenderState extends State<GetDataFromCalender> {
  List test = [];
  List datafromgoogleCalender = [];

  Future<calendar.CalendarApi> authenticate() async {
    final client = await clientViaServiceAccount(
        GoogleCalendar.serviceAccountCredentials, GoogleCalendar.scopes);

    return calendar.CalendarApi(client);
  }

  Future<List> fetchCalendarEvents() async {
    final calendarApi = await authenticate();
    Map testfun = {};

    final events = await calendarApi.events.list(
        'b1885ffddf6c4104018aa0a04116c434bee229abe5aeee4a0863f7e5c2a04d22@group.calendar.google.com');
    for (final event in events.items!) {
      testfun = {
        "id": event.id,
        "title": event.summary,
        "start": event.start!.dateTime,
        "end": event.end!.dateTime,
        'des': event.description,
      };
      test.add(testfun);
    }

    return test;
  }

  Future<void> getData() async {
    try {
      final accesstoken = await TokenFromGoogleDrive.getAccessToken();
      const calendarId =
          "b1885ffddf6c4104018aa0a04116c434bee229abe5aeee4a0863f7e5c2a04d22@group.calendar.google.com";
      const uri = "https://www.googleapis.com/calendars/$calendarId/events";
      final res = await http.get(Uri.parse(uri), headers: {
        'Authorization': 'Bearer $accesstoken',
      });
      final json = jsonDecode(res.body);
      print(json);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> getDataTest() async {
    try {
      List data = await fetchCalendarEvents();

      setState(() {
        datafromgoogleCalender = data;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // fetchCalendarEvents();
    getDataTest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (datafromgoogleCalender.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Get Data From Google Calender',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Data From Google Calender',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 3 / 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: datafromgoogleCalender.length,
                    itemBuilder: (BuildContext context, index) {
                      final id = datafromgoogleCalender[index]['id'];
                      final title = datafromgoogleCalender[index]['title'];
                      final start = datafromgoogleCalender[index]['start'];
                      final end = datafromgoogleCalender[index]['end'];
                      String des = "";
                      if (datafromgoogleCalender[index]['des'] != null) {
                        des = datafromgoogleCalender[index]['des'];
                      }

                      // DateTime datetimeof = DateTime.now();
                      // String formattedTime = DateFormat.Hms().format(now);
                      String formattedTimeforStart =
                          DateFormat.jm().format(start);
                      // print(formattedTime);
                      String formattedTimeforEnd = DateFormat.jm().format(end);
                      return InkWell(
                        hoverColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        focusColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListDataFromGoogleCalender(
                                  title: title,
                                  start: formattedTimeforStart,
                                  end: formattedTimeforEnd,
                                  des: des),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.only(left: 20),
                          child: SizedBox(
                            width: 200,
                            height: 100,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(
                                          width: 40,
                                        ),
                                        Text(
                                          formattedTimeforStart,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 40,
                                        ),
                                        Text(
                                          formattedTimeforEnd,
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 40,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Get data from google Calender'),
        ),
        body: const Center(
          child: Text('loading...'),
        ),
      );
    }
  }
}
