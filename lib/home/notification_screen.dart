

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:http/http.dart'as http;
import 'package:ut_messenger/model/notificationmodel.dart';

import '../helper/api.dart';
import '../helper/session.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotificationList();
  }


  Future<void> refresh() async {
    await Future.delayed(Duration(milliseconds: 100)); // Simulate a network call
    setState(() {
      getNotificationList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notifications"),
      ),

      body: RefreshIndicator(
        onRefresh: refresh,
        color: MyColor.primary,
        child: loading
            ? const Center(child: CircularProgressIndicator(color: MyColor.primary,)) : notificationList.isEmpty ? const Center(child: Text("no Notifications"))
            : ListView.builder(
                itemCount: notificationList.length ,
                itemBuilder: (context,index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: MyColor.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow:  [
                          BoxShadow(color: MyColor.secondary.withOpacity(0.2),
                              blurRadius: 2,spreadRadius: 3),
                        ],

                      ),
                      child: notificationList[index].type == "image" ?
                      GestureDetector(
                        onTap: (){
                          _launchURL(notificationList[index].image.toString());
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(notificationList[index].image!,

                                width: MediaQuery.of(context).size.width-20,
                                fit: BoxFit.cover,),
                              ),
                            ),

                            ExpansionTile(
                              trailing: const Text("Show \nMore",style: TextStyle(fontWeight: FontWeight.bold),),
                              title: SizedBox(
                                  width: MediaQuery.of(context).size.width - 60,
                                  child: Text(
                                    "${notificationList[index].title}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width - 60,
                                    child: Text(
                                      "${notificationList[index].description}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                                const SizedBox(height: 5,)
                              ],
                            ),
                            ],
                        ),
                      )
                      : notificationList[index].type == "pdf" ?
                      GestureDetector(
                        onTap:(){
                          _launchURL(notificationList[index].pdf.toString());
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image.asset("assets/images/pdficon.jpg",height: 100,),
                            ),

                            ExpansionTile(
                              trailing: Text("Show \nMore",style: TextStyle(fontWeight: FontWeight.bold),),
                              title: SizedBox(
                                  width: MediaQuery.of(context).size.width -50,
                                  child: Text(
                                    "${notificationList[index].title}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width -50,
                                    child: Text(
                                      "${notificationList[index].description}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ],
                            ),

                          ],
                        ),
                      )
                      : notificationList[index].type == "video" ?
                      GestureDetector(
                        onTap: (){
                          _launchURL(notificationList[index].video.toString());
                        },
                        child: Column(
                          children: [
                            Image.asset("assets/images/videoimg.png",height: 100,width: MediaQuery.of(context).size.width,fit: BoxFit.contain,),

                            ExpansionTile(
                              trailing: Text("Show \nMore",style: TextStyle(fontWeight: FontWeight.bold),),
                              title: SizedBox(
                                  width: MediaQuery.of(context).size.width-50,
                                  child: Text(
                                    "${notificationList[index].title}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width-50,
                                    child: Text(
                                      "${notificationList[index].description}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                      : notificationList[index].type == "audio" ?
                      GestureDetector(
                        onTap: (){
                          _launchURL(notificationList[index].audio.toString());
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image.asset("assets/images/audio.png",height: 100,),
                            ),

                            ExpansionTile(
                              trailing: Text("Show \nMore",style: TextStyle(fontWeight: FontWeight.bold),),
                              title: SizedBox(
                                  width: MediaQuery.of(context).size.width -50,
                                  child: Text(
                                    "${notificationList[index].title}",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width -50,
                                    child: Text(
                                      "${notificationList[index].description}",
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                      : notificationList[index].type == "text" ?
                      Column(
                        children: [
                          const SizedBox(width: 15,),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 70,
                                // width: 70,
                                decoration:  BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  // shape: BoxShape.circle,
                                  image: const DecorationImage(
                                    image: AssetImage("assets/images/logo.png",)
                                  )
                                ),
                            ),
                          ),
                          const SizedBox(width: 5,),

                          ExpansionTile(
                            trailing: Text("Show \nMore",style: TextStyle(fontWeight: FontWeight.bold),),
                            title:  SizedBox(
                                width: MediaQuery.of(context).size.width -50,
                                child: Text(
                                  "${notificationList[index].title}",
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width -50,
                                  child: Text(
                                    "${notificationList[index].description}",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  )),
                              SizedBox(height: 5,)
                            ],
                          ),
                        ],
                      ) : Container()
                    )
                  );
                }),
      ),
    );
  }



  bool isNetwork = false;
  bool loading = true;
  NotificationModel? notificationModel;
  List<NotificationModel> notificationList=[];


  getNotificationList() async {
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
      var request = http.Request('GET', Uri.parse(AppUrl.notificationList));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Convert the response to a string and parse it
        final responseBody = await response.stream.bytesToString();


        var parsedJson = jsonDecode(responseBody);

        setState(() {
          notificationList = (parsedJson as List).map((e) => NotificationModel.fromJson(e)).toList();
          // notificationModel = NotificationModel.fromJson(parsedJson);
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



  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
