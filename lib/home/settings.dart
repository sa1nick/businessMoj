import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/chat/chat_page.dart';
import 'package:ut_messenger/drawer_page/aboutus.dart';
import 'package:ut_messenger/drawer_page/change_password.dart';
import 'package:ut_messenger/auth/login_screen.dart';
import 'package:ut_messenger/drawer_page/faq.dart';
import 'package:ut_messenger/drawer_page/privacypolicy.dart';
import 'package:ut_messenger/drawer_page/termsandconditions.dart';
import 'package:ut_messenger/drawer_page/update_profile.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:http/http.dart'as http;
import 'package:ut_messenger/subscription/subscription_screen.dart';
import 'package:ut_messenger/widgets/logout_dialog.dart';
import '../helper/session.dart';
import '../model/getprofile_model.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserimage();
    getuser();
  }

String? firstname,lastname,phoneNo;
  getuser()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
     firstname = prefs.getString('fname')??"";
     lastname = prefs.getString('lname')??"";
     phoneNo = prefs.getString('mobile')??"";
  }

  Future<void> refresh() async {
    await Future.delayed(Duration(milliseconds: 100)); // Simulate a network call
    setState(() {
     getUserimage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Settings"),
      ),

      body: RefreshIndicator(
        color: MyColor.primary,
        onRefresh: refresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              const SizedBox(height: 10,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const UpdateProfileScreen()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: MyColor.secondaryLight,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12,
                          blurRadius: 2,spreadRadius: 3),
                    ],

                  ),
                  child:  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                 loading ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: MyColor.primary,)
                ): Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CircleAvatar(
                          foregroundImage: NetworkImage(getProfileModel?.image.toString()??""),
                          radius: 30,
                        ),
                      ),
                      Expanded(
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loading ? " " : "${getProfileModel?.fName} ${getProfileModel?.lName}",style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            Row(
                              children: [
                                const Icon(Icons.call),
                                Text(loading ? " " :"+91-${getProfileModel?.phone}",style: const TextStyle(fontSize: 15,),),
                              ],
                            )
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded),
                      const SizedBox(width: 10,),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10,),
              Expanded(
                child: ListView(
                  children: [
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const ChangePassword()));
                        },
                        child: buildOptionTile("assets/images/changepassword.png", "Change Password")),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const SubscriptionScreen()));
                        },
                        child: buildOptionTile("assets/images/changepassword.png", "Subscription")),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const PrivacyPolicy()));
                        },
                        child: buildOptionTile("assets/images/privacy.png", "Privacy Policy")),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const TermsAndConditions()));
                        },
                        child: buildOptionTile("assets/images/terms.png", "Terms & Conditions")),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const FaqScreen()));
                        },
                        child: buildOptionTile("assets/images/faq.png", "FAQ\'s")),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const AboutUs()));
                        },
                        child: buildOptionTile("assets/images/aboutus.png", "About Us")),
                    /*GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const ChatPage(name: 'Admin', image: "assets/images/logo.png",friendId: '1',)));
                        },
                        child: buildOptionTile("assets/images/supoortChat.png", "Support Chat")),*/
                    GestureDetector(
                        onTap: () async {
                          showDialog(
                              context: context,
                              // barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const LogoutDialog();
                              });


                        },
                        child: buildOptionTile("assets/images/logout.png", "Logout")),
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }


  Widget buildOptionTile(String icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: MyColor.white,
          borderRadius: BorderRadius.circular(8),
            boxShadow:  [
              BoxShadow(color: MyColor.shadow,spreadRadius: 2,blurRadius: 2)
            ]
        ),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: MyColor.white,
                borderRadius: BorderRadius.circular(25),

              ),
              child: Image.asset(icon,),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
            const Icon(Icons.arrow_forward_ios, color: MyColor.black, size: 20),
          ],
        ),
      ),
    );
  }



  bool isNetwork = false;
  bool loading = false;
  GetProfileModel? getProfileModel;


  getUserimage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mytoken = prefs.getString('token');
    // Check network availability
    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      setState(() {
        loading = true;
      });

      var headers = {
        'Authorization': 'Bearer $mytoken'
      };
      var request = http.Request('GET', Uri.parse(AppUrl.getProfile));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Convert the response to a string and parse it
        final responseBody = await response.stream.bytesToString();
        final parsedJson = jsonDecode(responseBody);

        setState(() {
          getProfileModel = GetProfileModel.fromJson(parsedJson);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load profile");
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
    // } else {
    //   // Handle no internet
    //   Fluttertoast.showToast(msg: "No internet connection");
    // }
  }


}
