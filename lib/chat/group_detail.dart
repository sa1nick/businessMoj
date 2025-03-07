import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/friendlist_screen.dart';
import 'package:ut_messenger/home/home_screen.dart';
import 'package:ut_messenger/model/contact_model.dart';
import 'package:ut_messenger/model/usermodel.dart';
import 'package:ut_messenger/widgets/networkimage.dart';

import '../helper/api.dart';
import '../helper/global.dart';
import '../home/bottom_navbar.dart';
import '../model/chatlist_model.dart';
import '../widgets/logout_dialog.dart';
import 'add_group.dart';
import 'package:http/http.dart' as http;

class GroupDetailScreen extends StatefulWidget {
    GroupDetailScreen({super.key, this.chatListData, this.fromBroadcast});

  ChatListData? chatListData;
  final bool? fromBroadcast ;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final nameC = TextEditingController();
  final descriptionC = TextEditingController();
  SharedPreferences? pref;
  String? token;
  UserData? userData;

  bool isLoading = false;

  bool isUpdating = false;
  bool isAdmin = false;

  bool? onlyAdminCanSendMessage;

  Function? dialogSetState;
  Chatroom? chatRoomData ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: MyColor.primary,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      color: MyColor.black,
                      child: widget.fromBroadcast ?? false ? Center(child: Image.asset('assets/images/Loud_Speaker.png')) : AppImage(
                          image: widget.chatListData?.imageUrl ?? '',
                          width: MediaQuery.of(context).size.width),
                    ),
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      color: MyColor.black.withOpacity(0.5),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    // Positioned(
                    //   top: 40,
                    //   right: 50,
                    //   child: IconButton(
                    //     icon: const Icon(Icons.person, color: Colors.white),
                    //     onPressed: () {},
                    //   ),
                    // ),
                    widget.fromBroadcast==true ?  SizedBox()  :     Positioned(
                      top: 40,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.exit_to_app, color: Colors.white),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => DeleteAccountDialog(
                                heading: 'Exit Group',
                                title: 'Do you really want to exit this group ?',
                                onTab: () async{
                                  SharedPreferences pref = await SharedPreferences.getInstance();

                                  var userString = pref.getString(AppConstants.userdata);

                                  String? token = pref?.getString('token');

                                  userData = UserData.fromJson(jsonDecode(userString!));

                                 String currentuser = userData?.id.toString() ?? '';
                                  removeGroupMember(currentuser).then((value) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const BottomNavBarMain()));
                                  },);
                                  // deleteAccount ();

                                },));
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatListData?.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                           Text(
                            'Created by ${isAdmin ? 'You' : chatRoomData?.user?.name ?? ''}, ${DateFormat('MMM dd yyyy').format(DateTime.parse(chatRoomData?.createdAt ?? DateTime.now().toString()))}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return updateTitleAndDescription();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  color: MyColor.white.withOpacity(0.2),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MyColor.primary,
                            fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.chatListData?.description ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Colors.grey),

                // Participants section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${widget.chatListData?.chatroom?.length} participants',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: MyColor.primary,
                    child: Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: const Text('Add participants'),
                  onTap: () {

                    Navigator.push(context, MaterialPageRoute(builder: (context) => FriendListScreen(fromGroupDetail: true,chatroom: widget.chatListData?.chatroom,),)).then((value) {

                      if(value !=null)
                        {
                          List<MyContactModel> myGropuList = value ;
                          addGroupMember(myGropuList.map((e) => e.id.toString(),).toList().join(','));
                        }


                    },);

                  },
                ),

                Expanded(
                    child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.chatListData?.chatroom?.length ?? 0,
                  itemBuilder: (context, index) {
                    var data = widget.chatListData?.chatroom![index];

                    return  data?.user?.id == userData?.id && isAdmin && (widget.fromBroadcast ?? false) ? const SizedBox() : ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: ClipOval(
                          child: AppImage(
                            image: '${AppUrl.profileURL}${data?.user?.image}',
                          ),
                        ),
                      ),
                      title: Text( data?.user?.fName != '' ?  '${data?.user?.fName}' : 'Unknown'),
                      subtitle: Text( isAdmin ? '${data?.user?.phone}' : ''),
                      onTap: () {},
                      onLongPress: data?.user?.id != userData?.id && isAdmin ?  ()  {

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return confirmDialog(
                                data?.user?.id.toString() ?? '', index);
                          },
                        );
                      }
                      : null,
                      trailing: data!.isAdmin == 0 ? const SizedBox() :Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                        decoration: BoxDecoration(
                            border: Border.all(color: MyColor.primary),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Admin'),
                      ),
                    );
                  },
                ))
              ],
            ),
    );
  }

  Widget confirmDialog(String userid, int index) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Confirm Action',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('Do you want to remove this user?'),
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
            Navigator.of(context).pop();
            widget.chatListData?.chatroom!.removeAt(index);
            setState(() {});
            removeGroupMember(userid);
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

  Widget updateTitleAndDescription() {
    nameC.text = widget.chatListData?.title ?? '';
    descriptionC.text = widget.chatListData?.description ?? '';
    String imageUrl = widget.chatListData?.imageUrl ?? '';

    return StatefulBuilder(
      builder: (context, dialogSate) {
        dialogSetState = dialogSate;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title:  Text(
            widget.fromBroadcast ?? true ?  'Update Group' : 'Update Broadcast',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              children: [
                // Group Icon
                widget.fromBroadcast ?? false ? const SizedBox() :GestureDetector(
                  onTap: () async {
                    image = await getLostData(ImageSource.gallery);
                    dialogSate(() {});
                    // Add functionality to change group icon
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      clipBehavior: Clip.hardEdge,
                      child: image == null
                          ? imageUrl == '' || imageUrl == null
                              ? Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[700],
                                )
                              : AppImage(image: imageUrl)
                          : Image.file(
                              image!,
                              fit: BoxFit.fill,
                              height: 60,
                              width: 60,
                            ),
                    ),
                  ),
                ),
                widget.fromBroadcast ?? false ? const SizedBox() : const SizedBox(width: 16),
                // Group Name Input
                Expanded(
                  child: TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      hintText: 'Group name',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              minLines: 3,
              // Set this
              maxLines: 6,
              // and this
              controller: descriptionC,
              keyboardType: TextInputType.multiline,
              cursorColor: MyColor.black,
              decoration: InputDecoration(
                hintText: 'Write a group description(Optional)',
                filled: true,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
                fillColor: MyColor.primary.withOpacity(0.2),
              ),
            ),
            isAdmin ?  Row(children: [
              Checkbox(
                value: onlyAdminCanSendMessage, onChanged: (value){

                onlyAdminCanSendMessage = value ;

                dialogSate((){});

              },activeColor: MyColor.primary,),
              const Text(
                'Only admin can send message*' ,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],) : const SizedBox(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                updateGroupDetail();
                // Perform action and close dialog
              },
              child: isUpdating
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: MyColor.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        );
      },
    );
  }

  init() async {
    pref = await SharedPreferences.getInstance();

    token = pref?.getString(AppConstants.token);
    String? userString = pref?.getString(AppConstants.userdata);

    if (userString != null) {
      userData = UserData.fromJson(jsonDecode(userString));
    }
    getGroupDetail();
  }

  Future<void> updateGroupDetail() async {
    isUpdating = true;
    dialogSetState!(() {});

    var headers = {'Authorization': 'Bearer $token'};
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.updateChatGroup));
    request.fields.addAll({
      'group_id': widget.chatListData?.id.toString() ?? '',
      'group_name': nameC.text,
      'group_description': descriptionC.text,
      'chat_access_group': onlyAdminCanSendMessage ?? false ? '1' :'2'
    });

    if (image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', image!.path));
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var result = await response.stream.bytesToString();

      var finalResult = jsonDecode(result);
      Navigator.of(context).pop();

      Fluttertoast.showToast(msg: '${finalResult['message']}');
      getGroupDetail();
    } else {
      print(response.reasonPhrase);
    }

    isUpdating = false;
    dialogSetState!(() {});
  }

  Future<void> removeGroupMember(String userid) async {
    try {
        var headers = {'Authorization': 'Bearer $token'};
        var body = {
          'group_id': widget.chatListData?.id.toString(),
          'user_id': userid
        };
        http.Response response = await http.post(Uri.parse(AppUrl.removeChatUser),
            headers: headers, body: body);

      print('${body}_______');
      print('${response.body}_______');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        Fluttertoast.showToast(msg: data['message']);
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load plans");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

  Future<void> getGroupDetail() async {
    setState(() {
      isLoading = true;
    });



    try {
      var headers = {'Authorization': 'Bearer $token'};

      http.Response response = await http.get(
          Uri.parse(
              '${AppUrl.myChatList}/${widget.chatListData?.id.toString()}'),
          headers: headers);
      
      print('${widget.chatListData?.id}____________fsdfd');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        widget.chatListData = MyChatListModel.fromJson(data).data?.first;

        widget.chatListData?.chatroom?.forEach((element) {

          if(element.isAdmin == 1){
            chatRoomData = element ;
          }

          if(element.user?.id == userData?.id && element.isAdmin == 1){
            isAdmin = true ;
          }
        },);

        onlyAdminCanSendMessage = widget.chatListData?.chatAccessGroup == 1 ;

        setState(() {});
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load plans");
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

  Future<void> addGroupMember(String userid) async {
    try {
      var headers = {'Authorization': 'Bearer $token'};
      var body = {
        'group_id': widget.chatListData?.id.toString(),
        'user_id': userid
      };
      http.Response response = await http.post(Uri.parse(AppUrl.addChatUser),
          headers: headers, body: body);


      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        getGroupDetail();

        Fluttertoast.showToast(msg: data['message']);
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to load plans");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

}
