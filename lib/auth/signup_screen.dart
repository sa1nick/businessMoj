import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/auth/login_screen.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/bottom_navbar.dart';
import 'package:ut_messenger/model/usermodel.dart';

import 'otp_screen.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getCity();
  }

  final projectNameController = TextEditingController();
  final gstNoCTr = TextEditingController();
  final gstNameController = TextEditingController();
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final passController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateEmail(value) {
    if (value!.isEmpty) {
      return "Please enter an email";
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email";
    }
  }

  bool _obscureText = true;
  bool _obscureText2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,
        centerTitle: true,
        title: const Text(
          "",//Sign Up
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,color: MyColor.black),
        ),
       automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 28,
                        color: MyColor.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: MyColor.secondaryLight,
                            hintText: 'First Name',
                            hintStyle: const TextStyle(color: MyColor.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            color: MyColor.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        TextFormField(
                          controller: lastnameController,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: MyColor.secondaryLight,
                            hintText: 'Last Name',
                            hintStyle: const TextStyle(color: MyColor.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            color: MyColor.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // Mobile Number
                        TextFormField(
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: MyColor.secondaryLight,
                            hintText: 'Mobile Number',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                              child: Text(
                                "+91",
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                              ),
                            ),
                            hintStyle: const TextStyle(color: MyColor.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Mobile Number';
                            } else if (value.length < 10) {
                              return 'Please enter a valid Mobile Number';
                            }
                            return null;
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // Email Field (Skippable, no validation)
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: MyColor.secondaryLight,
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: MyColor.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // Create Password Field (Skippable, no validation)
                        TextFormField(
                          controller: passController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: MyColor.secondaryLight,
                            hintText: 'Create Password',
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: MyColor.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: SizedBox(
          height: 100,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    signUp();

                  }

                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: MyColor.primary,
                      borderRadius: BorderRadius.circular(10)),
                  child:
                  isLoading
                      ? const Center(
                        child: SizedBox(
                        width: 45,
                        height: 45,
                        child: CircularProgressIndicator(color:Colors.white)),
                      )
                      :
                  const Center(
                      child: Text('Sign Up',
                          style: TextStyle(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 14, color: MyColor.black),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false, // This removes all the previous routes.
                      );
                    },
                    child: const Text(
                      "SignIn",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: MyColor.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  sendOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myfcmtoken = prefs.getString('fcmtoken');
    setState(() {
      isLoading = true;
    });
    var request = http.MultipartRequest('POST',Uri.parse(AppUrl.sendOtp));
    request.fields.addAll(
        {
          'phone': mobileController.text,
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
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>  OtpScreen(otp: otp.toString(),phoneNo: mobileController.text,)));


    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
        Fluttertoast.showToast(msg: "User Not found");
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



  bool isLoading = false;
  signUp() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

   // String?  token = await FirebaseMessaging.instance.getToken();
    setState(() {
      isLoading = true;
    });

    var request = http.MultipartRequest('POST', Uri.parse(AppUrl.Register));
    request.fields.addAll({
      'f_name': nameController.text,
      'l_name': lastnameController.text,
      'email': emailController.text,
      'phone': mobileController.text,
      'password': passController.text,
      'device_token': 'token' ?? '',
    });



      print(request.fields);
      print(request.url);


    http.StreamedResponse response = await request.send();
    print('${response.statusCode}');
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      if (finalResult['errors'] !=null) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "${finalResult['message']}");
      } else {
        setState(() {
          isLoading = false;
        });

        prefs.setBool('isLoggedIn', true);
        prefs.setString('fname', finalResult['user']['f_name']);
        prefs.setString('lname', finalResult['user']['l_name']);
        prefs.setString('mobile', finalResult['user']['phone']);
        prefs.setString('token', finalResult['token']);

       // UserModel user = UserModel.fromJson(finalResult['user']);

        prefs.setString(AppConstants.userdata, jsonEncode(finalResult['user']));

         // String? userData = prefs.getString(AppConstants.userdata);

        sendOtp();
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => BottomNavBarMain()),
        //       (Route<dynamic> route) => false, // This removes all the previous routes.
        // );
        setState(() {
          isLoading = false;
        });
      }
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      print('${finalResult}');
      Fluttertoast.showToast(msg: "${finalResult['errors'][0]['message']}");
    } else {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }



}

//com.businessmoj.main