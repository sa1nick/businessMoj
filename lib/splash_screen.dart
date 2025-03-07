import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/home/bottom_navbar.dart';
import 'auth/accept_privacy_screen.dart';
import 'auth/login_screen.dart';
import 'helper/colors.dart';

String? finalOtp;

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 5), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print("isloggedin - $isLoggedIn");
      if (isLoggedIn) {
        // User is logged in, navigate to the Home Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BottomNavBarMain()),
        );
      } else {
        // User is not logged in, navigate to the Login Page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AcceptPrivacyScreen()),
        );
        /*Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );*/
      }
    }
    );
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              "assets/images/splashImage.png",
              // fit: BoxFit.fill,
              fit: BoxFit.cover,
            ),
          ),
        ),
        );
  }

}