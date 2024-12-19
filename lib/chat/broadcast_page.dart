import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/model/message_model.dart';
import 'package:ut_messenger/model/usermodel.dart';
import 'package:ut_messenger/widgets/networkimage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/chatlist_model.dart';
import 'group_detail.dart';

class BroadcastPage extends StatefulWidget {
  final String name, image, friendId;

  final ChatListData? chatListData ;

  const BroadcastPage(
      {super.key,
        required this.name,
        required this.image,
        this.chatListData,
        required this.friendId});

  @override
  _BroadcastPageState createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  File? imagefile, anyfile;

  bool isTyping = false;

  Future<void> pickfiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Restrict to only images
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null) {
        anyfile = File(filePath);

        String base64Image = base64Encode(anyfile!.readAsBytesSync());

        channel.sink.add(jsonEncode({
          'type': 'file',
          "user_type": 'user',
          "sender": currentuser,
          "receiver_user": widget.friendId,
          "fileName": anyfile?.path.split('/').last,
          "fileData": base64Image,
          'room_id': widget.chatListData?.id.toString()
        }));
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
    );

    if (pickedFile != null) {
      imagefile = File(pickedFile.path);

      String base64Image = base64Encode(imagefile!.readAsBytesSync());

      channel.sink.add(jsonEncode({
        'type': 'file',
        "user_type": 'user',
        "sender": currentuser,
        "receiver_user": widget.friendId,
        "fileName": imagefile?.path.split('/').last,
        "fileData": base64Image,
        'room_id': widget.chatListData?.id.toString()
      }));
    }
  }



  ScrollController scrollController = ScrollController();

  final TextEditingController messageController = TextEditingController();

  String? currentuser;
  UserData ? userData ;

  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://chat-application.alphawizzserver.com:8082'),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    inIt();
  }

  inIt() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var userString = pref.getString(AppConstants.userdata);

    userData = UserData.fromJson(jsonDecode(userString!));


    currentuser = userData?.id.toString();



    channel.sink.add( jsonEncode({
      'type': 'fetch_history',
      'sender': currentuser,
      'receiver_user': widget.friendId,
      'room_id': widget.chatListData?.id.toString(),
    }));

    scrollController.addListener(() {});
    channel.stream.listen(
          (event) {

        print(event);
        var data = jsonDecode(event);


        if (data['type'] == 'history') {
          messageList = SmSHistoryModel.fromJson(data).messages ?? [];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.jumpTo(
                scrollController.position.maxScrollExtent);
          });

          isTyping = false;
          setState(() {});
        } else if (data['type'] == 'chat' &&
            (data['chat_user'] == currentuser ||
                data['logged_user'].toString() == currentuser) &&
            (data['chat_user'] == widget.friendId ||
                data['logged_user'].toString() == widget.friendId)) {
          messageList.add(SmSHistoryModel.fromJson(data).messages!.first);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.jumpTo(
                scrollController.position.maxScrollExtent);
          });

          setState(() {});
        } else if (data['type'] == 'typing' &&
            data['isTyping'] &&
            isTyping == false &&
            data['receiver_user'].toString() == currentuser) {
          isTyping = true;
          setState(() {});
        } else {
          isTyping = false;
//          setState(() {});
        }
      },
      onError: (error) {
        reconnectWebSocket();
      },
      onDone: () {
        reconnectWebSocket();
      },
    );
  }

  void reconnectWebSocket() {
    // Implement a reconnection strategy (e.g., exponential backoff)
    Future.delayed(const Duration(seconds: 2), () {
      initializeWebSocket();
    });
  }

  void initializeWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://chat-application.alphawizzserver.com:8082'),
    );
  }

  List<Messages> messageList = [];

  String roomId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 35,
        title: InkWell(onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailScreen(chatListData: widget.chatListData,fromBroadcast: true,),));
        },child:  Row(
          children: [
            const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/Loud_Speaker.png')
                    // NetworkImage(widget.image),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.2,
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10,),
                const Text(
                  'tab here to see broadcast detail',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                )
              ],
            )
          ],
        ),),
        actions: widget.friendId == '1'
            ? []
            : [
          // GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => VoiceCall(
          //                 frnd_id: widget.friendId,
          //               )));
          //     },
          //     child: const Icon(Icons.call)),
          const SizedBox(
            width: 20,
          ),
          /*GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CallScreen(frnd_id: widget.friendId)));
              },
              child: const Icon(Icons.video_call_outlined)),*/
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/chat_background.png",
                fit: BoxFit.cover,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: messageList.length ?? 0,
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        print(index);
                        var message = messageList[index];

                        return Column(
                          crossAxisAlignment: message.createdBy == 2
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            MessageBubble(
                              index: index,
                              message: message ?? Messages(),
                              isSeen: true,
                              isMe: false,
                              time: DateFormat('hh:mm').format(
                                  DateTime.parse(
                                      message?.createdAt ?? '')),
                              onPress: () {},
                              listLength: 5,
                              currentUser: currentuser ?? '2',
                              //MessageHelper.itemCount,
                              type: message.type.toString(),
                            )
                          ],
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey.shade100),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: messageController,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black),
                                      onChanged: (value) {
                                        // print('12345____________');
                                        // channel.sink.add(jsonEncode({
                                        //   'type': 'typing',
                                        //   "sender": currentuser,
                                        //   "receiver_user":
                                        //       widget.friendId,
                                        //   "messageType": 1,
                                        //   "isTyping": true
                                        // }));
                                      },
                                      onEditingComplete: () {
                                        // channel.sink.add(jsonEncode({
                                        //   'type': 'typing',
                                        //   "sender": currentuser,
                                        //   "receiver_user":
                                        //       widget.friendId,
                                        //   "messageType": 1,
                                        //   "isTyping": false
                                        // }));
                                      },
                                      decoration: const InputDecoration(
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal: 0.0),
                                        hintText: 'Message...',
                                        hintStyle: TextStyle(
                                          color: Color(0xff8E8E93),
                                        ),
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        pickfiles();
                                      },
                                      child:
                                      const Icon(Icons.attach_file)),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        showAlertDialog(context);
                                      },
                                      child:
                                      const Icon(Icons.camera_alt)),
                                  const SizedBox(
                                    width: 5,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (messageController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "message field can't be empty");
                          } else {
                            channel.sink.add(jsonEncode({
                              'type': 'typing',
                              "sender": currentuser,
                              "receiver_user": widget.friendId,
                              "messageType": 1,
                              "isTyping": false,
                              'room_id': widget.chatListData?.id.toString(),
                              'chat_type': 'broadcast'
                            }));

                            channel.sink.add(jsonEncode({
                              'type': 'chat',
                              "user_type": 'user',
                              "sender": currentuser,
                              "receiver_user": widget.friendId,
                              "content": messageController.text,
                              "messageType": 1,
                              'room_id': widget.chatListData?.id.toString(),
                              'chat_type': 'broadcast'
                            }));

                            print('${{
                              'type': 'chat',
                              "user_type": 'user',
                              "sender": currentuser,
                              "receiver_user": widget.friendId,
                              "content": messageController.text,
                              "messageType": 1,
                              'room_id': widget.chatListData?.id.toString(),
                              'chat_type': 'broadcast'
                            }}');

                            //  messageList.add(Messages(createdAt: '${DateTime.now()}', createdBy: 2,id: 5464,message: messageController.text,type: 1));
                            messageController.clear();
                          }
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
                )
              ],
            ),
          ],
        ),
      ),
    ); /*StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 35,
              title: Row(
                children: [
                  CircleAvatar(
                      radius: 18,
                      backgroundImage: widget.friendId == '1'
                          ? AssetImage(widget.image)
                          : NetworkImage(
                              widget.image,
                            ) // NetworkImage(widget.image),
                      ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      Text(
                        isTyping ? 'typing...' : '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      )
                    ],
                  )
                ],
              ),
              actions: widget.friendId == '1'
                  ? []
                  : [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VoiceCall(
                                          frnd_id: widget.friendId,
                                        )));
                          },
                          child: const Icon(Icons.call)),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CallScreen(frnd_id: widget.friendId)));
                          },
                          child: const Icon(Icons.video_call_outlined)),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      "assets/images/chat_background.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Builder(
                        builder: (context) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(),);
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Something went wrong'),);

                          } else if (snapshot.hasData) {

                            var data = jsonDecode(snapshot.data);

                            if (data['type'] == 'history') {

                              messageList = SmSHistoryModel.fromJson(jsonDecode(snapshot.data)).messages ?? [];
                              isTyping = false;

                            } else if (data['type'] == 'chat') {

                              print('${snapshot.data};fjsdkfkdfjkfjjff');

                              if ((data['chat_user'] == currentuser || data['logged_user'].toString() == currentuser)&&(data['chat_user'] == widget.friendId || data['logged_user'].toString() == widget.friendId) ) {
                                {
                                  messageList.add(SmSHistoryModel.fromJson(data).messages!.first);
                                }
                              }  else {

                              }

                            } else if (data['type'] == 'typing' &&
                                data['isTyping'] &&
                                isTyping == false &&
                                data['receiver_user'].toString() ==
                                    currentuser) {
                              isTyping = true;
                            } else {
                              isTyping = false;
                            }

                            // {type: read_receipt, sender: 1}
                            // SmSHistoryModel model =  SmSHistoryModel.fromJson(jsonDecode(snapshot.data));

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent);
                            });

                            return Expanded(
                              child: ListView.builder(
                                  itemCount: messageList.length ?? 0,
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    print(index);
                                    var message = messageList[index];

                                    return Column(
                                      crossAxisAlignment: message.createdBy == 2
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        MessageBubble(
                                          index: index,
                                          message: message ?? Messages(),
                                          isSeen: true,
                                          isMe: false,
                                          time: DateFormat('hh:mm').format(
                                              DateTime.parse(
                                                  message?.createdAt ?? '')),
                                          onPress: () {},
                                          listLength: 5,
                                          currentUser: currentuser ?? '2',
                                          //MessageHelper.itemCount,
                                          type: message.type.toString(),
                                        )
                                      ],
                                    );
                                  }),
                            );
                          } else {
                            return const Center(
                              child: Text('No Data'),
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.grey.shade100),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: messageController,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                            onChanged: (value) {
                                              // print('12345____________');
                                              // channel.sink.add(jsonEncode({
                                              //   'type': 'typing',
                                              //   "sender": currentuser,
                                              //   "receiver_user":
                                              //       widget.friendId,
                                              //   "messageType": 1,
                                              //   "isTyping": true
                                              // }));
                                            },
                                            onEditingComplete: () {
                                              // channel.sink.add(jsonEncode({
                                              //   'type': 'typing',
                                              //   "sender": currentuser,
                                              //   "receiver_user":
                                              //       widget.friendId,
                                              //   "messageType": 1,
                                              //   "isTyping": false
                                              // }));
                                            },
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 0.0),
                                              hintText: 'Message...',
                                              hintStyle: TextStyle(
                                                color: Color(0xff8E8E93),
                                              ),
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              pickfiles();
                                            },
                                            child:
                                                const Icon(Icons.attach_file)),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              showAlertDialog(context);
                                            },
                                            child:
                                                const Icon(Icons.camera_alt)),
                                        const SizedBox(
                                          width: 5,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (messageController.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "message field can't be empty");
                                } else {
                                  channel.sink.add(jsonEncode({
                                    'type': 'typing',
                                    "sender": currentuser,
                                    "receiver_user": widget.friendId,
                                    "messageType": 1,
                                    "isTyping": false
                                  }));

                                  channel.sink.add(jsonEncode({
                                    'type': 'chat',
                                    "user_type": 'user',
                                    "sender": currentuser,
                                    "receiver_user": widget.friendId,
                                    "content": messageController.text,
                                    "messageType": 1
                                  }));

                                  //  messageList.add(Messages(createdAt: '${DateTime.now()}', createdBy: 2,id: 5464,message: messageController.text,type: 1));
                                  messageController.clear();
                                }
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
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });*/
  }

  showAlertDialog(
      BuildContext context,
      ) {
    AlertDialog alert = AlertDialog(
      content: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select Any One Option",
            style: TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            pickImage(ImageSource.gallery);
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                color: MyColor.primary, borderRadius: BorderRadius.circular(8)),
            child: const Center(
                child: Text(
                  'Select From Gallery',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                )),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            pickImage(ImageSource.camera);
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                color: MyColor.primary, borderRadius: BorderRadius.circular(8)),
            child: const Center(
                child: Text(
                  'Select From Camera',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                )),
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    required this.isMe,
    required this.message,
    required this.time,
    required this.onPress,
    required this.index,
    required this.listLength,
    required this.isSeen,
    required this.type,
    required this.currentUser,
  });

  final bool isMe;
  final String type;
  final String currentUser;
  final Messages message;

  final String time;
  final VoidCallback onPress;
  int index;
  int listLength;
  bool isSeen;

  @override
  Widget build(BuildContext context) {
    String isImage = message.message?.split('.').last ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: message.createdBy.toString() == currentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 2,
          ),

          if (message.type == 1)
            Align(
              alignment: message.createdBy.toString() == currentUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: onPress,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(radius: 10,backgroundColor: Colors.blue,),
                    const SizedBox(width: 5,),
                    Material(
                      elevation: 1,
                      color: message.createdBy.toString() == currentUser
                          ? MyColor.primary
                          : MyColor.secondary,
                      borderRadius: message.createdBy.toString() == currentUser
                          ? const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(10))
                          : const BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(0)),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.createdAt ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 13, color: Colors.greenAccent),
                            ),

                            Text(
                              message.message ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 16, color: Colors.white,fontWeight: FontWeight.w700),
                            )
                          ],),
                      ),
                    )
                  ],),
              ),
            ),
          if (message.type == 2 &&
              (isImage == 'jpg' || isImage == 'jpeg' || isImage == 'png'))
            Align(
              alignment: message.createdBy.toString() == currentUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                          imageUrl:
                          '${AppUrl.fileURL}${message.message}' ?? ''),
                    ),
                  );
                },
                child: Material(
                  elevation: 1,
                  borderRadius: message.createdBy.toString() == currentUser
                      ? const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10))
                      : const BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(0)),
                  color: message.createdBy.toString() == currentUser
                      ? MyColor.primary
                      : MyColor.secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image(
                        height: MediaQuery.of(context).size.height * .2,
                        width: MediaQuery.of(context).size.width * .5,
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            '${AppUrl.fileURL}${message.message}' ?? '')),
                  ),
                ),
              ),
            ),

          if (message.type == 2 &&
              isImage != 'jpg' &&
              isImage != 'jpeg' &&
              isImage != 'png')
            Align(
              alignment: message.createdBy.toString() == currentUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  launchUrl(Uri.parse('${AppUrl.fileURL}${message.message}'));
                },
                child: Material(
                  elevation: 1,
                  borderRadius: message.createdBy.toString() == currentUser
                      ? const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10))
                      : const BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(0)),
                  color: message.createdBy.toString() == currentUser
                      ? MyColor.primary
                      : MyColor.secondary,
                  child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.file_present_sharp,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              message.message ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ),

          const SizedBox(
            height: 2,
          ),
          Text(
            time.toString(),
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(
            height: 4,
          ),
          // Text(time.toString())
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close the full-screen view on tap
        },
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain, // Ensure the image is fully visible
          ),
        ),
      ),
    );
  }
}
