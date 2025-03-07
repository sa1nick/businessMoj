// import 'package:agora_chat_sdk/agora_chat_sdk.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
//
// class AgoraChatService {
//   static const String appKey = "611242003#1433668";
//
//   static Future<void> initialize() async {
//     try {
//       await ChatClient.getInstance.init(
//         ChatOptions(appKey: appKey),
//       );
//       print('Agora Chat SDK initialized successfully');
//     } catch (e) {
//       print('Error initializing Agora Chat SDK: $e');
//     }
//   }
//
//   static Future<void> agoraLogin(String userId, String password) async {
//     try {
//       // await ChatClient.getInstance.login(userId, password);
//
//       await ChatClient.getInstance.loginWithAgoraToken(userId, password);
//       print('Logged in as $userId');
//     } catch (e) {
//       print('Login error: $e');
//     }
//   }
//
//   static Future<List<ChatMessage>> getChatHistory(String otherUserId) async {
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
//
//   static Future<void> sendMessage(
//       types.PartialText message, String recipientId) async {
//     ChatMessage textMessage = ChatMessage.createTxtSendMessage(
//         targetId: recipientId, content: message.text, chatType: ChatType.Chat);
//
//     ChatClient.getInstance.chatManager.addMessageEvent(
//       "UNIQUE_HANDLER_ID",
//       ChatMessageEvent(
//         onSuccess: (msgId, msg) {
//           print('on message succeed');
//         },
//         onProgress: (msgId, progress) {
//           print('on message progress');
//         },
//         onError: (msgId, msg, error) {
//           print(
//             "on message failed, code: ${error.code}, desc: ${error.description}",
//           );
//         },
//       ),
//     );
//     //agoraChatClient.chatManager.sendMessage(textMessage);
//
//     if (await ChatClient.getInstance.isConnected()) {
//       await ChatClient.getInstance.chatManager.sendMessage(textMessage);
//       ChatClient.getInstance.chatManager
//           .removeMessageEvent("UNIQUE_HANDLER_ID");
//     }
//   }
// }
