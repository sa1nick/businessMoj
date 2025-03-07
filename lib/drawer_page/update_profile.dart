import 'dart:convert';
import 'dart:io';

// import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/auth/login_screen.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/colors.dart';

import '../helper/session.dart';
import '../model/getprofile_model.dart';


class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
        title: Text("Update Profile"),
        centerTitle: true,
      ),
      body: loading ? const Center(child: CircularProgressIndicator(color: MyColor.primary,)) : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 15.0, vertical: 5),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,

               children: [
                 const SizedBox(height: 10,),

                 Stack(
                     children:[
                       Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           InkWell(
                             onTap: () {
                               pickImage();
                             },
                             child: CircleAvatar(
                               backgroundColor: MyColor.primary,
                               radius: 55,
                               child: _profileImage != null
                                   ? CircleAvatar(
                                 backgroundImage: FileImage(File(_profileImage!.path)),
                                 radius: 50,
                                 child: const Icon(
                                   Icons.camera_alt_outlined,
                                   size: 35,
                                   color: Colors.grey,
                                 ),
                               )
                                   : CircleAvatar(
                                 backgroundColor: MyColor.white,
                                 backgroundImage: NetworkImage(
                                   getProfileModel!.image!,
                                 ),
                                 radius: 50,
                                 child: const Icon(
                                   Icons.camera_alt_outlined,
                                   size: 35,
                                   color: Colors.grey,
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),]
                 ),




                 // Stack(
                 //   children: [
                 //     Center(
                 //       child: GestureDetector(
                 //         onTap: () {
                 //           setState(() {
                 //             pickImage();
                 //           });
                 //         },
                 //         child: Container(
                 //             height: 100,
                 //             width: 100,
                 //             decoration: BoxDecoration(
                 //               color: MyColor.secondaryLight,
                 //               borderRadius:
                 //               BorderRadius.circular(10),
                 //               border: Border.all(
                 //                   color:
                 //                   MyColor.primary),
                 //             ),
                 //             child:
                 //             getProfileModel?.image !=
                 //                 ""
                 //                 ? ClipRRect(
                 //                 borderRadius:
                 //                 BorderRadius.circular(
                 //                     10),
                 //                 child: Image.network(
                 //                   getProfileModel!.image!,
                 //                   height: 120,
                 //                   width: 120,
                 //                   fit: BoxFit.cover,
                 //                 ))
                 //                 : _profileImage != null
                 //                 ? ClipRRect(
                 //               borderRadius:
                 //               BorderRadius
                 //                   .circular(10),
                 //               child: Image.file(
                 //                 _profileImage!,
                 //                 height: 120,
                 //                 width: 120,
                 //                 fit: BoxFit.cover,
                 //               ),
                 //             )
                 //                 :
                 //             const Column(
                 //               mainAxisAlignment:
                 //               MainAxisAlignment
                 //                   .center,
                 //               children: [
                 //                 Icon(
                 //                   Icons
                 //                       .camera_alt_outlined,
                 //                   color:
                 //                   MyColor
                 //                       .primary,
                 //                 ),
                 //                 Text("Profile Pic"),
                 //               ],
                 //             )),
                 //       ),
                 //     ),
                 //     Padding(
                 //       padding: const EdgeInsets.only(top: 85.0),
                 //       child: Center(
                 //         child: Container(
                 //           height: 25,
                 //           width: 25,
                 //           decoration: const BoxDecoration(
                 //               shape: BoxShape.circle,
                 //               color: MyColor.primary),
                 //           child: const Icon(
                 //             Icons.edit,
                 //             color: MyColor.white,
                 //             size: 20,
                 //           ),
                 //         ),
                 //       ),
                 //     )
                 //   ],
                 // ),

                 const Text("First Name",
                     style: TextStyle(fontSize: 16)),
                 const SizedBox(height: 4),
                 TextFormField(
                   readOnly: false,
                   onChanged: (value) {
                     setState(() {});
                   },
                   controller: _nameController,
                   keyboardType: TextInputType.text,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter your name';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       hintText: 'First Name',
                       hintStyle: TextStyle(
                           color: MyColor.black),
                       filled: true,
                       fillColor: MyColor.secondaryLight,
                       border: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: BorderSide.none),
                       enabledBorder: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: const BorderSide(
                               color: Color(0xffCCCCCC))),
                       focusedBorder: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: const BorderSide(
                               color: MyColor
                                   .primaryMaterial)),
                       enabled: true,
                       suffixIcon:
                       _nameController.text.isNotEmpty
                           ? IconButton(
                         color: MyColor
                             .primaryMaterial,
                         icon: const Icon(Icons.clear,
                             size: 16),
                         onPressed: () {
                           setState(() {
                             _nameController.clear();
                           });
                         },
                       )
                           : null),
                 ),
                 const SizedBox(height: 20),

                 const Text("Last Name",
                     style: TextStyle(fontSize: 16)),
                 const SizedBox(height: 4),
                 TextFormField(
                   readOnly: false,
                   onChanged: (value) {
                     setState(() {});
                   },
                   controller: _lastnameController,
                   keyboardType: TextInputType.text,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter your name';
                     }
                     return null;
                   },
                   decoration: InputDecoration(
                       hintText: 'Last Name',
                       hintStyle: const TextStyle(
                           color: MyColor.black),
                       filled: true,
                       fillColor: MyColor.secondaryLight,
                       border: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: BorderSide.none),
                       enabledBorder: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: const BorderSide(
                               color: Color(0xffCCCCCC))),
                       focusedBorder: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: const BorderSide(
                               color: MyColor
                                   .primaryMaterial)),
                       enabled: true,
                       suffixIcon:
                       _lastnameController.text.isNotEmpty
                           ? IconButton(
                         color: MyColor
                             .primaryMaterial,
                         icon: const Icon(Icons.clear,
                             size: 16),
                         onPressed: () {
                           setState(() {
                             _lastnameController.clear();
                           });
                         },
                       )
                           : null),
                 ),
                 const SizedBox(height: 20),

                 const Text("Email ",
                     style: TextStyle(fontSize: 16)),
                 const SizedBox(height: 4),
                 TextFormField(
                   onChanged: (value) {
                     setState(() {});
                   },
                   controller: _emailController,
                   keyboardType: TextInputType.text,
                   validator: validateEmail,
                   readOnly: getProfileModel!.email?.isEmpty ?? true ?  false : true,
                   decoration: InputDecoration(
                       hintText: 'Email',
                       hintStyle: const TextStyle(
                           color: MyColor.black),
                       filled: true,
                       fillColor: MyColor.secondaryLight,
                       border: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: BorderSide.none),
                       enabledBorder: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: const BorderSide(
                               color: Color(0xffCCCCCC))),
                       focusedBorder: OutlineInputBorder(
                           borderRadius:
                           BorderRadius.circular(8),
                           borderSide: const BorderSide(
                               color: MyColor
                                   .primaryMaterial)),
                       enabled: true,
                       suffixIcon:
                       /*_emailController.text.isNotEmpty*/false
                           ? IconButton(
                         color: MyColor
                             .primaryMaterial,
                         icon: const Icon(Icons.clear,
                             size: 16),
                         onPressed: () {
                           setState(() {
                             _emailController.clear();
                           });
                         },
                       )
                           : null),
                 ),
                 const SizedBox(height: 20),

                 Text("Mobile",
                     style: TextStyle(fontSize: 16)),
                 const SizedBox(height: 4),
                 TextFormField(
                   readOnly: true,
                   onChanged: (value) {
                     setState(() {});
                   },
                   controller: _mobileController,
                   keyboardType: TextInputType.text,
                   decoration: InputDecoration(
                     prefixIcon: const Padding(
                       padding: EdgeInsets.only(
                           left: 15.0, top: 15, bottom: 15),
                       child: Text("+91"),
                     ),
                     hintText: 'Type the Mobile',
                     hintStyle: TextStyle(
                         color: MyColor.black),
                     filled: true,
                     fillColor: MyColor.secondaryLight,
                     border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                         borderSide: BorderSide.none),
                     enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                         borderSide: const BorderSide(
                             color: Color(0xffCCCCCC))),
                     focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                         borderSide: const BorderSide(
                             color: MyColor
                                 .primaryMaterial)),
                     enabled: true,
                     // suffixIcon: _addressController.text.isNotEmpty ? IconButton(
                     //   color: ColorResources.primaryMaterial,
                     //   icon: const Icon(Icons.clear, size: 16),
                     //   onPressed: () {
                     //     setState(() {
                     //       _addressController.clear();
                     //     });
                     //   },
                     // )
                     //     : null
                   ),
                 ),
                 const SizedBox(height: 20),


                 // const Text("Password",
                 //     style: TextStyle(fontSize: 16)),
                 // const SizedBox(height: 4),
                 // TextFormField(
                 //   onChanged: (value) {
                 //     setState(() {});
                 //   },
                 //   controller: _passController,
                 //   keyboardType: TextInputType.text,
                 //   decoration: InputDecoration(
                 //       hintText: 'Password',
                 //       hintStyle:const TextStyle(
                 //           color: MyColor.black),
                 //       filled: true,
                 //       fillColor: MyColor.secondaryLight,
                 //       border: OutlineInputBorder(
                 //           borderRadius:
                 //           BorderRadius.circular(8),
                 //           borderSide: BorderSide.none),
                 //       enabledBorder: OutlineInputBorder(
                 //           borderRadius:
                 //           BorderRadius.circular(8),
                 //           borderSide: const BorderSide(
                 //               color: Color(0xffCCCCCC))),
                 //       focusedBorder: OutlineInputBorder(
                 //           borderRadius:
                 //           BorderRadius.circular(8),
                 //           borderSide: const BorderSide(
                 //               color: MyColor
                 //                   .primaryMaterial)),
                 //       enabled: true,
                 //       suffixIcon: _passController.text.isNotEmpty
                 //           ? IconButton(
                 //         color: MyColor
                 //             .primaryMaterial,
                 //         icon: const Icon(Icons.clear,
                 //             size: 16),
                 //         onPressed: () {
                 //           setState(() {
                 //             _passController.clear();
                 //           });
                 //         },
                 //       )
                 //           : null),
                 // ),
                 // const SizedBox(height: 20),

               ],
             ),

              const SizedBox(height: 50,),

              // Continue Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        update();
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
              ),

            ],
          ),
        ),
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validating age (positive number)
  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    int? age = int.tryParse(value);
    if (age == null || age <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  bool isNetwork = false;
  bool loading = true;
  GetProfileModel? getProfileModel;


  getUser() async {
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

            _nameController.text = getProfileModel!.fName!;
            _lastnameController.text = getProfileModel!.lName!;
            _emailController.text = getProfileModel!.email!;
            _mobileController.text = getProfileModel!.phone!;
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
        'f_name': _nameController.text,
        'l_name': _lastnameController.text,
        'phone': _mobileController.text,
        'email': _emailController.text,
        // 'password': _passController.text,
      });

      request.headers.addAll(headers);

      print(_profileImage.toString());
      if (_profileImage != null) {
        request.files.add(
          http.MultipartFile(
            'image',
            _profileImage!.readAsBytes().asStream(),
            _profileImage!.lengthSync(),
            filename: path.basename(_profileImage!.path),
            // contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
      if (kDebugMode) {
        print("saaaaaaaaaaaa${_mobileController.text}");
      }
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

  File? _profileImage;

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Restrict to only images
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null) {
        setState(() {
          _profileImage = File(filePath);
        });
      }
    }
  }
}