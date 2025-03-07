import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/chat/group_page.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:http/http.dart'as http;
import 'package:ut_messenger/model/chatlist_model.dart';
import 'package:ut_messenger/widgets/networkimage.dart';

import '../helper/api.dart';
import '../helper/session.dart';
import '../model/usermodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.myChatList});

  final List<ChatListData> myChatList;


  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  int? vId = 0;
  List<ChatListData> userList=[];
  List<ChatListData> tempList=[];



  info() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      vId = prefs.getInt('userid');
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userList = widget.myChatList ;
    tempList = userList;
    info();
  //  getUserList();
  }


  searchMock(String value) {
    final suggestions = tempList.where((element) {
      final username = element.title?.toLowerCase();
      String? description = element.description?.toLowerCase();
      final input = value.toLowerCase();


      return username!.contains(input)  ||  description!.contains(input)  ; /*||  firmName!.contains(input)*//* || mobile.contains(input) ||  firmName.contains(input)*/;
    }).toList();
    userList = suggestions;
    setState(() {

    });

    // update();
  }
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search People'),
        centerTitle: true,
      ),
      body: Padding(
        padding:  const EdgeInsets.all(16.0),
        child: Column(

          children: [
            TextFormField(
              controller: searchController,
              onChanged: (value) {
                searchMock(value);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: userList.length ,
                itemBuilder: (context, index) {
                  return  vId == userList[index].id || userList[index].type ==3 ? const SizedBox() :
                 ListTile(
                  leading:  CircleAvatar(

                    radius: 20,
                    child: ClipOval(child: AppImage(image: userList[index].imageUrl ?? '',),),
                  ),
                  title: Text(userList[index].title ?? ''),
                  trailing: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColor.primary
                      ),
                      child:  GestureDetector(
                        onTap:  () async {

                          if(userList[index].type == 1 && (userList[index].isBlocked ?? false)) {
                            Fluttertoast.showToast(msg: '${userList[index].title} has blocked you.');
                          }else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => GroupPage(
                                                    name: userList[index]
                                                        .title
                                                        .toString(),
                                                    image: userList[index]
                                                        .imageUrl
                                                        .toString(),
                                                    friendId: userList[index]
                                                        .id
                                                        .toString(),
                                                    chatListData:
                                                        userList[index],
                                                  )));
                                    }
                                  },
                        child:  const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 5),
                          child: Text("Chat",style: TextStyle(color: MyColor.white,fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ),
                  ),
                );
              },),
            )
          ],
        )

      ),
    );
  }



  bool isNetwork = false;
  bool loading = true;
  UserModel? userModel;



  /*getUserList() async {
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
      var request = http.Request('GET', Uri.parse(AppUrl.myChatList));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Convert the response to a string and parse it
        final responseBody = await response.stream.bytesToString();
        final parsedJson = jsonDecode(responseBody);

        userList = MyChatListModel.fromJson(parsedJson).data ?? [];

      } else {

        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load contact");
      }
      setState(() {
        loading = false;
      });
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
  }*/



  bool isLoading = false;
  bool isNetwork1 = false;
  bool status = false;

  sendRequest(String userid) async {
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
    var request = http.MultipartRequest('POST', Uri.parse(AppUrl.sendRequest));
    request.fields.addAll({
      'friend_id': userid,

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
          status = false;
          isLoading = false;
        });

        Fluttertoast.showToast(msg: "${finalResult['message']}");
      } else {
        setState(() {
          status = true;
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
