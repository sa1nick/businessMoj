// import 'dart:developer';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:agora_chat_sdk/agora_chat_sdk.dart';
//
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ut_messenger/helper/api.dart';
// import 'package:ut_messenger/helper/colors.dart';
// import 'package:ut_messenger/main.dart';
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:mime/mime.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:ut_messenger/model/friendmodel.dart';
// import 'package:ut_messenger/services/agora_chat_service.dart';
// import 'package:uuid/uuid.dart';
//
// import '../helper/session.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//
//   ScrollController scrollController = ScrollController();
//   String? _messageContent, _chatId;
//   final List<String> _logText = [];
//   List<types.Message> _messages = [];
//   List<ChatMessage> messagesList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _initSDK();
//     _addChatListener();
//   }
//
//   @override
//   void dispose() {
//     ChatClient.getInstance.chatManager.removeEventHandler('UNIQUE_HANDLER_ID');
//     ChatClient.getInstance.chatManager.removeMessageEvent('UNIQUE_HANDLER_ID');
//     _signOut();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('chat'),
//       ),
//       body: Container(
//         padding: const EdgeInsets.only(left: 10, right: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.max,
//           children: [
//             Expanded(
//               child: Chat(
//                 messages: _messages,
//                 // onAttachmentPressed: _handleAttachmentPressed,
//                 onMessageTap: (context, message) async {
//                   if (message is types.FileMessage) {
//                     await OpenFilex.open(message.uri);
//                   }
//                 },
//                 onPreviewDataFetched: (message, previewData) {
//                   final index = _messages.indexWhere((m) => m.id == message.id);
//                   if (index >= 0) {
//                     setState(() {
//                       _messages[index] = (_messages[index] as types.TextMessage)
//                           .copyWith(previewData: previewData);
//                     });
//                   }
//                 },
//                 onSendPressed: _sendMessage,
//                 showUserAvatars: true,
//                 showUserNames: true,
//                 user: types.User(id: 'user3'),
//               ),
//             ),
//             /*Flexible(
//               child: ListView.builder(
//                 controller: scrollController,
//                 itemBuilder: (_, index) {
//                   return Text(_logText[index]);
//                 },
//                 itemCount: _logText.length,
//               ),
//             ),*/
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _initSDK() async {
//     ChatOptions options = ChatOptions(
//       appKey: AgoraChatConfig.appKey,
//       autoLogin: false,
//     );
//     await ChatClient.getInstance.init(options);
//     await ChatClient.getInstance.startCallback();
//     getToken();
//   }
//
//   void _addChatListener() {
//     ChatClient.getInstance.chatManager.addEventHandler(
//       'UNIQUE_HANDLER_ID',
//       ChatEventHandler(onMessagesReceived: onMessagesReceived),
//     );
//
//     ChatClient.getInstance.chatManager.addMessageEvent(
//       'UNIQUE_HANDLER_ID',
//       ChatMessageEvent(
//         onSuccess: (msgId, msg) {
//           _addLogToConsole("send message: $_messageContent");
//         },
//         onError: (msgId, msg, error) {
//           _addLogToConsole(
//             "send message failed, code: ${error.code}, desc: ${error.description}",
//           );
//         },
//       ),
//     );
//
//     _signIn();
//   }
//
//   void _signIn() async {
//     try {
//       await ChatClient.getInstance.loginWithAgoraToken(
//         AgoraChatConfig.userId,
//         AgoraChatConfig.agoraToken,
//       );
//
//       messagesList = await getChatHistory('user3');
//
//       print('hkfhdkshfs${messagesList.length}______');
//
//       for (var msg in messagesList) {
//         ChatTextMessageBody body = msg.body as ChatTextMessageBody;
//
//         _addMessage(
//           types.TextMessage(
//             author: types.User(id: msg.from!),
//             id: msg.msgId,
//             text: body.content,
//             createdAt: msg.serverTime,
//           ),
//         );
//       }
//
//       _addLogToConsole("login succeed, userId: ${AgoraChatConfig.userId}");
//     } on ChatError catch (e) {
//       _addLogToConsole("login failed, code: ${e.code}, desc: ${e.description}");
//     }
//   }
//
//   void _signOut() async {
//     try {
//       await ChatClient.getInstance.logout(true);
//       // _addLogToConsole("sign out succeed");
//     } on ChatError catch (e) {
//       // _addLogToConsole(
//       //     "sign out failed, code: ${e.code}, desc: ${e.description}");
//     }
//   }
//
//   void _sendMessage(types.PartialText text) async {
//     // if (_chatId == null || _messageContent == null) {
//     //   _addLogToConsole("single chat id or message content is null");
//     //   return;
//     // }
//
//     var msg = ChatMessage.createTxtSendMessage(
//       targetId: 'user3',
//       content: text.text,
//     );
//     messagesList.insert(0, msg);
//     ChatTextMessageBody body = msg.body as ChatTextMessageBody;
//
//     _addMessage(
//       types.TextMessage(
//         author: types.User(id: msg.from!),
//         id: msg.msgId,
//         text: body.content,
//         createdAt: msg.serverTime,
//       ),
//     );
//
//     ChatClient.getInstance.chatManager.sendMessage(msg);
//   }
//
//   void onMessagesReceived(List<ChatMessage> messages) {
//     for (var msg in messages) {
//       switch (msg.body.type) {
//         case MessageType.TXT:
//           {
//             ChatTextMessageBody body = msg.body as ChatTextMessageBody;
//             _addNewMessage(msg);
//             _addLogToConsole(
//               "receive text message: ${body.content}, from: ${msg.from}",
//             );
//           }
//           break;
//         case MessageType.IMAGE:
//           {
//             _addLogToConsole(
//               "receive image message, from: ${msg.from}",
//             );
//           }
//           break;
//         case MessageType.VIDEO:
//           {
//             _addLogToConsole(
//               "receive video message, from: ${msg.from}",
//             );
//           }
//           break;
//         case MessageType.LOCATION:
//           {
//             _addLogToConsole(
//               "receive location message, from: ${msg.from}",
//             );
//           }
//           break;
//         case MessageType.VOICE:
//           {
//             _addLogToConsole(
//               "receive voice message, from: ${msg.from}",
//             );
//           }
//           break;
//         case MessageType.FILE:
//           {
//             _addLogToConsole(
//               "receive image message, from: ${msg.from}",
//             );
//           }
//           break;
//         case MessageType.CUSTOM:
//           {
//             _addLogToConsole(
//               "receive custom message, from: ${msg.from}",
//             );
//           }
//           break;
//         case MessageType.COMBINE:
//           {
//             _addLogToConsole(
//               "receive combine message, from: ${msg.from}",
//             );
//           }
//           break;
//         default:
//           break;
//       }
//     }
//   }
//
//   void _addNewMessage(ChatMessage message) {
//     messagesList.insert(0, message);
//
//     ChatTextMessageBody body = message.body as ChatTextMessageBody;
//
//     _addMessage(
//       types.TextMessage(
//         author: types.User(id: message.from!),
//         id: message.msgId,
//         text: body.content,
//         createdAt: message.serverTime,
//       ),
//     );
//   }
//
//   void _addMessage(types.Message message) {
//     setState(() {
//       _messages.insert(0, message);
//     });
//   }
//
//   void getToken() async {
//     String token = await ChatClient.getInstance.getAccessToken();
//
//     log('token:  ${token}');
//   }
//
//   void _addLogToConsole(String log) {
//     _logText.add(_timeString + ": " + log);
//     setState(() {
//       scrollController.jumpTo(scrollController.position.maxScrollExtent);
//     });
//   }
//
//   String get _timeString {
//     return DateTime.now().toString().split(".").first;
//   }
//
//   Future<List<ChatMessage>> getChatHistory(String otherUserId) async {
//     List<ChatMessage> messages = [];
//     try {
//       final chatConversation =
//           await ChatClient.getInstance.chatManager.getConversation(
//         otherUserId,
//         type: ChatConversationType.Chat,
//       );
//
//       final chatHistory = await ChatClient.getInstance.chatManager
//           .fetchHistoryMessages(
//               conversationId: chatConversation?.id ?? '',
//               pageSize: 20,
//               type: ChatConversationType.Chat);
//
//       messages = chatHistory.data;
//
//       return messages;
//     } catch (e) {
//       print('Error loading chat history: $e');
//       return messages;
//     }
//   }
// }
//
// class AgoraChatConfig {
//   static const String appKey = "611242003#1433668";
//   static const String userId = "user3";
//   static const String agoraToken =
//       "007eJxTYDD1mXbo0I9DJZHxD/LmuCjMYsubN7nXZDabji8j60Q1YSYFhiQjEyODJHPLRANDE5NkY+MkoyRTo9TUJDNLw2Rz4zQLuUUW6Q2BjAxpJ4NZGBlYGRiBEMRXYbA0NEpNSjYz0E00tEjSNTRMTdO1MDI10000N06xNDSwTE2zMAUAIZIjfA==";
// }
