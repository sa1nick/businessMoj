import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ut_messenger/model/chatlist_model.dart';
import '../helper/api.dart';
import '../misc/full_image_view.dart';

class InChatProfileInfo extends StatelessWidget {
  final ChatListData? chatListData;
  final String image;

  const InChatProfileInfo({
    Key? key,
    this.chatListData,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    final user = chatListData?.chatroom?.first.user;
    String fullName = (user?.fName?.trim().isNotEmpty ?? false)
        ? "${user!.fName} ${user.lName ?? ''}".trim()
        : user?.phone ?? 'NA';
    String mobile = user?.phone?.isNotEmpty == true ? user!.phone! : 'NA';

    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Profile Image Section
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullImageView(
                    imageUrl: image,
                    title: fullName,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: image.isNotEmpty
                  ? Image.network(
                image,
                fit: BoxFit.cover,
                height: 300,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/images/blank_profile_picture.png",
                    fit: BoxFit.cover,
                    height: 300,
                    width: double.infinity,
                  );
                },
              )
                  : Image.asset(
                "assets/images/blank_profile_picture.png",
                fit: BoxFit.cover,
                height: 300,
                width: double.infinity,
              ),
            ),
          ),


          const SizedBox(height: 20),



          const SizedBox(height: 10),

          // Mobile Number Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(mobile, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ),
          ),

          const SizedBox(height: 20),

          // Block & Report Section
          _buildActionTile(context, Icons.block, "Block", Colors.red, () {
            _showBlockConfirmation(context, user?.id?.toString() ?? '');
          }),

          _buildActionTile(context, Icons.report, "Report", Colors.redAccent, () {
            Fluttertoast.showToast(msg: "Report feature coming soon!");
          }),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        onTap: onTap,
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context, String friendId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Block User"),
          content: const Text("Are you sure you want to block this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                userBlock(context, friendId);
              },
              child: const Text("Block", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> userBlock(BuildContext context, String friendId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    try {
      var headers = {'Authorization': 'Bearer $token'};
      var body = {'friend_id': friendId};

      http.Response response = await http.post(Uri.parse(AppUrl.blockUserApi),
          headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Fluttertoast.showToast(msg: data['message']);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Failed to block user.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }
}
