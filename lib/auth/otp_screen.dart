import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/auth/signup_screen.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/bottom_navbar.dart';

import '../helper/api.dart';

class OtpScreen extends StatefulWidget {
  String otp,phoneNo;
   OtpScreen({super.key,required this.otp,required this.phoneNo});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController OtpCOntroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.primary2,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            _loginImg(),
            _loginForm(),
          ],
        ),
      ),
    );
  }

  _loginImg() {
    return Container(
        height: 300,
        margin: const EdgeInsets.only(top: 70),
        width: MediaQuery.of(context).size.width,
        child: SvgPicture.asset("assets/images/otp.svg")
    );
  }

  _loginForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 360),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2 + 40,
        decoration: const BoxDecoration(
          color: MyColor.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // welcome txt
                    const Text(
                      "Verify Otp",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: MyColor.black),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      "Please Enter Otp Send to +91-${widget.phoneNo}",
                      style: const TextStyle(fontSize: 16, color: MyColor.black),
                    ),
                    Text(
                      "otp: ${widget.otp}",
                      style: const TextStyle(fontSize: 16, color: MyColor.black),
                    ),

                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15, left: 15, right: 15, bottom: 10),
                      child: Container(
                        child: PinCodeTextField(
                          appContext: context,
                          keyboardType: TextInputType.number,
                          length: 4,
                          controller: OtpCOntroller,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(8),
                            activeFillColor: MyColor.white,
                            inactiveFillColor: MyColor.white,
                            selectedFillColor: MyColor.white,
                            activeColor: Colors.grey,
                            inactiveColor: Colors.grey,
                            selectedColor: Colors.grey,
                            borderWidth: 0.5,
                            fieldWidth: 58,
                            activeBorderWidth: 0.5,
                            inactiveBorderWidth:0.5,
                          ),
                        ),
                      ),
                    ),

                   
                    // login button
                    InkWell(
                      onTap: ()
                      {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            verifyOtp();
                          }
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                            color: MyColor.primary,
                            borderRadius: BorderRadius.circular(10)),
                        child:
                        // isLoading
                        //     ? loadingWidget()
                        //     :
                         Center(
                          child: isLoading ? const CircularProgressIndicator(color: MyColor.white,) : const Text(
                            'Verify Otp',
                            style: TextStyle(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    GestureDetector(
                        onTap: (){
                          sendOtp();
                          setState(() {});
                        },
                        child:  Center(child: Loading ? const CircularProgressIndicator(color: MyColor.primary,) : const Text("RESEND",style: TextStyle(color: MyColor.primary,fontSize: 17,fontWeight: FontWeight.bold),)))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  bool isLoading = false;
  verifyOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myfcmtoken = prefs.getString('fcmtoken');
    setState(() {
      isLoading = true;
    });
    var request = http.MultipartRequest('POST',Uri.parse(AppUrl.verifyOtp));
    request.fields.addAll(
        {
          'phone':widget.phoneNo,
          'otp': OtpCOntroller.text,
          'device_token': myfcmtoken.toString(),
        });

    print(request.fields);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', finalResult['token']);
      prefs.setString(AppConstants.userdata, jsonEncode(finalResult['user']));

      log("shivani -=-= $finalResult['token']");
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => BottomNavBarMain()),
            (Route<dynamic> route) => false, // This removes all the previous routes.
      );
      setState(() {
        isLoading = false;
      });

    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
        Fluttertoast.showToast(msg: "Invalid Otp");
      });
    } else {
      // Fluttertoast.showToast(msg: "Invalid email or password");
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  bool Loading = false;
  sendOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myfcmtoken = prefs.getString('fcmtoken');
    setState(() {
      Loading = true;
    });
    var request = http.MultipartRequest('POST',Uri.parse(AppUrl.sendOtp));
    request.fields.addAll(
        {
          'phone': widget.phoneNo,
          'device_token': myfcmtoken.toString(),
        });

    print(request.fields);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);

      if (kDebugMode) {
        print("sajaltoken $finalResult['otp']");
      }
      int otp = finalResult['otp'];
      setState(() {
        Loading = false;
      });
      widget.otp = otp.toString();


    } else if (response.statusCode == 403) {
      setState(() {
        Loading = false;
        Fluttertoast.showToast(msg: "Invalid phone");
      });
    } else {
      // Fluttertoast.showToast(msg: "Invalid email or password");
      setState(() {
        Loading = false;
      });
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

}
