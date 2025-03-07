import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';
import '../helper/colors.dart';

class BlockReportDialog extends StatelessWidget {
  const BlockReportDialog({super.key, this.forBlock = false, this.title,this.onTabYes});

  final bool forBlock;

  final String? title;
  final VoidCallback? onTabYes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: forBlock
          ? Text("Do you want to Block ${title ?? 'User'} ?",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
          : Text(
              " Report ${title ?? 'this group'} to Business Moj ?",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
      content: forBlock
          ? const Text(
              "Blocked contacts can not send you messages. this contact will not be notified.",
              style: TextStyle(fontSize: 14))
          :       Text(
              "The last messages from this ${title == null ? 'group' : 'chat'} will be forwarded to Business Moj. No one in this group will be notify.",
              style: const TextStyle(fontSize: 14),
            ),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(0)),
          onPressed: () async {
            Navigator.pop(context);

            // prefs.setString('userId', "");
            // setState(() {});
            // _logout();
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const AuthScreen()));
          },
          child: const Text("cancel", style: TextStyle(color: MyColor.primary)),
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(0)),
            onPressed: onTabYes,
            child: Text(forBlock ? "Block" : "Report",
                style: const TextStyle(color: MyColor.primary))),
      ],
    );
  }
}
