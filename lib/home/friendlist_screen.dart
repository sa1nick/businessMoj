import 'dart:convert';
import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/chat/add_group.dart';
import 'package:ut_messenger/chat/chat_page.dart';
import 'package:ut_messenger/chat/group_page.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/model/contact_model.dart';
import 'package:ut_messenger/model/friendmodel.dart';
import 'package:http/http.dart' as http;
import 'package:ut_messenger/widgets/networkimage.dart';

import '../helper/api.dart';
import '../helper/session.dart';
import '../model/chatlist_model.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen(
      {super.key,
      this.fromGroup,
      this.fromGroupDetail,
      this.fromBroadcast,
      this.chatroom});

  final bool? fromGroup;
  final bool? fromGroupDetail;
  final bool? fromBroadcast;
  final List<Chatroom>? chatroom;

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  TextEditingController searchController = TextEditingController();
  int? vId;
  String? token;

  bool isNetwork = false;
  bool loading = false;
  List<Contact>? _contacts;
  List<MyContactModel> myContactsList = [];
  List<MyContactModel> mygropuList = [];
  SharedPreferences? prefs;

  ///for many bool variable handle in one variable
  bool isSelectable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///for many bool variable handle in one variable
    isSelectable = (widget.fromGroup ?? false) ||
        (widget.fromGroupDetail ?? false) ||
        (widget.fromBroadcast ?? false);
    info();
  }

  info() async {
    prefs = await SharedPreferences.getInstance();
    vId = prefs?.getInt('userid') ?? 0;
    token = prefs?.getString('token') ?? '';

    String? contact = prefs?.getString(AppConstants.myContact);

    if (contact != null && contact != '[]') {
      var data = jsonDecode(contact);
      myContactsList = (data as List)
          .map(
            (e) => MyContactModel.fromJson(e),
          )
          .toList();
      tempList = myContactsList;
      setState(() {});
    } else {
      contactPermission();
    }

    print("userId: $vId");
  }

  Future<void> refresh() async {
    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulate a network call
    setState(() {
      contactPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.white,
      floatingActionButton: isSelectable
          ? FloatingActionButton(
              backgroundColor: MyColor.primary,
              child: const Icon(
                Icons.arrow_forward,
                color: MyColor.white,
              ),
              onPressed: () {
                if (widget.fromGroup ?? false) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddGroupScreen(
                          groupMembers: mygropuList,
                        ),
                      ));
                } else if (widget.fromBroadcast ?? false) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddGroupScreen(
                          groupMembers: mygropuList,
                          fromBroadCast: true,
                        ),
                      ));
                } else {
                  Navigator.pop(context, mygropuList);
                }
              },
            )
          : /*const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Powered by @ NAVGURU WELLNESS PVT LTD',textAlign: TextAlign.center,style: TextStyle(color: MyColor.primary),)
        ],)*/
          const SizedBox(),
      //floatingActionButtonLocation: isSelectable ? null :FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        centerTitle:
            !((widget.fromGroup ?? false) || (widget.fromBroadcast ?? false)),
        automaticallyImplyLeading:
            (widget.fromGroup ?? false) || (widget.fromBroadcast ?? false),
        title: (widget.fromGroup ?? false) || (widget.fromBroadcast ?? false)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fromBroadcast == true
                        ? "New Broadcast"
                        : "New Group",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    "Add member",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              )
            : const Text("Contacts"),
        actions: const [
          // IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen()));}, icon: Icon(Icons.message))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: MyColor.primary,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: searchController,
                readOnly: false,
                onChanged: (value) {
                  searchMock(value);
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
                : myContactsList.isEmpty
                    ? const Expanded(child: Center(child: Text("No Friends")))
                    : Expanded(
                        child: ListView.builder(
                            itemCount: myContactsList.length,
                            itemBuilder: (context, index) {

                              var friend = myContactsList[index];

                              return vId == myContactsList[index].id
                                  ? const SizedBox()
                                  : InkWell(
                                      onTap: isSelectable
                                          ? () {

                                        if(widget.chatroom?.any((element) => element.userId == myContactsList[index].id) ?? false)
                                          {
                                         Fluttertoast.showToast(msg: 'User already added in this group');
                                          }
                                         else{
                                          friend.isSelected =
                                          !(friend.isSelected ?? false);

                                          if (friend.isSelected ?? false) {
                                            mygropuList.add(friend);
                                          } else {
                                            mygropuList.remove(friend);

                                          }

                                          setState(() {});
                                          print('_____________');
                                        }
                                            }
                                          : () {},
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: MyColor.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 2,
                                                  spreadRadius: 3),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: InkWell(
                                                    onTap: isSelectable
                                                        ? () {
                                                            friend.isSelected =
                                                                !(friend.isSelected ??
                                                                    false);

                                                            if (friend
                                                                    .isSelected ??
                                                                false) {
                                                              mygropuList
                                                                  .add(friend);
                                                            } else {
                                                              mygropuList
                                                                  .remove(
                                                                      friend);
                                                              ;
                                                            }

                                                            setState(() {});
                                                            print(
                                                                '_____________');
                                                          }
                                                        : () {},
                                                    child: Stack(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 30,
                                                          child: ClipOval(
                                                            child: AppImage(
                                                              image: friend
                                                                      .image ??
                                                                  '',
                                                            ),
                                                          ),
                                                        ),
                                                        isSelectable &&
                                                                (friend.isSelected ??
                                                                    false)
                                                            ? Positioned(
                                                                bottom: 0,
                                                                right: 0,
                                                                child:
                                                                    Container(
                                                                  height: 20,
                                                                  width: 20,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: MyColor
                                                                        .green,
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons.check,
                                                                    color: MyColor
                                                                        .black,
                                                                    size: 20,
                                                                  ),
                                                                ))
                                                            : const SizedBox()
                                                      ],
                                                    ),
                                                  )),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      friend.name == ''
                                                          ? 'Unknown'
                                                          : friend.name ??
                                                              'Unknown',
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      friend.phone ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              isSelectable
                                                  ? const SizedBox()
                                                  : Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (friend
                                                                    .imblocked ??
                                                                false) {
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          '${friend.name} has blocked you.');
                                                            } else {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          GroupPage(
                                                                            name:
                                                                                friend.name.toString(),
                                                                            image:
                                                                                friend.image.toString(),
                                                                            friendId:
                                                                                friend.id.toString(),
                                                                            myRoomId:
                                                                                friend.roomId,
                                                                            isBlock:
                                                                                friend.isBlocked,
                                                                          ))).then(
                                                                (value) {
                                                                  contactPermission();
                                                                },
                                                              );
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color: MyColor
                                                                      .primary),
                                                              child:
                                                                  const Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20.0,
                                                                        vertical:
                                                                            5),
                                                                child: Text(
                                                                  "Chat",
                                                                  style: TextStyle(
                                                                      color: MyColor
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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

  // final FlutterContactPicker _contactPicker =  FlutterContactPicker();

  myContacts(List<String> contact) async {
    // Check network availability
    isNetwork = await isNetworkAvailable();

    // if (isNetwork) {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      http.Response response = await http.post(Uri.parse(AppUrl.friendList),
          body: {"list": contact.join(',')}, headers: headers);

      print(contact.join(','));

      log(token!);

      if (response.statusCode == 200) {
        print('${response.body}');

        prefs?.setString(AppConstants.myContact, response.body);

        var data = jsonDecode(response.body);
        myContactsList = (data as List)
            .map(
              (e) => MyContactModel.fromJson(e),
            )
            .toList();

        tempList = myContactsList;
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load profile");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }

    setState(() {
      loading = false;
    });
  }

  Future<List<Contact>?> contactPermission() async {
    setState(() {
      loading = true;
    });

    if (await Permission.contacts.request().isGranted) {
      // Fetch contacts from the device
      Iterable<Contact> contacts = await ContactsService.getContacts();

      _contacts = contacts.toList();

      List<String> phoneNumbers = contacts
          .where((contact) => contact.phones != null)
          .expand((contact) => contact.phones!)
          .map((phone) => normalizePhoneNumber(phone.value!))
          .toList();

      myContacts(phoneNumbers);
    }
  }

  bool isLoading = false;

  String normalizePhoneNumber(String phoneNumber) {
    // Remove non-digit characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Remove leading '+' if present
    if (phoneNumber.startsWith('+')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Remove country code '91' if present
    if (phoneNumber.startsWith('91') && phoneNumber.length > 10) {
      phoneNumber = phoneNumber.substring(2);
    }

    // Remove leading '0' if present
    if (phoneNumber.startsWith('0') && phoneNumber.length > 10) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Ensure the number is exactly 10 digits
    if (phoneNumber.length == 10 && RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      return phoneNumber;
    }

    // Return empty string for invalid numbers
    return '';
  }

  List<MyContactModel> tempList = [];

  searchMock(String value) {
    final suggestions = tempList.where((element) {
      final username = element.name?.toLowerCase();
      String? description = element.phone?.toLowerCase();
      final input = value.toLowerCase();

      return username!.contains(input) || description!.contains(input);
      /*||  firmName!.contains(input)*/ /* || mobile.contains(input) ||  firmName.contains(input)*/;
    }).toList();
    myContactsList = suggestions;
    setState(() {});

    // update();
  }
}
