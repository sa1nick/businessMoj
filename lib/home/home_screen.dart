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
  const HomeScreen({super.key, this.fromChat});

  final bool? fromChat;

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

  bool isLoading = false;
  bool isNetwork1 = false;
  bool status = false;

  ///for forward message
  List<ChatListData> selectedChat = [];

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

    getChatList();

    // print("token $token");
  }

  Future<void> refresh() async {
    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate a network call
    setState(() {
      getChatList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chats"),
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
      /*floatingActionButton: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Powered by @ NAVGURU WELLNESS PVT LTD',textAlign: TextAlign.center,style: TextStyle(color: MyColor.primary),)
        ],),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,*/
      bottomNavigationBar: selectedChat.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Container(
                height: 50,
                padding: const EdgeInsets.only(left: 10, right: 10),
                width: MediaQuery.of(context).size.width,
                color: MyColor.primary.withOpacity(0.2),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            selectedChat.length,
                            (index) {
                              return Text(
                                '${selectedChat[index].title}, ',
                                style: const TextStyle(
                                    color: MyColor.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, selectedChat);
                      },
                      child: const CircleAvatar(
                        backgroundColor: MyColor.primary,
                        radius: 20,
                        child: Icon(
                          Icons.send,
                          size: 19,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          : const SizedBox(),
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
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: MyColor.primary,
                      ),
                    ),
                  )
                : myChatList.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text('No more chats available'),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                            itemCount: myChatList.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              var users = myChatList[index];
                              return users.id == vId
                                  ? const SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 5),
                                      child: InkWell(
                                        onTap: widget.fromChat != null
                                            ? () {
                                                if (selectedChat.length < 5) {
                                                  if (selectedChat
                                                      .contains(users)) {
                                                    selectedChat.remove(
                                                        users); // Unselect if already selected
                                                  } else {
                                                    selectedChat.add(
                                                        users); // Add to selection
                                                  }

                                                  setState(() {});
                                                } else if (selectedChat
                                                    .contains(users)) {
                                                  selectedChat.remove(users);
                                                  setState(() {});
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Only 5 item can be selected at a time');
                                                }
                                              }
                                            : () {
                                                if (users.type == 3) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              BroadcastPage(
                                                                name: users
                                                                    .title
                                                                    .toString(),
                                                                image: users
                                                                    .imageUrl
                                                                    .toString(),
                                                                friendId: users
                                                                    .id
                                                                    .toString(),
                                                                chatListData:
                                                                    users,
                                                              )));
                                                } else if (users.type == 1 &&
                                                    (users.imblocked ??
                                                        false)) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          '${users.title} has blocked you.');
                                                } else {
                                                  print('title--->${users.title.toString()}');
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              GroupPage(
                                                                name: users
                                                                    .title
                                                                    .toString(),
                                                                image: users
                                                                    .imageUrl
                                                                    .toString(),
                                                                friendId: users
                                                                    .id
                                                                    .toString(),
                                                                chatListData:
                                                                    users,
                                                              ))).then(
                                                    (value) {
                                                      if (value != null) {
                                                        getChatList();
                                                      }
                                                    },
                                                  );
                                                }
                                              },
                                        onLongPress: widget.fromChat == null
                                            ? () {
                                                if (users.type == 1 ||
                                                    users.createdBy == null) {
                                                } else if (users.createdBy !=
                                                        null &&
                                                    users.createdBy == vId) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return confirmDialog(
                                                          users.id.toString(),
                                                          index);
                                                    },
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Only admin can delete the chat');
                                                }
                                              }
                                            : null,
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
                                              Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
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
                                                  selectedChat.contains(users)
                                                      ? Positioned(
                                                          bottom: 10,
                                                          right: 5,
                                                          child: Container(
                                                            height: 20,
                                                            width: 20,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: MyColor
                                                                  .primary,
                                                            ),
                                                            child: const Icon(
                                                              Icons.check,
                                                              color:
                                                                  MyColor.white,
                                                              size: 20,
                                                            ),
                                                          ))
                                                      : const SizedBox()
                                                ],
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          users.title ??
                                                              'Unknown', //chatOrGroupname(users)
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        users.unreadCount == '0'
                                                            ? const SizedBox()
                                                            : CircleAvatar(
                                                                radius: 10,
                                                                backgroundColor:
                                                                    MyColor
                                                                        .unreadColor1,
                                                                child: Text(
                                                                  '${users.unreadCount}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                    users.type == 3
                                                        ? SizedBox(
                                                            width: 150,
                                                            child: Text(
                                                                users.chatroom
                                                                        ?.map(
                                                                          (e) => e
                                                                              .user
                                                                              ?.name,
                                                                        )
                                                                        .toList()
                                                                        .join(
                                                                            ',') ??
                                                                    '',
                                                                maxLines: 1,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis)),
                                                          )
                                                        : users.lastUnreadDate
                                                                    ?.isNotEmpty ??
                                                                false
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    calculateTimeDifference(DateTime.parse(
                                                                        users.lastUnreadDate ??
                                                                            '')),
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        overflow:
                                                                            TextOverflow.clip),
                                                                  ),
                                                                  // Container(
                                                                  //   padding: EdgeInsets.symmetric(horizontal: 5),
                                                                  //   decoration: BoxDecoration(
                                                                  //       border: Border.all(color: MyColor.unreadColor1,
                                                                  //       ),borderRadius: BorderRadius.circular(5)),
                                                                  //   child: const Text('2 pending...',style: TextStyle(fontSize: 12, color: MyColor.black),),
                                                                  // )
                                                                ],
                                                              )
                                                            : const SizedBox(),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              )
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
      List<Chatroom>? otherUser = chat.chatroom?.where((element) {
        return element.user?.id != vId;
      }).toList();

      if (otherUser?.isNotEmpty ?? false) {
        if (otherUser?.first.user?.fName == '') {
          return 'Unknown';
        } else {
          return '${otherUser?.first.user?.fName} ${otherUser?.first.user?.lName.toString()}';
        }
      } else {
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

  String calculateTimeDifference(DateTime pastTime) {
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(pastTime);

    int minutes = difference.inMinutes;
    int hours = difference.inHours;
    int days = difference.inDays;
    int weeks = (days / 7).floor();
    int months = (days / 30).floor(); // Approximate month length

    if (minutes < 60) {
      if (minutes == 0) {
        return 'now';
      }
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (hours < 24) {
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else if (days < 7) {
      return '$days day${days == 1 ? '' : 's'} ago';
    } else if (weeks < 4) {
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else {
      return '$months month${months == 1 ? '' : 's'} ago';
    }
  }

  Future<void> getChatList() async {
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
        // List<ChatListData> temp = MyChatListModel.fromJson(parsedJson).data ?? [];

        myChatList = MyChatListModel.fromJson(parsedJson).data ?? [];

        myChatList.sort((a, b) => DateTime.parse(
                b.lastUnreadDate ?? DateTime.now().toString())
            .compareTo(
                DateTime.parse(a.lastUnreadDate ?? DateTime.now().toString())));
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

  Future<void> deleteGroupOrBroadCast(String groupId, int index) async {
    String? token = prefs?.getString('token');

    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      var body = {
        'group_id': groupId,
      };
      http.Response response = await http.post(Uri.parse(AppUrl.deleteGroup),
          headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final parsedJson = jsonDecode(responseBody);
        Fluttertoast.showToast(msg: parsedJson['message']);
        myChatList.removeAt(index);

        setState(() {});
        Navigator.of(context).pop();
        getChatList();
      } else {
        Fluttertoast.showToast(msg: "Failed to delete chat");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

  Widget confirmDialog(String groupId, int index) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Confirm Action',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('Do you want to remove this chat?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text(
            'No',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColor.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            deleteGroupOrBroadCast(groupId, index);
            // Perform action and close dialog
          },
          child: const Text(
            'Yes',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
