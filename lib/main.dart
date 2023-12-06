import 'package:flutter/material.dart';
import 'package:simple_chat_app/repositories/message_repo.dart';
import 'package:simple_chat_app/services/api_client.dart';
import 'package:simple_chat_app/services/web_socket_client.dart';

import 'screens/screens.dart';
import 'widgets/widgets.dart';

final apiClient = ApiClient(tokenProvider: () async {
  return '';
});

final WebSocketClient webSocketClient = WebSocketClient();
final MessageRepo messageRepo = MessageRepo(
  apiClient: apiClient,
  webSocketClient: webSocketClient,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatRoomScreen(chatRoom: chatRoom),
    );
  }
}
