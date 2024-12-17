import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/main.dart';
import 'package:http/http.dart'as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../helper/api.dart';

/*
class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
       'resource://mipmap/ic_launcher',
        [
          NotificationChannel(
              locked: true,
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    MyApp.navigatorKey.currentState?.

    pushNamedAndRemoveUntil(
        '/',
            (route) =>
        (route.settings.name != '/') || route.isFirst,
        arguments: receivedAction);
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************
  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: -1, // -1 is replaced by a random number
            channelKey: 'alerts',
            title: 'Huston! The eagle has landed!',
            body:
            "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static Future<void> showCallNotification(String callerName) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Request permission if not already granted
      AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'alerts',
        title: 'Incoming Call',
        body: 'Call from $callerName',
        notificationLayout: NotificationLayout.BigText,
        autoDismissible: false, // Keeps notification persistent
        category: NotificationCategory.Call,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ANSWER',
          label: 'Answer',
          color: Colors.green,
          autoDismissible: true, // Dismiss notification on click
        ),
        NotificationActionButton(
          key: 'REJECT',
          label: 'Reject',
          color: Colors.red,
          autoDismissible: true, // Dismiss notification on click
        ),
      ],
    );
  }

  static Future<void> scheduleNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await myNotifyScheduleInHours(
        title: 'test',
        msg: 'test message',
        heroThumbUrl:
        'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
        hoursFromNow: 5,
        username: 'test user',
        repeatNotif: false);
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

Future<void> myNotifyScheduleInHours({
  required int hoursFromNow,
  required String heroThumbUrl,
  required String username,
  required String title,
  required String msg,
  bool repeatNotif = false,
}) async
{
  var nowDate = DateTime.now().add(Duration(hours: hoursFromNow, seconds: 5));
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar(
      //weekday: nowDate.day,
      hour: nowDate.hour,
      minute: 0,
      second: nowDate.second,
      repeats: repeatNotif,
      //allowWhileIdle: true,
    ),
    // schedule: NotificationCalendar.fromDate(
    //    date: DateTime.now().add(const Duration(seconds: 10))),
    content: NotificationContent(
      id: -1,
      channelKey: 'basic_channel',
      title: '${Emojis.food_bowl_with_spoon} $title',
      body: '$username, $msg',
      bigPicture: heroThumbUrl,
      notificationLayout: NotificationLayout.BigPicture,
      //actionType : ActionType.DismissAction,
      color: Colors.black,
      backgroundColor: Colors.black,
      // customSound: 'resource://raw/notif',
      payload: {'actPag': 'myAct', 'actType': 'food', 'username': username},
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'NOW',
        label: 'btnAct1',
      ),
      NotificationActionButton(
        key: 'LATER',
        label: 'btnAct2',
      ),
    ],
  );
}
*/
///  *********************************************
///     MAIN WIDGET
///  *********************************************
///



class NotificationController {
  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'General notifications',
          playSound: true,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          ledColor: Colors.deepPurple,
          defaultColor: Colors.deepPurple,

        ),
      ],
      debug: true,
    );

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: false);

    // Request notification permissions
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');





    // Get FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleFirebaseMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification when the app is opened from a terminated state
      handleFirebaseMessage(message, onOpen: true);
    });
  }

  static ReceivePort? receivePort;
 static Future<void>  initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {

    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }



  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {


    print('sasa-- ${receivedAction.title} ${receivedAction.body} ${receivedAction.actionType}');
    print('sasa-- ${receivedAction.payload} ');

    if(receivedAction.actionType == ActionType.DismissAction){

      await AwesomeNotifications().dismiss(receivedAction.id!,);

      var data=  receivedAction.payload;
      print("call reject function");
      rejectCall(data?['friend_id'] ?? '', data?['channel_id'] ?? '', data?['type'] ?? '', data?['user_id'] ?? '');

    }else if(receivedAction.buttonKeyPressed == 'ANSWER' && receivedAction.title == "Incoming Audio Call"){

     await AwesomeNotifications().dismiss(receivedAction.id!,);
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
       '/call',
           (route) =>
       (route.settings.name != '/') || route.isFirst,
       arguments: [receivedAction.payload]); }

   if(receivedAction.buttonKeyPressed == 'ANSWER' && receivedAction.title == "Incoming Video Call"){
     await AwesomeNotifications().dismiss(receivedAction.id!);
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/video',
            (route) =>
        (route.settings.name != '/') || route.isFirst,
        arguments: [receivedAction.payload]);}
   if(receivedAction.buttonKeyPressed == 'REJECT'){
     await AwesomeNotifications().dismiss(receivedAction.id!,);

     var data=  receivedAction.payload;
     print("call reject function");
     rejectCall(data?['friend_id'] ?? '', data?['channel_id'] ?? '', data?['type'] ?? '', data?['user_id'] ?? '');

   }

 }

 ///Reject Call Event When user pressed reject call button

 static Future<void> rejectCall(String friendId, String channel, String type, String userid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var headers = {'Authorization': 'Bearer $token'};
    var request = http.MultipartRequest('POST', Uri.parse(AppUrl.callReject));
    request.fields.addAll({
      'friend_id':userid,
      'channel_id': channel,
      'type': "reject_call",
      'user_id': friendId,
    });
    request.headers.addAll(headers);

    print(request.fields);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();

      var data = jsonDecode(result);

    } else if (response.statusCode == 403) {
      // Fluttertoast.showToast(msg: "Invalid email or password");
      if (kDebugMode) {
        print("not send");
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///




  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {

   print('_________________jkhkhfkjsdhfhsd');


    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction ) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    }  else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }



  static Future<void> handleFirebaseMessage(RemoteMessage message, {bool onOpen = false}) async {
    String? title = message.notification?.title;
    String? body = message.notification?.body;
    String? messageType = message.data['type'] ?? 'text'; // Message type: 'text', 'audio_call', 'video_call'

    // print(message.data);
    switch (messageType) {
      case 'voice_call':
        await showCallNotification(body ?? '', isVideo: false,message);
        break;
      case 'video_call':
        await showCallNotification(body ?? '',message, isVideo: true);
        break;
        case 'reject_call':
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: DateTime.now().second,
              channelKey: 'alerts',
              title: title,
              body: body,
              autoDismissible: true,
              notificationLayout: NotificationLayout.Default,
              payload:  message.data.map((key, value) => MapEntry(key, value.toString())),
            ),
          );
        break;
      default:
      // Default text message notification
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().second,
            channelKey: 'alerts',
            title: title,
            body: body,
            autoDismissible: false,
            notificationLayout: NotificationLayout.Default,
            payload:  message.data.map((key, value) => MapEntry(key, value.toString())),
          ),

        );
    }
  }




  static Future<void> showCallNotification(String callerName, RemoteMessage message, {required bool isVideo}) async {

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().second,
        channelKey: 'alerts',
        title: isVideo ? 'Incoming Video Call' : 'Incoming Audio Call',
        body: callerName,
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Call,
        autoDismissible: false,
        duration: const Duration(minutes: 1),
        payload: message.data.map((key, value) => MapEntry(key, value.toString()))// Persistent notification
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ANSWER',
          label: 'Answer',
          color: Colors.green,
          autoDismissible: false,
          enabled: true,
          actionType: ActionType.Default
        ),
        NotificationActionButton(
          key: 'REJECT',
          label: 'Reject',
          color: Colors.red,
          autoDismissible: false,
          enabled: true,
          actionType: ActionType.Default
        ),
      ],
    );


  }





}
