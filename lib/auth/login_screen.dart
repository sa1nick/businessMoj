import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/auth/otp_screen.dart';
import 'package:ut_messenger/auth/signup_screen.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/bottom_navbar.dart';
import 'package:ut_messenger/home/home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
// String? token,userId;
class _LoginPageState extends State<LoginPage> {
  int? otp;
  String? mobile;
  bool isLoading = false;
  String? _loginType = 'phone';

  final _formKey = GlobalKey<FormState>();
  int selectedIndex = 99;
  bool selected = false;
  bool _obscureText = true;
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

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
      margin: const EdgeInsets.only(top: 50),
      width: MediaQuery.of(context).size.width,
      child: SvgPicture.asset("assets/images/login.svg")
    );
  }

  _loginForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 360),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 1.80 ,
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
                      "Sign In",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: MyColor.black),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Welcome, Please Enter Your Details",
                      style: TextStyle(fontSize: 16, color: MyColor.black),
                    ),

                    const SizedBox(height: 8),

                    // radio buttons
                    Row(
                      children: [
                        Radio<String>(
                          value: 'phone',
                          groupValue: _loginType,
                          fillColor:
                          MaterialStateProperty.all(MyColor.primary),
                          onChanged: (String? value) {
                            setState(() {
                              _loginType = value;
                            });
                          },
                        ),
                        const Text(
                          "Phone",
                          style:
                          TextStyle(fontSize: 14, color: MyColor.black),
                        ),
                        Radio<String>(
                          value: 'email',
                          groupValue: _loginType,
                          fillColor:
                          MaterialStateProperty.all(MyColor.primary),
                          onChanged: (String? value) {
                            setState(() {
                              _loginType = value;
                            });
                          },
                        ),
                        const Text(
                          "Email",
                          style:
                          TextStyle(fontSize: 14, color: MyColor.black),
                        )
                      ],
                    ),

                    const SizedBox(height: 4),

                    _loginType == 'phone'
                    // mobile txt field
                        ? TextFormField(
                      controller: mobileController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        isDense: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0,horizontal: 10),
                          child: Text("+91",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                        ),
                        fillColor: MyColor.secondaryLight,
                        hintText: 'Mobile Number',
                        hintStyle:
                        const TextStyle(color: Colors.black),
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
                          return 'Please enter a mobile number';
                        } else if (value!.length < 10 ||
                            value!.length > 10) {
                          return 'Please enter valid mobile number';
                        }
                        return null;
                      },
                    )
                        : Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: MyColor.secondaryLight,
                            hintText: 'Email',
                            hintStyle:
                            const TextStyle(color: Colors.black),
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
                          validator: _validateEmail,
                        ),

                        const SizedBox(height: 10),

                        // Password Field
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: passController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor: MyColor.secondaryLight,
                            hintText: 'Password',
                            hintStyle:
                            const TextStyle(color: Colors.black),
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
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a password';
                            } else if (value!.length < 8) {
                              return 'Password is too short';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // login button
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          _loginType == 'phone' ? sendOtp() : login();
                        }
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                            color: MyColor.primary,
                            borderRadius: BorderRadius.circular(10)),
                        child:
                        isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            :
                            Center(
                          child: Text(
                            _loginType == 'phone' ? 'Send OTP' : 'Login',
                            style: const TextStyle(
                              color: MyColor.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: MyColor.black
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()));
                          },
                          child: const Text(
                            "SignUp",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: MyColor.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(value) {
    if (value!.isEmpty) {
      return "Please enter an email";
    }
    RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email";
    }
  }



  login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? myfcmtoken = prefs.getString('fcmtoken');
    setState(() {
      isLoading = true;
    });
    var request = http.MultipartRequest('POST',Uri.parse(AppUrl.login));
    request.fields.addAll(
        {
          'email': emailController.text,
          'password': passController.text,
          'device_token': myfcmtoken.toString(),
        });

    print(request.fields);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);

        if (kDebugMode) {
          print("sajaltoken"+finalResult['token']);
        }
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('fname', finalResult['user']['f_name']);
        await prefs.setString('lname', finalResult['user']['l_name']);
        await prefs.setString('mobile', finalResult['user']['phone']);
        await prefs.setString('token', finalResult['token']);
        await prefs.setInt('userid', finalResult['user']['id']);

      prefs.setString(AppConstants.userdata, jsonEncode(finalResult['user']));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBarMain()),
            (Route<dynamic> route) => false, // This removes all the previous routes.
      );
        setState(() {
          isLoading = false;
        });

    } else if (response.statusCode == 401) {
      setState(() {
        isLoading = false;
         Fluttertoast.showToast(msg: "Invalid email or password");
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
        Fluttertoast.showToast(msg: "Invalid phone");
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


}

