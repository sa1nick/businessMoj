// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart'as http;
//
// import '../helper/api.dart';
//
//
// const appId = 'c14b4eb96e5e4fe8a0a61cf94ab770bd';
//
//
// class CallScreen extends StatefulWidget {
//   String? frnd_id;
//    CallScreen({Key? key,this.frnd_id}) : super(key: key);
//
//   @override
//   _CallScreenState createState() => _CallScreenState();
// }
//
// class _CallScreenState extends State<CallScreen> {
//
//   String agoraAppCertificate = "db5684deb1df408aacb8067bf7a4acff";
//   String agoraToken = "";//"006c14b4eb96e5e4fe8a0a61cf94ab770bdIACxUnB3rttwt0N1eP8QvqgCx7dftmKtjFqnknLXQrGNl3Xi9dQAAAAAEADkIAEAqdU+ZwEA6AOBhj1n";
//   String agoraChannelName = "";//"utmessenger10_1";
//
//   int? _remoteUid;
//   RtcEngine? _engine; // Nullable RtcEngine
//   bool _isEngineReady = false; // Flag to check if the engine is ready
//   int isUserConnect = 1;
//   bool switchCamera = true,
//        audioMute = false,
//       openCamera = true;
//
//
//   @override
//   void initState() {
//     super.initState();
//     firebaseOpenAppMessage();
//     Future.microtask((){
//       if(ModalRoute.of(context)?.settings.arguments != null) {
//         final List argument = ModalRoute.of(context)?.settings.arguments as List;
//
//         print('${argument[0]}_______________');
//
//         var data = argument[0];
//
//         agoraToken = data['token'];
//         agoraChannelName = data['channel_id'];
//         initForAgora();
//       }else {
//         generateToken();
//       }
//
//       // setupVoiceSDKEngine();
//     });
//
//   }
//
//
//   Future generateToken() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       int? vId =  prefs.getInt('userid');
//       agoraChannelName = 'utmessenger${vId}_${widget.frnd_id}';
//       log('channel :- $agoraChannelName');
//       agoraToken = await getRtcToken(
//         appId,
//         agoraAppCertificate,
//         agoraChannelName,);
//
//
//        initForAgora();
//
//       sendNotification(agoraToken,agoraChannelName,"video_call");
//
//
//
//       print("call token:- $agoraToken");
//       // await sendCallToken(
//       //     agoraToken, agoraChannelName, widget.frnd_id as int);
//     } catch (e) {
//       // ignore: avoid_print
//       print("Exception in gettting token: ${e.toString()}");
//     }
//   }
//
//   Future<dynamic> getRtcToken(String appId, String appCertificate,String channelName) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(AppUrl.generateToken));
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
//         return finalResult['rtmToken'];
//       }
//       else {
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       print("Exception in getRtcToken :-$e");
//     }
//   }
//
//   sendNotification(String token ,String channel, String type) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // String? myfcmtoken = prefs.getString('fcmtoken');
//     String? mytoken = prefs.getString('token');
//
//     var headers = {
//       'Authorization': 'Bearer $mytoken'
//     };
//     var request = http.MultipartRequest('POST',Uri.parse(AppUrl.callNotification));
//     request.fields.addAll(
//         {
//           'friend_id': widget.frnd_id ?? '',
//           'channel_id': channel,
//           'token':token,
//           'type': type,
//         });
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
//           print("send notification api "+finalResult['message']);
//         }
//       }
//     }
//   }
//
//
//
//   Future<void> initForAgora() async {
//     // Request permissions
//     await [Permission.camera, Permission.microphone].request();
//
//     // Step 1: Create the engine
//     _engine = await createAgoraRtcEngine(); // Initialize the engine
//
//     // Step 2: Initialize the engine with context
//     await _engine!.initialize(
//       const RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//       ),
//     );
//
//     // Enable video module
//     await _engine!.enableVideo();
//
//     // Set event handlers
//     _engine!.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int uid) {
//
//           setState(() {
//             isUserConnect = 1;
//             _isEngineReady = true;// Mark the engine as ready
//           });
//         },
//         onUserJoined: (RtcConnection connection, int uid, int elapsed) {
//           print("Remote user $uid joined");
//           setState(() {
//             isUserConnect = 2;
//             _remoteUid = uid;
//
//           });
//         },
//         onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
//           print("Remote user $uid left channel");
//           setState(() {
//             isUserConnect = 3;
//             _remoteUid = null;
//             Navigator.pop(context);
//           });
//         },
//       ),
//     );
//
//     // Join the channel
//     await _engine!.joinChannel(
//       token: agoraToken,
//       channelId: agoraChannelName,
//       uid: 0,
//       options: ChannelMediaOptions(),
//     );
//   }
//
//   Future<void> _switchCamera() async {
//     await _engine?.switchCamera();
//     setState(() {
//       switchCamera = !switchCamera;
//     });
//   }
//
//   Future<void> _muteAudio() async {
//     // await _engine?.muteRemoteAudioStream(uid: _remoteUid!, mute: audioMute);
//     await _engine?.muteLocalAudioStream(audioMute);
//     setState(() {
//       audioMute = !audioMute;
//     });
//   }
//
//   Future<void> _muteLocalAudio() async {
//     await _engine?.muteLocalAudioStream(audioMute);
//     setState(() {
//       audioMute = !audioMute;
//     });
//   }
//
//   _openCamera() async {
//     await _engine?.enableLocalVideo(!openCamera);
//     setState(() {
//       openCamera = !openCamera;
//     });
//   }
//
//
//   @override
//   void dispose() {
//     // Dispose engine properly when leaving the channel
//     _engine?.leaveChannel();
//     _engine?.release();
//     super.dispose();
//   }
//
//   firebaseOpenAppMessage (){
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//
//       String? title = message.notification?.title;
//       String? body = message.notification?.body;
//       String? messageType = message.data['noti_type'] ?? 'text';
//
//       if(messageType == 'reject_call'){
//         print("call rejection");
//         _engine?.leaveChannel();
//         _engine?.release();
//         Navigator.pop(context);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Call'),
//       ),
//       body: _isEngineReady
//           ? Stack(
//         children: [
//           Center(
//             child: _renderRemoteVideo(),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(onPressed: (){
//                   _switchCamera();
//                 }, icon: const Icon(Icons.cameraswitch,size: 50,),),
//                 IconButton(onPressed: (){
//                   _openCamera();
//                 }, icon: Icon(!openCamera ? Icons.no_photography_outlined : Icons.photo_camera_outlined,size: 50,),),
//                 IconButton(onPressed: (){
//                   _muteAudio();
//                 }, icon:  Icon(!audioMute ? Icons.mic_off: Icons.mic,size: 50,),),
//                 IconButton(onPressed: (){
//                   _engine?.leaveChannel();
//                   _engine?.release();
//                   Navigator.pop(context);
//                 }, icon: const Icon(Icons.call_end,size: 50,color: Colors.red,),),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: SizedBox(
//                 width: 100,
//                 height: 200,
//                 child: Center(
//                   child: _renderLocalPreview(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       )
//           : const Center(
//         child: CircularProgressIndicator(), // Show loading until engine is ready
//       ),
//     );
//   }
//
//   Widget _renderLocalPreview() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: _engine!,
//           canvas: const VideoCanvas(uid: 0),
//         ),
//       ),
//     );
//   }
//
//   Widget _renderRemoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine!,
//           canvas: VideoCanvas(uid: _remoteUid!),
//           connection: RtcConnection(channelId: agoraChannelName),
//         ),
//       );
//     } else {
//       return Text(isUserConnect == 1 ? 'Connecting...' : isUserConnect == 2 ?'User Connected' : 'Call Ended' , textAlign: TextAlign.center,) ;
//
//     }
//   }
// }
