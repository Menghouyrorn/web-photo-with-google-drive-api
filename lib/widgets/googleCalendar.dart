// ignore_for_file: file_names

import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';


class GoogleCalendar{
  static final serviceAccountCredentials = ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "apiwithflutter",
    "private_key_id": "1ab78452b963851b17a22e802521a34d6d79cdf6",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDDr1TE9i7B/AUZ\nwmMv53pdTlwlwAnJmJJP6xPIaA1POpni48oisbyevyCRQj2TejZo1aDPtO+vtewM\nXTQQ+nNLOIclQnArccqiu99hpLQl0yi1jqoNue+7+VaDr9UK65Vqp/jr7b0qFfQD\nybQM7LatwKbhM/353VD9vyzCamNsJX6HQbwoy4Lwf6KsRDVjRFjrHRA2wJ7AxShO\nG9RB8S8PTIGFHdM21aXhcDOxFlsAga3PteDwDxPHJN5prt/aM+9RykdX2BXKoG5p\nPUxeBNUFxrX4lhuU0PGcTC1rhve52JVyzWVzp+sZGICRpswHyL5fefvbsOv9wKHf\n7jI0cKulAgMBAAECggEAGPiHvbaYkuKBGB9pHtTQFZYJRjvyQ8p3aUFbPeihQin9\nNynQQoshwbQsCL1GNEqVJN2V7sttBqQVYiKGoWAEVGX7QPLwc2rK6+dDgydMYcNH\nX5u78ZJ3mCoiMx299u3HHFwg9KJa0EMK52zW0Ato6FU8NmK3Fyp5yleZ85k15LfO\noVz/w8meR6bUVkoyT1U9q62K769mg6C/qHSFoLWfXTTUXAbjA3zCWQGD4mKOlGJU\nCJ2H97sgSkcU5T7yYxkVYxx5SVLpuoda8VTIp7nOMd0G8JBot9+L2k2m1LkECc6p\n/QRMzHKTSnAvhQ9qz60FVMjX8ksfl9FRr2raZ4XZYQKBgQD7iXCuV09DQziwN3wQ\nH5964pFLq4x6D9g2MdRvyZ1qxZoDz5cPuGsgjIt8vxjrMNqK9tdz44F1B/CIM6QZ\nK3uWNfSoDhOTAnob2L4gmT4NQPneBTpZav/zfe8Jx/bAYNwWjRnR747x08YVsyYf\nVYerxigs1qvawlveSLeTJOMMmQKBgQDHKDGRDeZYMCLLusXcq1ZZlPuaBKCXksvY\nsnN4RK3Cyw2x0D4H1jcpG5gBuybyRvJlVgUhjeHE6A8MF39DJUMfpVfr0mi8xrVa\neMBAHAD5bhKFMOA7/JCv8VHPHERuPRQC3wT6Amr1QqTqW0Zs/e4GVHB9OQaZ8VFP\nhZCfif1S7QKBgQCyjUBwcUexjnEaHXiylVAG0fejiFXCe6bV6Y9L/wkANt56IAyy\nOw3IYBvP5HLS2K35gPk1qWRG5+jlNgshVs12tjxCYyOf8l0tkTB9QWpbzCjSYlGm\nEZ84f8eD4O8WZms0ktqmPG/y14o/8xh3m6Yf2BzCn2wEcHz4EBRHniKR2QKBgQCp\nonTFxv8isq2Qtp/+G/rLBvlf8P0Q3jq/cxCjqmwO9YHOqT+M0UveueA56T19NC0X\nX7OzJvTdEYRvmjwN51lLRTykY25PDTo/u4aVlMTHsJgZ1s3IipJ7KqOyM7Od6mx3\nHZtRkGmmSoPKEsDj6U6rGZVPNBmJWmEVyQCsw46A6QKBgQCbwUcI4a5FzhRxkW0/\nk1vM1X5O0dScuXtxi2P86DxuMykVXMPOngrjWfL9V6z+M9v28yAJuAvT49dTkazn\nhu3ZQPxOzp93qqo7tpSTEVsKza9WQA25DuDYChV0ouYXtC8FcBgkhQF7sCAnw44r\nPrVPtSaLzY724qj+UKMmKMAtUQ==\n-----END PRIVATE KEY-----\n",
    "client_email": "menghouy@apiwithflutter.iam.gserviceaccount.com",
    "client_id": "116204412999680463158",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/menghouy%40apiwithflutter.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  });

  static final scopes = [calendar.CalendarApi.calendarReadonlyScope];
}