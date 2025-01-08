import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/helper/colors.dart';

import '../auth/login_screen.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: const Text("Log out",style: TextStyle(fontSize: 20),
      ),
      content: const Text("Do you really want to logout?",style: TextStyle(fontSize: 12),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: MyColor.primary),
          onPressed: () async {
            SharedPreferences prefs =
            await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', false);
            await prefs.setString('fname', "");
            await prefs.setString('lname', "");
            await prefs.setString('mobile', "");

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false, // This removes all the previous routes.
            );
            // prefs.setString('userId', "");
            // setState(() {});
            // _logout();
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const AuthScreen()));
          },
          child: const Text("Yes",
              style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(MyColor.primary),
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Text("No",
                style: TextStyle(color: Colors.white))),
      ],
    );
  }
}



class DeleteAccountDialog extends StatelessWidget {
   DeleteAccountDialog({super.key,required this.heading,required this.title,required this.onTab});


  String heading ;
  String title ;
  VoidCallback onTab ;

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title:   Text(heading,style: const TextStyle(fontSize: 20),
      ),
      content:  Text(title,style: const TextStyle(fontSize: 12),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: MyColor.primary),
          onPressed: onTab,
          child: const Text("Yes",
              style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(MyColor.primary),
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Text("No",
                style: TextStyle(color: Colors.white))),
      ],
    );
  }
}

