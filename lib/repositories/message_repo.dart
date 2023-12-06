import 'dart:async';
import 'dart:convert';

import 'package:models/models.dart';
import 'package:simple_chat_app/services/api_client.dart';

import '../services/web_socket_client.dart';

class MessageRepo {
  final ApiClient apiClient;
  final WebSocketClient webSocketClient;
  StreamSubscription? _messageSubscription;

  MessageRepo({
    required this.apiClient,
    required this.webSocketClient,
  });

  Future<void> createMessage(Message message) async {
    var payload = {'event': 'message.create', 'data': message.toJson()};
    webSocketClient.send(jsonEncode(payload));
  }

  Future<List<Message>> fetchMessages(String chatRoomId) async {
    final resposne = await apiClient.fetchMessages(chatRoomId);

    final messages = resposne['messages']
        .map<Message>((message) => Message.fromJson(message))
        .toList();

    return messages;
  }

  void subscribeToMessageUpdates(
    void Function(Map<String, dynamic>) onMessageReceived,
  ) {
    _messageSubscription = webSocketClient.messageUpdates().listen(
      (message) {
        onMessageReceived(message);
      },
    );
  }

  void unsubscribeFromMessageUpdates() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }
}
