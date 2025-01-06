import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/settings.dart';
import 'package:ut_messenger/splash_screen.dart';
import 'package:ut_messenger/voicecall/voice_call.dart';

import 'call/call_screen.dart';
import 'notification/notification_controller.dart';
import 'notification_service.dart';



Future<void> main() async {
  print("App is starting...");
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.initializeIsolateReceivePort();
  await NotificationController.startListeningNotificationEvents();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAiUTeYzzq4nD7btvbHV_XRJP10r2q8q68',
          appId: '1:157135741762:android:d2719d66d58709cce61edb',
          messagingSenderId: '157135741762',
          projectId: 'businessmoj-6b0b0'));
  await NotificationController.initializeLocalNotifications();
  HttpOverrides.global = MyHttpOverrides();


  //LocalNotificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try{
    String? token = await FirebaseMessaging.instance.getToken();
    await prefs.setString('fcmtoken', token!);
    print("-----------token:-----${token}");
  } on FirebaseException{
    print('__________FirebaseException_____________');
  }

  runApp(const MyApp());
  print("App is starting...");
}

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationController.handleFirebaseMessage(message);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static Color mainColor = const Color(0xFF9D50DD);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Business Moj',
      navigatorKey: MyApp.navigatorKey,
      routes: {
        '/': (context) => SplashScreen(),
        // '/call': (context) => VoiceCall(), // Define your call page route here
        // '/video': (context) => CallScreen(),
        '/setting': (context) => SettingScreen(),
      },
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            toolbarHeight: 45,
            backgroundColor: MyColor.primary,
            foregroundColor: MyColor.white,
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'CustomFont')
        ),
        fontFamily: 'CustomFont',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }


}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}