import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/colors.dart';

import 'login_screen.dart';

class AcceptPrivacyScreen extends StatefulWidget {
  const AcceptPrivacyScreen({super.key});

  @override
  State<AcceptPrivacyScreen> createState() => _AcceptPrivacyScreenState();
}

class _AcceptPrivacyScreenState extends State<AcceptPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor:Colors.white ,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          // Circular illustration
          Container(
            //width: 200,
            //height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
           // clipBehavior: Clip.antiAlias,
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Image(image: AssetImage('assets/images/businessmojdoodle.png'),fit: BoxFit.fitWidth,),
            ),
          ),
          const SizedBox(height: 30),

          const Text(
            'Welcome to Business Moj',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: MyColor.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Privacy Policy and Terms text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: RichText(
              textAlign: TextAlign.center,
              text:  TextSpan(
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                children: [
                  const TextSpan(text: 'Read our ',style: TextStyle(color: MyColor.grey,fontSize: 12)),
                  TextSpan(
                    text: 'Privacy Policy',
                    recognizer: TapGestureRecognizer()..onTap = () {
                      _openUrl('https://businessmoj.com/privacy-policy');
                    },
                    style: const TextStyle(
                      color: MyColor.primary,
                      decoration: TextDecoration.underline,fontSize: 12,
                    ),
                  ),
                  const TextSpan(text: '. Tap "Agree and continue" to accept the ',style: TextStyle(color: MyColor.grey,fontSize: 12)),
                  TextSpan(
                    text: 'Terms of Service',
                    recognizer: TapGestureRecognizer()..onTap = () {
                      _openUrl('https://businessmoj.com/terms');
                    },
                    style: const TextStyle(
                      color: MyColor.primary,
                      decoration: TextDecoration.underline,fontSize: 12
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Agree button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              'AGREE AND CONTINUE',
              style: TextStyle(fontSize: 16, color: MyColor.white),
            ),
          ),
          const SizedBox(height: 20),
          // Footer text

        ],
      ),
    );
  }
  void _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error if URL cannot be launched
      print('Could not launch $url');
    }
  }
}
