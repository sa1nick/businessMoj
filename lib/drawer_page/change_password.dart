import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import '../helper/api.dart';
import '../helper/colors.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passController = TextEditingController();
  TextEditingController _confirmpassController = TextEditingController();
  bool _obscureText = true;
  bool _obscureText2 = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),
      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.only(bottom: 20.0,right: 10,left: 10),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate() && _passController.text == _confirmpassController.text) {
              update();
            }
            else if(_passController.text != _confirmpassController.text){
              Fluttertoast.showToast(msg: "Password doesn\'t match");
            }
          },
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: MyColor.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Center(
                child:
                !isLoading
                    ?
                const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: MyColor.white,
                  ),
                )
                  : const CircularProgressIndicator(
                color: MyColor.white,
              )
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              // Create Password Field
              TextFormField(
                controller: _passController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor:MyColor.secondaryLight,
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
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a password';
                  }
                  else if (value!.length < 8) {
                    return 'Password is too short';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 20,
              ),


              TextFormField(
                controller: _confirmpassController,
                keyboardType: TextInputType.number,
                obscureText: _obscureText2,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a password';
                  }
                  else if (value!.length < 8) {
                    return 'Password is too short';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  isDense: true,
                  fillColor: MyColor.secondaryLight,
                  hintText: 'Confirm Password',
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText2 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText2 = !_obscureText2;
                      });
                    },
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
  bool isLoading = false;
  bool isNetwork1 = false;

  update() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mytoken = prefs.getString('token');

    // isNetwork1 = await isNetworkAvailable();

    // if (isNetwork1) {
    setState(() {
      isLoading = true;
    });
    var headers = {
      'Authorization': 'Bearer $mytoken'
    };
    var request = http.MultipartRequest('POST', Uri.parse(AppUrl.updateProfile));
    request.fields.addAll({
      'password': _passController.text,
    });

    request.headers.addAll(headers);

    if (kDebugMode) {
      print(request.fields);
    }
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      if (finalResult['status'] == false) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "${finalResult['message']}");
      } else {
        setState(() {
          Fluttertoast.showToast(msg: "${finalResult['message']}");
        });
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
      }
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
      });
      var result = await response.stream.bytesToString();
      var finalResult = jsonDecode(result);
      Fluttertoast.showToast(msg: "${finalResult['message']}");
    } else {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
    // } else {
    //    Fluttertoast.showToast(msg: "No internet");
    // }
  }
}
