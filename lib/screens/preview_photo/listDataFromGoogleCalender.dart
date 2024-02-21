import 'package:flutter/material.dart';

class ListDataFromGoogleCalender extends StatelessWidget {
  String title;
  String des;
  String start;
  String end;
  ListDataFromGoogleCalender(
      {super.key,
      required this.title,
      required this.start,
      required this.end,
      required this.des});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            children: [
              Text(des.isEmpty ? 'no description':des),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(start),
                  Text(end),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
