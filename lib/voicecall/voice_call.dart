// import 'dart:async';
// import 'dart:convert';
//
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
//
// import 'dart:developer';
//
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ut_messenger/call/call_screen.dart';
// import 'package:ut_messenger/helper/api.dart';
// import 'package:ut_messenger/helper/colors.dart';
//
// import '../helper/global.dart';
//
// class VoiceCall extends StatefulWidget {
//   String? frnd_id;
//
//   VoiceCall({super.key, this.frnd_id});
//
//   @override
//   State<VoiceCall> createState() => _VoiceCallState();
// }
//
// class _VoiceCallState extends State<VoiceCall> {
//   Timer? _callTimer;
//   Duration _callDuration = Duration.zero;
//
//   int uid = 0;
//   int? remoteUid;
//   late RtcEngine agoraEngine;
//   Global global = Global();
//   bool isCalling = true;
//   bool isMuted = false;
//   bool isSpeaker = true;
//   Timer? timer;
//   Timer? secTimer;
//   int callVolume = 50;
//   int min = 0;
//   int sec = 0;
//   String agoraAppCertificate = "db5684deb1df408aacb8067bf7a4acff";
//
//   // String agoraToken = "";
//   // String agoraChannelName = "";
//   String agoraToken =
//       ""; //"006c14b4eb96e5e4fe8a0a61cf94ab770bdIACxUnB3rttwt0N1eP8QvqgCx7dftmKtjFqnknLXQrGNl3Xi9dQAAAAAEADkIAEAqdU+ZwEA6AOBhj1n";
//   String agoraChannelName = ""; //"utmessenger10_1";
//   @override
//   void initState() {
//     super.initState();
//
//     firebaseOpenAppMessage ();
//     //Set up an instance of Agora engine
//
//     Future.microtask(() {
//       if (ModalRoute.of(context)?.settings.arguments != null) {
//         final List argument = ModalRoute.of(context)?.settings.arguments as List;
//
//         print('${argument[0]}_______________');
//
//         var data = argument[0];
//
//         agoraToken = data['token'];
//         agoraChannelName = data['channel_id'];
//         setupVoiceSDKEngine();
//       } else {
//         print('generate token_________________');
//         generateToken();
//       }
//     });
//   }
//
//   Future generateToken() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       int? vId = prefs.getInt('userid');
//       agoraChannelName = 'utmessenger${vId}_${widget.frnd_id}';
//       print('channel :- $agoraChannelName');
//
//       agoraToken = await getRtcToken(
//         appId,
//         agoraAppCertificate,
//         agoraChannelName,
//       );
//       print("call token:- $agoraToken");
//
//       ///for calling
//       setupVoiceSDKEngine();
//
//       sendNotification(agoraToken, agoraChannelName, "voice_call");
//     } catch (e) {
//       // ignore: avoid_print
//       print("Exception in gettting token: ${e.toString()}");
//     }
//   }
//
//   Future<dynamic> getRtcToken(
//       String appId, String appCertificate, String channelName)
//   async {
//     try {
//       var request = http.MultipartRequest(
//           'POST',
//           Uri.parse(
//               AppUrl.generateToken));
//       request.fields.addAll({
//         'appID': appId,
//         'appCertificate': appCertificate,
//         'user': channelName,
//       });
//       http.StreamedResponse response = await request.send();
//
//       if (response.statusCode == 200) {
//         var result = await response.stream.bytesToString();
//         var finalResult = jsonDecode(result);
//
//         return finalResult['rtmToken'];
//       } else {
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       print("Exception in getRtcToken :-$e");
//     }
//   }
//
//   sendNotification(String token, String channel, String type) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // String? myfcmtoken = prefs.getString('fcmtoken');
//     String? mytoken = prefs.getString('token');
//
//     var headers = {'Authorization': 'Bearer $mytoken'};
//     var request =
//         http.MultipartRequest('POST', Uri.parse(AppUrl.callNotification));
//     request.fields.addAll({
//       'friend_id': widget.frnd_id ?? '',
//       'channel_id': channel,
//       'token': token,
//       'type': type,
//     });
//     request.headers.addAll(headers);
//     print(request.fields);
//     http.StreamedResponse response = await request.send();
//     if (response.statusCode == 200) {
//       var result = await response.stream.bytesToString();
//       var finalResult = jsonDecode(result);
//       if (finalResult['status'] == false) {
//       } else {
//         Fluttertoast.showToast(msg: finalResult['message']);
//         if (kDebugMode) {
//           print("send notification api " + finalResult['message']);
//         }
//       }
//     }
//   }
//
//  Future<void> rejectCall(String friendId, String channel, String type, String userid) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     var headers = {'Authorization': 'Bearer $token'};
//     var request = http.MultipartRequest('POST', Uri.parse(AppUrl.callReject));
//     request.fields.addAll({
//       'friend_id':userid,
//       'channel_id': channel,
//       'type': type,
//       'user_id': friendId,
//     });
//     request.headers.addAll(headers);
//
//     print(request.fields);
//     http.StreamedResponse response = await request.send();
//     if (response.statusCode == 200) {
//       var result = await response.stream.bytesToString();
//
//       var data = jsonDecode(result);
//
//     } else if (response.statusCode == 403) {
//       // Fluttertoast.showToast(msg: "Invalid email or password");
//       if (kDebugMode) {
//         print("not send");
//       }
//     } else {
//       if (kDebugMode) {
//         print(response.reasonPhrase);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         global.showToast(
//             message: 'Please leave the call by pressing leave button');
//         return false;
//       },
//       child: Scaffold(
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.only(top: 20),
//               color: MyColor.primary,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Text(
//                           'User',
//                           style: TextStyle(
//                               fontWeight: FontWeight.w500, fontSize: 20),
//                         ),
//                         SizedBox(
//                           child: status(),
//                         ),
//                         const SizedBox(
//                           height: 15,
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Center(
//                 child: Container(
//                   height: 120,
//                   width: 120,
//                   alignment: Alignment.center,
//                   margin: EdgeInsets.only(bottom: 50),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.yellow),
//                     borderRadius: BorderRadius.circular(7),
//                   ),
//                   child: CircleAvatar(
//                       backgroundColor: Colors.transparent,
//                       radius: 60,
//                       // ignore: unnecessary_null_comparison
//                       child:
//                           // widget.profile == null || widget.profile == "" ?
//                           Image.asset(
//                         'assets/images/logo.png',
//                         fit: BoxFit.cover,
//                       )
//
//                       //     : CachedNetworkImage(
//                       //   imageUrl: '${global.imgBaseurl}${widget.profile}',
//                       //   imageBuilder: (context, imageProvider) =>
//                       //       CircleAvatar(
//                       //         radius: 60,
//                       //         backgroundColor: Colors.transparent,
//                       //         child: Image.network(
//                       //           '${global.imgBaseurl}${widget.profile}',
//                       //           fit: BoxFit.contain,
//                       //           height: 60,
//                       //         ),
//                       //       ),
//                       //   placeholder: (context, url) => const Center(
//                       //       child: CircularProgressIndicator()),
//                       //   errorWidget: (context, url, error) => Image.asset(
//                       //     'assets/images/no_customer_image.png',
//                       //     fit: BoxFit.contain,
//                       //     height: 60,
//                       //     width: 40,
//                       //   ),
//                       // ),
//                       ),
//                 ),
//               ),
//             )
//           ],
//         ),
//         bottomSheet: Container(
//           height: 100,
//           padding: const EdgeInsets.all(10),
//           color: MyColor.primary,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               InkWell(
//                 onTap: () {
//                   setState(() {
//                     callVolume = 100;
//                     isSpeaker = !isSpeaker;
//                   });
//                   onVolume(isSpeaker);
//                 },
//                 child: Icon(
//                   Icons.volume_up,
//                   color: isSpeaker ? Colors.blue : Colors.grey,
//                 ),
//               ),
//               InkWell(
//                 onTap: () {
//                   // global.callOnFcmApiSendPushNotifications(
//                   //   fcmTokem: "",
//                   //   title: "Astrologer Leave call",
//                   //   subTitle: "",
//                   //   sendData: {},
//                   // );
//                   leave();
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(10),
//                   margin: const EdgeInsets.only(right: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: const Icon(
//                     Icons.phone,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () {
//                   setState(() {
//                     isMuted = !isMuted;
//                     log('mute $isMuted');
//                   });
//                   onMute(isMuted);
//                 },
//                 child: Icon(
//                   Icons.mic_off,
//                   color: isMuted ? Colors.blue : Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> setupVoiceSDKEngine() async {
//     // retrieve or request microphone permission
//     await [Permission.microphone].request();
//     //createClient();
//     //agoraEngine.startAudioRecording(config);
//     //create an instance of the Agora engine
//     agoraEngine = createAgoraRtcEngine();
//     await agoraEngine.initialize(RtcEngineContext(appId: appId));
//
//
//     agoraEngine.setEnableSpeakerphone(false);
//
//
//     // Register the event handler
//     agoraEngine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           // ignore: avoid_print
//           print('joined${connection.localUid}');
//         },
//         onUserJoined: (RtcConnection connection, int remoteUId, int elapsed) {
//           setState(() {
//             remoteUid = remoteUId;
//             startCallTimer();
//           });
//           // ignore: avoid_print
//           print("RemoteId for call$remoteUid");
//         },
//         onUserOffline: (RtcConnection connection, int remoteUId,
//             UserOfflineReasonType reason) {
//           setState(() {
//             remoteUid = null;
//           });
//           // ignore: avoid_print
//           print('remote offline');
//           leave();
//         },
//         onRtcStats: (connection, stats) {},
//       ),
//     );
//
//     //onVolume(isSpeaker);
//     onMute(isMuted);
//     join();
//   }
//
//   void startCallTimer() {
//     _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
//       });
//     });
//   }
//
//   void stopCallTimer() {
//     _callTimer?.cancel();
//   }
//
//   String formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
//   }
//
//   Widget status() {
//     String statusText;
//     if (remoteUid == null) {
//       statusText = 'Calling...';
//       return Text(statusText);
//     } else {
//       statusText = 'Calling in progress';
//       return Text(formatDuration(_callDuration));
//       //   CountdownTimer(
//       //   endTime: DateTime.now().millisecondsSinceEpoch + 1000 * 300,
//       //   widgetBuilder: (_, CurrentRemainingTime? time) {
//       //     if (time == null) {
//       //       return const Text('00 min 00 sec');
//       //     }
//       //     return Padding(
//       //       padding: const EdgeInsets.only(left: 10),
//       //       child: time.min != null
//       //           ? Text('${time.min} min ${time.sec} sec',
//       //           style: const TextStyle(fontWeight: FontWeight.w500))
//       //           : Text(
//       //         '${time.sec} sec',
//       //         style: const TextStyle(fontWeight: FontWeight.w500),
//       //       ),
//       //     );
//       //   },
//       //   onEnd: () {
//       //     if (remoteUid != null) {
//       //       leave();
//       //     }
//       //   },
//       // );
//     }
//   }
//
//   void join() async {
//     // Set channel options including the client role and channel profile
//     ChannelMediaOptions options = const ChannelMediaOptions(
//       clientRoleType: ClientRoleType.clientRoleBroadcaster,
//       channelProfile: ChannelProfileType.channelProfileCommunication,
//     );
//
//
//     await agoraEngine.joinChannel(
//       token: agoraToken,
//       channelId: agoraChannelName,
//       options: options,
//       uid: uid,
//     );
//
//   }
//
//   void onMute(bool mute) {
//     agoraEngine.muteLocalAudioStream(mute);
//   }
//
//   void onVolume(bool isSpeaker) async {
//     await agoraEngine.setEnableSpeakerphone(isSpeaker);
//   }
//
//   void leave() {
//     if (mounted) {
//       setState(() {
//         remoteUid = null;
//       });
//     }
//     if (timer != null) {
//       timer!.cancel();
//     }
//     if (secTimer != null) {
//       secTimer!.cancel();
//     }
//     agoraEngine.leaveChannel();
//     agoraEngine.release(sync: true);
//     Navigator.pop(context);
//   }
//
//   @override
//   void dispose() {
//     if (timer != null) {
//       timer!.cancel();
//     }
//     if (secTimer != null) {
//       secTimer!.cancel();
//     }
//     stopCallTimer();
//     super.dispose();
//   }
//
//  firebaseOpenAppMessage (){
//    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//
//      String? title = message.notification?.title;
//      String? body = message.notification?.body;
//      String? messageType = message.data['noti_type'] ?? 'text';
//
//      if(messageType == 'reject_call'){
//        leave();
//      }
//    });
//  }
// }
