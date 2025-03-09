import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ut_messenger/helper/api.dart';
import 'package:ut_messenger/helper/app_contants.dart';
import 'package:ut_messenger/helper/colors.dart';
import 'package:ut_messenger/home/bottom_navbar.dart';
import 'package:ut_messenger/home/home_screen.dart';
import 'package:ut_messenger/model/message_model.dart';
import 'package:ut_messenger/model/usermodel.dart';
import 'package:ut_messenger/notification/notification_controller.dart';
import 'package:ut_messenger/widgets/Block%20_and_report_dialog.dart';
import 'package:ut_messenger/widgets/logout_dialog.dart';
import 'package:ut_messenger/widgets/networkimage.dart';
import 'package:video_compress/video_compress.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/chatlist_model.dart';
import 'group_detail.dart';
import 'package:http/http.dart' as http;

import 'in_chat_profile_info.dart';

class GroupPage extends StatefulWidget {
  final String name, image, friendId;
  String? myRoomId;
  bool? isBlock;

  final ChatListData? chatListData;

  GroupPage(
      {super.key,
      required this.name,
      required this.image,
      this.chatListData,
      this.myRoomId,
      this.isBlock,
      required this.friendId});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  File? imagefile, anyfile;

  bool isTyping = false;

  FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();
  String _audioPath = '';
  bool _isRecording = false;
  Timer? _timer;
  int _elapsedTime = 0;

  Future<void> pickfiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Restrict to only images
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null) {

        var temp = File(filePath);

        double kb = await temp.length() / 1024 ;

        if(kb >25600) {

          Fluttertoast.showToast(msg: 'More then 24 MB file size not supported',toastLength: Toast.LENGTH_LONG);
        }else if(filePath.contains('.mp4')){
          MediaInfo? mediaInfo = await VideoCompress.compressVideo(
            filePath,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false, // It's false by default
          );
          anyfile = File(mediaInfo!.file!.path);
        }else {
          anyfile = File(filePath);
        }


        String base64Image = base64Encode(anyfile!.readAsBytesSync());

        channel.sink.add(jsonEncode({
          'type': 'file',
          "user_type": 'user',
          "sender": currentuser,
          "receiver_user": widget.friendId,
          "fileName": anyfile?.path.split('/').last,
          "fileData": base64Image,
          'room_id': widget.chatListData?.id == null
              ? (widget.myRoomId ?? '')
              : (widget.chatListData?.id ?? ''),
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
        'room_id': widget.chatListData?.id == null
            ? widget.myRoomId.toString()
            : widget.chatListData?.id.toString(),
      }));
    }
  }

  ScrollController scrollController = ScrollController();

  final TextEditingController messageController = TextEditingController();

  String? currentuser;
  UserData? userData;

  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse(AppUrl.webSocketURL),
  );

  List<Messages> messageList = [];

  String roomId = '';

  ///for message forward
  List<Messages> selectedMessage = [];
  bool isForward = false;
  bool isForwardLoading = false;
  bool isDelete = false;

  List popupItemsList = [
    {'icon': Icons.thumb_down, 'title': 'Report'},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.isBlock != null && widget.isBlock!) {
      popupItemsList.add({'icon': Icons.report_off, 'title': 'Unblock'});
    } else if (widget.isBlock != null && widget.isBlock == false) {
      popupItemsList.add({'icon': Icons.block, 'title': 'Block'});
    } else if (widget.chatListData?.isBlocked == true &&
        widget.chatListData?.type == 1) {
      popupItemsList.add({'icon': Icons.report_off, 'title': 'Unblock'});
    } else if (widget.chatListData?.isBlocked == false &&
        widget.chatListData?.type == 1) {
      popupItemsList.add({'icon': Icons.block, 'title': 'Block'});
    } else {}

    notificationHandle();
    inIt();
    _initializeRecorder();
  }

  notificationHandle() async {
    NotificationController.messageStream.listen((message) {
      if (message.data['type'] == 'forwarded_message') {
        if (widget.myRoomId != null && widget.myRoomId != '') {
          channel.sink.add(jsonEncode({
            'type': 'fetch_history',
            'sender': currentuser,
            'receiver_user': widget.friendId,
            'room_id': (widget.myRoomId ?? '').toString(),
          }));
        } else {
          channel.sink.add(jsonEncode({
            'type': 'fetch_history',
            'sender': currentuser,
            'receiver_user': widget.friendId,
            'room_id': (widget.chatListData?.id ?? '').toString(),
          }));
        }
      }
      // Handle the message and update the chat screen UI
    });
  }

  inIt() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var userString = pref.getString(AppConstants.userdata);

    String? token = pref?.getString('token');

    userData = UserData.fromJson(jsonDecode(userString!));

    currentuser = userData?.id.toString();

    if (widget.myRoomId != null && widget.myRoomId != '') {
      channel.sink.add(jsonEncode({
        'type': 'fetch_history',
        'sender': currentuser,
        'receiver_user': widget.friendId,
        'room_id': (widget.myRoomId ?? '').toString(),
      }));
    }
    else {
      channel.sink.add(jsonEncode({
        'type': 'fetch_history',
        'sender': currentuser,
        'receiver_user': widget.friendId,
        'room_id': (widget.chatListData?.id ?? '').toString(),
      }));
    }

    // channel.sink.add( jsonEncode({
    //   'type': 'fetch_history',
    //   'sender': currentuser,
    //   'receiver_user': widget.friendId,
    //   'room_id': widget.chatListData?.id.toString(),
    // }));
// print('llkkk');
    scrollController.addListener(() {});
    channel.stream.listen(
      (event) {
        var data = jsonDecode(event);

        print('Data__${data}');

        if (data['type'] == 'history' &&
            (data['room_id'].toString() == widget.chatListData?.id.toString() ||
                data['room_id'].toString() == widget.myRoomId)) {
          messageList = SmSHistoryModel.fromJson(data).messages ?? [];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });

          isTyping = false;
          setState(() {});
        } else if (data['type'] == 'chat' &&
            (data['room_id'].toString() == widget.chatListData?.id.toString() || data['room_id'].toString() == widget.myRoomId) && (data['friend_users'].toString().split(',').any((element) => element == currentuser.toString(),))) {
          print('${widget.chatListData?.id.toString()}__________roroom');

          messageList.add(SmSHistoryModel.fromJson(data).messages!.first);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });

          if (mounted) {
            setState(() {});
          }
        } else if (data['type'] == 'chat' &&
            data['logged_user'] == currentuser) {
          if (data['room_id'] != null) {
            widget.myRoomId = data['room_id'].toString();
          }
          messageList.add(SmSHistoryModel.fromJson(data).messages!.first);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });

          if (mounted) {
            setState(() {});
          }
        } else if (data['type'] == 'typing' &&
            data['isTyping'] &&
            isTyping == false &&
            data['receiver_user'].toString() == currentuser) {
          isTyping = true;
          // setState(() {});
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

    // _mPlayer!.openPlayer().then((value) {
    //   setState(() {
    //     _mPlayerIsInited = true;
    //   });
    // });
    // recordAudio();
  }

  Future<void> _initializeRecorder() async {
    await _soundRecorder.openRecorder();
    await _soundPlayer.openPlayer();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print('Microphone permission granted');
    } else {
      print('Microphone permission denied');
    }
  }

  // Start recording
  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    DateTime date = DateTime.now();

    _audioPath = '${directory.path}/voice_recording${date}.aac';
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });
    });
    await _soundRecorder.startRecorder(toFile: _audioPath);
    setState(() {
      _isRecording = true;
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _stopRecording() async {
    await _soundRecorder.stopRecorder();

    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _elapsedTime = 0;
    });

    anyfile = File(_audioPath);

    String base64Image = base64Encode(anyfile!.readAsBytesSync());

    channel.sink.add(jsonEncode({
      'type': 'file',
      "user_type": 'user',
      "sender": currentuser,
      "receiver_user": widget.friendId,
      "fileName": anyfile?.path.split('/').last,
      "fileData": base64Image,
      'room_id': widget.chatListData?.id == null
          ? widget.myRoomId.toString()
          : widget.chatListData?.id.toString(),
    }));
    // Send the audio to the chat (you can implement your own chat logic here)
  }

  Future<void> _playRecording() async {
    await _soundPlayer.startPlayer(fromURI: _audioPath);
  }

  void stopAudio(int index) async {
    await _soundPlayer.stopPlayer();
    setState(() {
      messageList[index].isplaying = false;
      messageList[index].currentPosition = Duration.zero;
    });
  }

  void playAudio(String url, int index) async {
    setState(() {
      messageList[index].isBuffering = true;
    });

    _soundPlayer.setSubscriptionDuration(const Duration(milliseconds: 1000));
    try {
      await _soundPlayer
          .startPlayer(
        fromURI: url,
        //codec: Codec(),
        whenFinished: () {
          setState(() {
            messageList[index].isplaying = false;
            messageList[index].currentPosition = Duration.zero;
          });
        },
      )
          .then((_) {
        if (_soundPlayer.onProgress != null) {
          _soundPlayer.onProgress?.listen((event) {
            setState(() {
              messageList[index].currentPosition = event.position;
              messageList[index].totalDuration = event.duration;
            });
          });
          setState(() {
            messageList[index].isplaying = true;
            messageList[index].isBuffering = false;
          });
        } else {
          print("onProgress is null");
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void reconnectWebSocket() {
    // Implement a reconnection strategy (e.g., exponential backoff)
    Future.delayed(const Duration(seconds: 2), () {
      initializeWebSocket();
    });
  }

  void initializeWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse(AppUrl.webSocketURL),
    );
  }

  int returnIndex() {
    int index = widget.chatListData!.chatroom!
        .indexWhere((element) => element.user?.id.toString() != currentuser);
    return index != -1 ? index : 1;
  }

  @override
  Widget build(BuildContext context) {
    isDelete = selectedMessage.any(
      (element) => element.createdBy.toString() != currentuser,
    );
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 35,
        title: InkWell(
          onTap: () {
            if (widget.chatListData != null && widget.chatListData!.type != 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailScreen(
                      chatListData: widget.chatListData,
                    ),
                  ));
            }
          },
          child: GestureDetector(
            onTap: () {
              print("IMAGE URL: https://businessmoj.com/storage/app/public/profile/${widget.chatListData?.chatroom?.first.user?.image ?? 'default.png'}");
              print(jsonEncode(widget.chatListData?.toJson()));

              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500), // Animation speed
                  pageBuilder: (context, animation, secondaryAnimation) {
                    print("Image URL: ${widget.image}"); // Console log for debugging
                    return InChatProfileInfo(
                      image: (widget.chatListData?.chatroom?.first.user?.image != null)
                          ? "https://businessmoj.com/storage/app/public/profile/${widget.chatListData!.chatroom!.first.user!.image}"
                          : widget.image,
                      chatListData: widget.chatListData,
                    );
                  },

                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },


            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: ClipOval(
                    child: AppImage(image: widget.image),
                  ), // NetworkImage(widget.image),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: Text(
                        widget.name.isNotEmpty ? "${widget.chatListData!.chatroom!.first.user!.fName} ${widget.chatListData!.chatroom!.first.user!.lName}" : 'NA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    widget.chatListData != null && widget.chatListData!.type != 1
                        ? const Text(
                      'Tap here to see group detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                        : const SizedBox()
                  ],
                ),
              ],
            ),
          ),

        ),
        actions: widget.friendId == '1'
            ? []
            : [
                selectedMessage.isNotEmpty
                    ? Row(
                        children: [
                          isDelete
                              ? const SizedBox()
                              : GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return confirmDialog();
                                      },
                                    );
                                  },
                                  child: const Icon(Icons.delete)),
                          const SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                              onTap: () {
                                String msg = selectedMessage
                                    .map(
                                      (e) => e.message,
                                    )
                                    .toList()
                                    .join('\n');

                                Clipboard.setData(ClipboardData(
                                  text: msg,
                                ));
                                Fluttertoast.showToast(msg: 'message copied');
                                messageList.forEach(
                                  (element) => element.isSelected = false,
                                );
                                selectedMessage = [];
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.copy,
                                size: 20,
                              )),
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
                            width: 15,
                          ),

                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => const HomeScreen(
                                              fromChat: true,
                                            ))).then(
                                  (value) {
                                    if (value != null) {
                                      List<ChatListData> selectedChat =
                                          value as List<ChatListData>;

                                      forwardMessage(
                                          '',
                                          selectedMessage
                                              .map(
                                                (e) => e.id.toString(),
                                              )
                                              .toList()
                                              .join(','),
                                          selectedChat
                                              .map(
                                                (e) => e.id.toString(),
                                              )
                                              .toList()
                                              .join(','));
                                    }
                                  },
                                );
                              },
                              child: const Icon(Icons.shortcut)),
                          /*GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CallScreen(frnd_id: widget.friendId)));
              },
              child: const Icon(Icons.video_call_outlined)),*/
                        ],
                      )
                    :
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
                                      if (popupItemsList[i]['title'] ==
                                          'Report') {
                                        showDialog(
                                            context: context,
                                            // barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return widget.chatListData !=
                                                          null &&
                                                      widget.chatListData!
                                                              .type !=
                                                          1
                                                  ? BlockReportDialog(
                                                      onTabYes: () {
                                                        reportUserOrRoom(
                                                            roomId: widget
                                                                    .chatListData
                                                                    ?.id
                                                                    .toString() ??
                                                                '',
                                                            friendId: '');
                                                      },
                                                    )
                                                  : BlockReportDialog(
                                                      title: widget.name,
                                                      onTabYes: () {
                                                        if (widget
                                                                .chatListData !=
                                                            null) {
                                                          int index =
                                                              returnIndex();

                                                          reportUserOrRoom(
                                                              friendId: widget
                                                                      .chatListData
                                                                      ?.chatroom![
                                                                          index]
                                                                      .user!
                                                                      .id
                                                                      .toString() ??
                                                                  '',
                                                              roomId: '');
                                                        } else {
                                                          reportUserOrRoom(
                                                              friendId: widget
                                                                  .friendId,
                                                              roomId: '');
                                                        }
                                                      },
                                                    );
                                            });
                                      } else if (popupItemsList[i]['title'] ==
                                          'Block') {
                                        showDialog(
                                            context: context,
                                            // barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return BlockReportDialog(
                                                  title: widget.name,
                                                  forBlock: true,
                                                  onTabYes: () {
                                                    if (widget.isBlock ==
                                                        null) {
                                                      int index = returnIndex();

                                                      userBlock(widget
                                                              .chatListData
                                                              ?.chatroom![index]
                                                              .user!
                                                              .id
                                                              .toString() ??
                                                          '');
                                                    } else {
                                                      userBlock(
                                                          widget.friendId);
                                                    }
                                                  });
                                            });
                                      } else {
                                        if (widget.isBlock == null) {
                                          int index = returnIndex();

                                          userBlock(widget.chatListData
                                                  ?.chatroom![index].user!.id
                                                  .toString() ??
                                              '');
                                        } else {
                                          userBlock(widget.friendId);
                                        }
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
              ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isForwardLoading
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 30,
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: MyColor.primary.withOpacity(0.5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/appLogoIcon.png',
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'sending...',
                      style: TextStyle(color: MyColor.white),
                    )
                  ],
                ),
              ),
            )
          : const SizedBox(),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/chat_background.png",
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(0.2),
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
                        var message = messageList[index];

                        return Column(
                          crossAxisAlignment: message.createdBy == 2
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            MessageBubble(
                              index: index,
                              onLongPress: () {
                                messageList[index].isSelected =
                                    !(messageList[index].isSelected ?? false);

                                isForward = messageList.any(
                                  (element) => element.isSelected ?? false,
                                );

                                if (selectedMessage.contains(message)) {
                                  selectedMessage.remove(message);
                                } else {
                                  selectedMessage.add(message);
                                }

                                setState(() {});

                                // if (message.createdBy.toString() == currentuser) {
                                //
                                //
                                //
                                // }
                              },

                              message: message ?? Messages(),
                              isSeen: true,
                              isMe: false,
                              time: DateFormat('dd/MM/yyyy hh:mm a').format(
                                  DateTime.parse(message?.createdAt ?? '').toLocal()),
                              onPress: () {},
                              listLength: 5,
                              currentUser: currentuser ?? '2',
                              //MessageHelper.itemCount,
                              type: message.type.toString(),
                              currentUserImage: userData?.image ?? '',
                              audioPlayer: _soundPlayer,
                              // Pass the audio player instance
                              isPlaying: message.isplaying ?? false,
                              isBuffering: message.isBuffering ?? false,
                              currentPosition:
                                  message.currentPosition ?? Duration.zero,
                              totalDuration:
                                  message.totalDuration ?? Duration.zero,
                              playAudio: playAudio,
                              stopAudio: stopAudio,
                              formatDuration: formatDuration,
                            ),
                          ],
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.chatListData?.type != 1 &&
                          widget.chatListData?.chatAccessGroup == 1 &&
                          widget.chatListData?.createdBy.toString() !=
                              currentuser
                      ? Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: RichText(
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Image.asset(
                                    'assets/images/Loud_Speaker.png',
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                                const TextSpan(
                                    text:
                                        "Admin changed this group's setting to allow only admin to send message to this group",
                                    style:
                                        TextStyle(color: MyColor.hintTextColor))
                              ]),
                            ),
                          ),
                        )
                      : Row(
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
                                            textInputAction:
                                                TextInputAction.newline,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
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
                                        _isRecording
                                            ? Text(_formatTime(_elapsedTime))
                                            : Row(
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        pickfiles();
                                                      },
                                                      child: const Icon(
                                                          Icons.attach_file)),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        showAlertDialog(
                                                            context);
                                                      },
                                                      child: const Icon(
                                                          Icons.camera_alt)),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                ],
                                              ),
                                        GestureDetector(
                                            // onPanStart: (f){
                                            //   _startRecording();
                                            // },
                                            // onPanEnd: (d){
                                            //   _stopRecording();
                                            // },
                                            onTap: () {
                                              if (_isRecording) {
                                                _stopRecording();
                                              } else {
                                                _startRecording();
                                              }
                                            },
                                            child: Icon(
                                              _isRecording
                                                  ? Icons.stop
                                                  : Icons.mic,
                                            )),

                                        /*if (_audioPath.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow),
                                      onPressed: _playRecording,
                                    ),*/
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
                                } else if ((widget.isBlock != null &&
                                        widget.isBlock!) ||
                                    (widget.chatListData != null &&
                                        widget.chatListData!.isBlocked!)) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "You've blocked this user. Please unblock them to send a message.");
                                } else {
                                  channel.sink.add(jsonEncode({
                                    'type': 'typing',
                                    "sender": currentuser,
                                    "receiver_user": widget.friendId,
                                    "messageType": 1,
                                    "isTyping": false,
                                    'room_id': widget.chatListData?.id == null
                                        ? widget.myRoomId == ''
                                            ? null
                                            : widget.myRoomId
                                        : widget.chatListData?.id.toString(),
                                    'sender_name':  widget.chatListData?.type == 2  ?   widget.name : userData?.name,
                                    'group_name':  widget.chatListData?.type == 2  ?   widget.name :  ''
                                  }));

                                  channel.sink.add(jsonEncode({
                                    'type': 'chat',
                                    "user_type": 'user',
                                    "sender": currentuser,
                                    "receiver_user": widget.friendId,
                                    "content": messageController.text,
                                    "messageType": 1,
                                    'room_id': widget.chatListData?.id == null ? widget.myRoomId == ''
                                            ? ''
                                            : widget.myRoomId
                                        : widget.chatListData?.id.toString(),
                                    'sender_name': widget.chatListData?.type == 2  ?   widget.name :  userData?.name,
                                    'group_name':  widget.chatListData?.type == 2  ?   widget.name :  ''
                                  }));


                                  //  messageList.add(Messages(createdAt: '${DateTime.now()}', createdBy: 2,id: 5464,message: messageController.text,type: 1));

                                  messageController.clear();

                                  Future.delayed(Duration(milliseconds: 300), () {
                                    callSocketHistory();
                                  });

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

  @override
  void dispose() {
    // TODO: implement dispose
    _soundRecorder.closeRecorder();
    _soundPlayer.closePlayer();
    _timer?.cancel();
    super.dispose();
  }

  Widget confirmDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Confirm Action',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('Do you want to remove this message?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            messageList.forEach(
              (element) => element.isSelected = false,
            );
            setState(() {}); // Close dialog
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
            channel.sink.add(jsonEncode({
              'type': 'delete',
              "user_type": 'user',
              "sender": currentuser,
              "receiver_user": widget.friendId,
              "content": messageController.text,
              "messageType": 1,
              'room_id': widget.chatListData?.id == null
                  ? widget.myRoomId.toString()
                  : widget.chatListData?.id.toString(),
              'sender_name': userData?.name,
              'message_id': selectedMessage
                  .map(
                    (e) => e.id.toString(),
                  )
                  .toList()
                  .join(',')
            }));

            Navigator.of(context).pop();

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

  Future<void> forwardMessage(
      String token, String messageids, String mroomIds) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? token = pref?.getString('token');

    setState(() {
      isForwardLoading = true;
    });
    try {
      var headers = {'Authorization': 'Bearer $token'};
      var body = {'room_ids': mroomIds, 'message_ids': messageids};
      http.Response response = await http.post(Uri.parse(AppUrl.forwardMessage),
          headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        Fluttertoast.showToast(msg: data['message']);
        callSocketHistory();
      } else {
        Fluttertoast.showToast(msg: "Failed to forward ");
      }

      messageList.forEach(
        (element) => element.isSelected = false,
      );

      setState(() {
        isForwardLoading = false;
      });
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

  Future<void> userBlock(String friendId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? token = pref?.getString('token');
    try {
      var headers = {'Authorization': 'Bearer $token'};
      var body = {'friend_id': friendId};
      http.Response response = await http.post(Uri.parse(AppUrl.blockUserApi),
          headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        Fluttertoast.showToast(msg: data['message']);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBarMain(),
            ));
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to block");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

  Future<void> reportUserOrRoom(
      {required String roomId, required String friendId}) async
  {
    SharedPreferences pref = await SharedPreferences.getInstance();

    String? token = pref.getString('token');

    try {
      var headers = {'Authorization': 'Bearer $token'};
      var body = {'friend_id': friendId, 'room_id': roomId};
      http.Response response = await http.post(Uri.parse(AppUrl.reportApi),
          headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        Fluttertoast.showToast(msg: data['message']);
      } else {
        // Handle error response
        Fluttertoast.showToast(msg: "Failed to block");
      }
    } catch (e) {
      // Handle network or parsing error
      Fluttertoast.showToast(msg: "An error occurred: $e");
    }
  }

  callSocketHistory(){
    if (widget.myRoomId != null && widget.myRoomId != '') {
      channel.sink.add(jsonEncode({
        'type': 'fetch_history',
        'sender': currentuser,
        'receiver_user': widget.friendId,
        'room_id': (widget.myRoomId ?? '').toString(),
      }));
    }
    else {
      channel.sink.add(jsonEncode({
        'type': 'fetch_history',
        'sender': currentuser,
        'receiver_user': widget.friendId,
        'room_id': (widget.chatListData?.id ?? '').toString(),
      }));
    }
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.isMe,
      required this.message,
      required this.time,
      required this.onPress,
      required this.index,
      required this.listLength,
      required this.isSeen,
      required this.type,
      required this.currentUser,
      required this.onLongPress,
      required this.isPlaying,
      required this.isBuffering,
      required this.currentPosition,
      required this.totalDuration,
      required this.playAudio,
      required this.stopAudio,
      required this.formatDuration,
      required this.audioPlayer,
      this.currentUserImage});

  final bool isMe;
  final String type;
  final String currentUser;
  final String? currentUserImage;
  final Messages message;
  final VoidCallback onLongPress;

  final bool isPlaying;
  final bool isBuffering;
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(String, int) playAudio;
  final Function(int) stopAudio;
  final String Function(Duration) formatDuration;
  final FlutterSoundPlayer audioPlayer;

  final String time;
  final VoidCallback onPress;
  int index;
  int listLength;
  bool isSeen;

  @override
  Widget build(BuildContext context) {
    String isImage = message.message?.split('.').last ?? '';

    if (message.type == 2 && (isImage == 'aac')) {}
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        color: message.isSelected ?? false
            ? MyColor.primary.withOpacity(0.2)
            : Colors.transparent,
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
                  onTap: () {
                    if (isValidLink(message.message ?? '')) {
                      launchUrl(Uri.parse(message.message ?? ''));
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      message.createdBy.toString() == currentUser
                          ? CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.blue,
                              child: ClipOval(
                                child: AppImage(
                                  image:
                                  currentUserImage!.contains('http') ? '$currentUserImage'  :'${AppUrl.profileURL}$currentUserImage',
                                ),
                              ),
                            )
                          : const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.blue,
                              child: ClipOval(
                                child: AppImage(
                                  image: '',
                                  personImage: true,
                                ),
                              ),
                            ),
                      const SizedBox(
                        width: 5,
                      ),
                      Material(
                        elevation: 1,
                        color: message.createdBy.toString() == currentUser
                            ? MyColor.primary
                            : MyColor.white,
                        borderRadius:
                            message.createdBy.toString() == currentUser
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.senderName ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontSize: 13,
                                        color: message.createdBy.toString() ==
                                                currentUser
                                            ? Colors.blue.shade100
                                            : Colors.black45,
                                        fontWeight: FontWeight.w700),
                              ),
                              Text(
                                message.message ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontSize: 16,
                                        color: message.createdBy.toString() ==
                                                currentUser
                                            ? MyColor.white
                                            : Colors.black,
                                        decoration:
                                            isValidLink(message.message ?? '')
                                                ? TextDecoration.underline
                                                : null,
                                        fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
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
                    elevation: 0,
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
                        ? Colors.transparent//MyColor.primary
                        : Colors.transparent,//MyColor.secondary,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: AppImage(
                        image: '${AppUrl.fileURL}${message.message}' ?? '',
                        height: MediaQuery.of(context).size.height * .2,
                        width: MediaQuery.of(context).size.width * .5,
                        fit: BoxFit.cover,
                      ) /*Image(
                          height: MediaQuery.of(context).size.height * .2,
                          width: MediaQuery.of(context).size.width * .5,
                          fit: BoxFit.cover,
                          image: )*/
                      ,
                    ),
                  ),
                ),
              ),
            if (message.type == 2 && (isImage == 'aac'))
              Align(
                alignment: message.createdBy.toString() == currentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: ChatBubble(
                  message: message,
                  audioPlayer: audioPlayer,
                  // Pass the audio player instance
                  isPlaying: isPlaying,
                  isBuffering: isBuffering,
                  currentPosition: currentPosition,
                  totalDuration: totalDuration,
                  playAudio: playAudio,
                  stopAudio: stopAudio,
                  formatDuration: formatDuration,
                  index: index,
                  isuser: message.createdBy.toString() == currentUser,
                ),
              ),

            if (message.type == 2 &&
                isImage != 'jpg' &&
                isImage != 'jpeg' &&
                isImage != 'png' &&
                isImage != 'aac')
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
      ),
    );
  }

  bool isValidLink(String text) {
    final uri = Uri.tryParse(text);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }
}

class ChatBubble extends StatefulWidget {
  final Messages message;
  final bool isPlaying;
  final bool isBuffering;
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(String, int) playAudio;
  final Function(int) stopAudio;
  final String Function(Duration) formatDuration;
  final FlutterSoundPlayer audioPlayer;
  final int index;
  final bool? isuser;

  const ChatBubble(
      {required this.message,
      required this.isPlaying,
      required this.isBuffering,
      required this.currentPosition,
      required this.totalDuration,
      required this.playAudio,
      required this.stopAudio,
      required this.formatDuration,
      required this.audioPlayer,
      required this.index,
      this.isuser});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  FlutterSoundPlayer soundPlayer1 = FlutterSoundPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    init();
  }

  init() async {
    await soundPlayer1.openPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: MyColor.greyText.withOpacity(0.5),
        borderRadius: BorderRadius.only(
            topRight: const Radius.circular(10),
            topLeft: const Radius.circular(10),
            bottomRight: Radius.circular(widget.isuser ?? true ? 0.0 : 10),
            bottomLeft: Radius.circular(widget.isuser ?? true ? 10.0 : 0.0)),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // if (widget.isPlaying) {
              //   widget.stopAudio(widget.index);
              // } else {
              //   widget.playAudio('${AppUrl.fileURL}${widget.message.message}', widget.index);
              // }
              if (widget.message.isplaying ?? false) {
                stopAudio(widget.index);
              } else {
                playAudio(
                    '${AppUrl.fileURL}${widget.message.message}', widget.index);
              }
            },
            child: widget.message.isBuffering ?? false
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.blue))
                : Icon(
                    widget.message.isplaying ?? false
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.blue,
                    size: 30,
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator and Timer
                Row(
                  children: [
                    Text(
                      formatDuration(
                          widget.message.currentPosition ?? Duration.zero),
                      //widget.formatDuration(widget.currentPosition),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Expanded(
                      child: Slider(
                        value: (widget.message.currentPosition ?? Duration.zero)
                            .inSeconds
                            .toDouble(),
                        max: (widget.message.totalDuration?.inSeconds ?? 0)
                                    .toDouble() >
                                0
                            ? (widget.message.totalDuration?.inSeconds ?? 0)
                                .toDouble()
                            : 1,
                        onChanged: (value) {
                          soundPlayer1
                              .seekToPlayer(Duration(seconds: value.toInt()));
                        },
                        activeColor: Colors.blue,
                        inactiveColor: Colors.grey[300],
                      ),
                    ),
                    Text(
                      formatDuration(
                          widget.message.totalDuration ?? Duration.zero),
                      //widget.formatDuration(widget.totalDuration)
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void stopAudio(int index) async {
    await soundPlayer1.stopPlayer();
    setState(() {
      widget.message.isplaying = false;
      widget.message.currentPosition = Duration.zero;
    });
  }

  void playAudio(String url, int index) async {
    setState(() {
      widget.message.isBuffering = true;
    });

    soundPlayer1.setSubscriptionDuration(const Duration(milliseconds: 1000));
    try {
      await soundPlayer1
          .startPlayer(
        fromURI: url,
        //codec: Codec(),
        whenFinished: () {
          setState(() {
            widget.message.isplaying = false;
            widget.message.currentPosition = Duration.zero;
          });
        },
      )
          .then((_) {
        if (soundPlayer1.onProgress != null) {
          soundPlayer1.onProgress?.listen((event) {
            setState(() {
              widget.message.currentPosition = event.position;
              widget.message.totalDuration = event.duration;
            });

            print('${widget.message.currentPosition}___________sdsds');
          });
          setState(() {
            widget.message.isplaying = true;
            widget.message.isBuffering = false;
          });
        } else {
          print("onProgress is null");
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    soundPlayer1.closePlayer();
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
          child: AppImage(fit: BoxFit.contain ,image: imageUrl,height: 600,width: 400,) /*Image.network(
            imageUrl,
            fit: BoxFit.contain, // Ensure the image is fully visible
          )*/,
        ),
      ),
    );
  }
}
