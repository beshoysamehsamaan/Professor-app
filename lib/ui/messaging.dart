 import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class Messaging {
  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
      'AAAAMF2P81Y:APA91bF2YnaXiOWZVtFFlMbnO1SE9qtBG7c6vopK7CuIof8oMFuM_uoxwJUMiJ2nhQV3AXmjjdwjOllGITV5GautjIVIICqnWLmAfsQgsxYSYK_aBzE6oft2RHWmwYGrV-y8cTMWxaqY';

  static Future<Response> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: "d4NZRvUBq6k:APA91bFGhcvQpVeGv_NL2fhbus_0XmduJUxyrZOSwf1ATo82NhgWds_2NDBfIQam3t-va1xFi5vox-IkkHpROYuUfigPkRJQ0GM4O5Qv2xzY_Rc7w6ou9XML2OrWEhmo7grWZZ17d_-0");

  static Future<Response> sendToTopic(
          {@required String title,
          @required String body,
          @required String topic}) =>
      sendTo(title: title, body: body, fcmToken: topic);

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'notification': {'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          },
          'to': "d4NZRvUBq6k:APA91bFGhcvQpVeGv_NL2fhbus_0XmduJUxyrZOSwf1ATo82NhgWds_2NDBfIQam3t-va1xFi5vox-IkkHpROYuUfigPkRJQ0GM4O5Qv2xzY_Rc7w6ou9XML2OrWEhmo7grWZZ17d_-0",
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );
}
