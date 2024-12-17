import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/model/staticpage_model.dart';
import 'package:http/http.dart'as http;

import '../helper/api.dart';
import '../helper/session.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    staicPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
      ),
      body:loading ? const Center(child: CircularProgressIndicator(color: MyColor.primary,)) : Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: HtmlWidget(
              staticPageModel!.privacyPolicy!
          ),
        ),
      ),

    );
  }
  bool isNetwork = false;
  bool loading = true;
  StaticPageModel? staticPageModel;


  staicPages() async {
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
      var request = http.Request('GET', Uri.parse(AppUrl.staticpages));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Convert the response to a string and parse it
        final responseBody = await response.stream.bytesToString();
        final parsedJson = jsonDecode(responseBody);

        setState(() {
          staticPageModel = StaticPageModel.fromJson(parsedJson);
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
