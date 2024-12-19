import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/auth/login_screen.dart';
import 'package:ut_messenger/chat/broadcast_page.dart';
import 'package:ut_messenger/chat/group_page.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/chat_screen.dart';
import 'package:ut_messenger/home/friendlist_screen.dart';
import 'package:ut_messenger/home/request_screen.dart';
import 'package:ut_messenger/home/search_screen.dart';
import 'package:ut_messenger/home/settings.dart';
import 'package:ut_messenger/home/test_page.dart';
import 'package:ut_messenger/model/chatlist_model.dart';
import 'package:ut_messenger/model/usermodel.dart';
import 'package:http/http.dart' as http;
import 'package:ut_messenger/voicecall/voice_call.dart';
import 'package:ut_messenger/widgets/logout_dialog.dart';
import 'package:ut_messenger/widgets/networkimage.dart';

import '../chat/chat_page.dart';
import '../helper/session.dart';
import '../model/getprofile_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  int? vId;

  SharedPreferences? prefs;

  List popupItemsList = [
    {'icon': Icons.group_add_rounded, 'title': 'New Group'},
    {'icon': Icons.broadcast_on_home, 'title': 'New Broadcast'},
    {'icon': Icons.settings, 'title': 'Settings'},
    {'icon': Icons.logout, 'title': 'Logout'},
  ];

  bool isNetwork = false;
  bool loading = true;
  List<ChatListData> myChatList = [];

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    info();
  }

  GetProfileModel? getProfileModel;

  info() async {
    prefs = await SharedPreferences.getInstance();
    String? mytoken = prefs?.getString('token');

    await getProfile(mytoken ?? '');

    vId = getProfileModel?.id;
    print("sajal $vId");

    prefs?.setInt('userid', getProfileModel?.id ?? 0);
    prefs?.setString('fname', getProfileModel?.fName ?? '');
    prefs?.setString('lname', getProfileModel?.lName ?? '');
    prefs?.setString('mobile', getProfileModel?.phone ?? '');

    getUserList();

    // print("token $token");
  }

  Future<void> refresh() async {
    await Future.delayed(
        Duration(milliseconds: 100)); // Simulate a network call
    setState(() {
      getUserList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add People"),
        actions: [
          PopupMenuButton(
            color: MyColor.primary,
            // style: ButtonStyle(backgroundColor: WidgetStateProperty.all(MyColor.primary) ,),
            itemBuilder: (context) {
              return [
                for (int i = 0; i < popupItemsList.length; i++)
                  PopupMenuItem(
                      value: popupItemsList[i]['title'],
                      child: ListTile(
                        onTap: () {
                          if (popupItemsList[i]['title'] == 'New Group') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FriendListScreen(
                                    fromGroup: true,
                                  ),
                                ));
                          } else if (popupItemsList[i]['title'] == 'Settings') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingScreen(),
                                ));
                          } else if (popupItemsList[i]['title'] ==
                              'New Broadcast') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FriendListScreen(
                                    fromBroadcast: true,
                                  ),
                                ));
                          } else {
                            showDialog(
                                context: context,
                                // barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const LogoutDialog();
                                });
                          }
                        },
                        leading: Icon(
                          popupItemsList[i]['icon'],
                          color: MyColor.white,
                        ),
                        title: Text(
                          popupItemsList[i]['title'],
                          style: const TextStyle(
                              color: MyColor.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ))
              ];
            },
          )

          // IconButton(onPressed: (){
          //   Navigator.push(context, MaterialPageRoute(builder: (context)=>const RequestScreen()));
          // }, icon: const Icon(Icons.people_alt_outlined),),

          // IconButton(onPressed: (){
          // //   Navigator.push(context, MaterialPageRoute(builder: (context)=>const TestPage()));
          // }, icon: const Icon(Icons.notification_add),),
        ],
      ),
      body: RefreshIndicator(
        color: MyColor.primary,
        onRefresh: refresh,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: searchController,
                readOnly: true,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchScreen(
                                myChatList: myChatList,
                              )));
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "Search..",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: MyColor.primary,
                    ),
                  )
                : myChatList.isEmpty
                    ? const Center(
                        child: Text('No more chats available'),
                      )
                    : Expanded(
                        child: ListView.builder(
                            itemCount: myChatList.length,
                            itemBuilder: (context, index) {
                              var users = myChatList[index];
                              return users.id == vId
                                  ? const SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 5),
                                      child: InkWell(
                                        onTap: () {
                                          if (users.type == 3) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BroadcastPage(
                                                          name: users.title
                                                              .toString(),
                                                          image: users.imageUrl
                                                              .toString(),
                                                          friendId: users.id
                                                              .toString(),
                                                          chatListData: users,
                                                        )));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupPage(
                                                          name: users.title
                                                              .toString(),
                                                          image: users.imageUrl
                                                              .toString(),
                                                          friendId: users.id
                                                              .toString(),
                                                          chatListData: users,
                                                        )));
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: MyColor.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 2,
                                                  spreadRadius: 2),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor:
                                                      MyColor.greyBorder,
                                                  child: ClipOval(
                                                    child: users.type == 3
                                                        ? Image.asset(
                                                            'assets/images/Loud_Speaker.png')
                                                        : AppImage(
                                                            image: users
                                                                    .imageUrl ??
                                                                ''),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(children: [
                                                      Text(
                                                        chatOrGroupname(users),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      const SizedBox(width: 10,),
                                                      users.unreadCount =='0' ? const SizedBox() :  CircleAvatar(radius: 10,backgroundColor: MyColor.unreadColor1,child: Text('${users.unreadCount}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 12),),),

                                                    ],),
                                                    users.type == 3
                                                        ? SizedBox(
                                                      width: 150,
                                                            child: Text(
                                                                users.chatroom?.map((e) => e
                                                                              .user
                                                                              ?.name,).toList().join(',') ?? '',
                                                                maxLines: 1,
                                                                style:  const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis)),
                                                          )
                                                        : Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                                DateFormat('MMM d, yyyy').format(DateTime.parse(users.createdAt ??
                                                                    '')),
                                                                style: const TextStyle(
                                                                    fontSize: 15,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip),
                                                              ),
                                                            // Container(
                                                            //   padding: EdgeInsets.symmetric(horizontal: 5),
                                                            //   decoration: BoxDecoration(
                                                            //       border: Border.all(color: MyColor.unreadColor1,
                                                            //       ),borderRadius: BorderRadius.circular(5)),
                                                            //   child: const Text('2 pending...',style: TextStyle(fontSize: 12, color: MyColor.black),),
                                                            // )
                                                          ],
                                                        ),
                                                  ],
                                                ),
                                              ),
                                             // const CircleAvatar(radius: 10,backgroundColor: MyColor.unreadColor1,child: Text('2',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 12),),),
                                              const SizedBox(width: 20,)

                                            ],
                                          ),
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

  String chatOrGroupname(ChatListData chat) {
    if (chat.type == 1 && chat.chatroom?.length == 2) {


     List <Chatroom>? otherUser = chat.chatroom?.where((element) {
        return element.user?.id != vId;}).toList();

        if(otherUser?.isNotEmpty ?? false) {
          return '"${otherUser?.first.user?.fName} ${otherUser?.first.user?.lName.toString()}"';
        }else {
          return '';
        }

     // return "${otherUser?.user?.fName} ${otherUser?.user?.lName.toString()}";
    } else {
      return '${chat.title}';
    }
  }

  Future<void> getProfile(String mytoken) async {
    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      var headers = {'Authorization': 'Bearer $mytoken'};
      var request = http.Request('GET', Uri.parse(AppUrl.getProfile));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final parsedJson = jsonDecode(responseBody);

        getProfileModel = GetProfileModel.fromJson(parsedJson);
      } else {
        Fluttertoast.showToast(msg: "Failed to load profile");
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
  }

  Future<void> getUserList() async {
    setState(() {
      loading = true;
    });
    String? token = prefs?.getString('token');

    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      log('${headers}');
      var request = http.Request('GET', Uri.parse(AppUrl.myChatList));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final parsedJson = jsonDecode(responseBody);

        myChatList = MyChatListModel.fromJson(parsedJson).data ?? [];
      } else {
        Fluttertoast.showToast(msg: "Failed to load chat");
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

  bool isLoading = false;
  bool isNetwork1 = false;
  bool status = false;

  Future<void> sendRequest(String userid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mytoken = prefs.getString('token');

    // isNetwork1 = await isNetworkAvailable();

    // if (isNetwork1) {
    setState(() {
      isLoading = true;
    });
    var headers = {'Authorization': 'Bearer $mytoken'};
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
