import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:video_call/utils/user.utils.dart';

String MEETING_API_URL = "http://192.168.1.33:4000/api/meeting";

var client = http.Client();

Future<http.Response?> startMeeting() async {
  Map<String, String> requestHeaders = {'Content-Type': 'application/json'};

  var userId = await loadUserId();

  var response = await client.post(
    Uri.parse('$MEETING_API_URL/start'),
    headers: requestHeaders,
    body: jsonEncode(
      {
        'hostId': userId,
        'hostName': '',
      },
    ),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    return null;
  }
}

Future<http.Response> joinMeeting(String meetingId) async {
  var response = await http.get(Uri.parse('$MEETING_API_URL/join?meetingId=$meetingId'));

  if (response.statusCode >= 200 && response.statusCode < 400) {
    return response;
  }

  throw UnsupportedError('Not a valid Meeting');
}
