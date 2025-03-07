import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/model/myrequestmodel.dart';
import 'package:http/http.dart'as http;

import '../helper/api.dart';
import '../helper/session.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MyRequestList();
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate a network call
    setState(() {
      MyRequestList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Requests"),
      ),

      body: RefreshIndicator(
        onRefresh: refresh,
        child: Column(
          children: [
            const SizedBox(height: 10,),
            loading ? const Center(child: CircularProgressIndicator(color: MyColor.primary,)) : myRequestModel?.data?.length == 0 ? const Center(child: Text("No Requests")) :
            Expanded(
              child: ListView.builder(
                  itemCount: myRequestModel?.data?.length??0,
                  itemBuilder: (context,index){
                    var myrequest = myRequestModel?.data?[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MyColor.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12,
                                blurRadius: 2,spreadRadius: 3),
                          ],

                        ),
                        child:  Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                foregroundImage: NetworkImage(myrequest!.user!.image.toString()),
                                radius: 30,
                              ),
                            ),
                             Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text("${myrequest.user!.fName.toString()} ${myrequest.user!.lName.toString()}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                // Text("Lorem Ipsum dolor emit",style: TextStyle(fontSize: 15,),),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap:(){
                                        acceptRequest("1", myrequest.id.toString(),index);
                                        setState(() {
                                          MyRequestList();
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 5.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: MyColor.primary
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                                            child: Text("Accept",style: TextStyle(color: MyColor.white,fontWeight: FontWeight.bold),),
                                          ),
                                        ),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap:(){
                                        acceptRequest("2", myrequest.id.toString(), index);
                                        setState(() {
                                          MyRequestList();
                                        });
                                          },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: MyColor.secondary
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                                            child: Text("Delete",style: TextStyle(color: MyColor.white,fontWeight: FontWeight.bold),),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  }),
            )


          ],
        ),
      ),
    );
  }



  bool isNetwork = false;
  bool loading = true;
  MyRequestModel? myRequestModel;
  MyRequestList() async {
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
      var request = http.Request('GET', Uri.parse(AppUrl.myRequest));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Convert the response to a string and parse it
        final responseBody = await response.stream.bytesToString();
        final parsedJson = jsonDecode(responseBody);

        setState(() {
          myRequestModel = MyRequestModel.fromJson(parsedJson);
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


  bool isLoading = false;
  bool isNetwork1 = false;

  acceptRequest(String status,String userid, int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mytoken = prefs.getString('token');

    // isNetwork1 = await isNetworkAvailable();

    // if (isNetwork1) {
    setState(() {isLoading = true;});
    var headers = {
      'Authorization': 'Bearer $mytoken'
    };
    var request = http.MultipartRequest('POST', Uri.parse(AppUrl.updateRequest));
    request.fields.addAll({
      'id': userid,
      'status': status,

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
        myRequestModel?.data?.removeAt(index);
        setState(() {
          Fluttertoast.showToast(msg: "${finalResult['message']}");
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
