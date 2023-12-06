import 'package:flutter/material.dart';
import 'package:models/models.dart';

import '../main.dart';
import '../widgets/widgets.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messageList = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startWebSocket();

    messageRepo.subscribeToMessageUpdates((messageData) {
      final message = Message.fromJson(messageData);
      if (message.chatRoomId == widget.chatRoom.id) {
        messageList.add(message);
        messageList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        setState(() {});
      }
    });
  }

  void _sendMessage() async {
    final message = Message(
      chatRoomId: widget.chatRoom.id,
      senderUserId: userId1,
      receiverUserId: userId2,
      content: _messageController.text,
      createdAt: DateTime.now(),
    );

    await messageRepo.createMessage(message);
    _messageController.clear();
  }

  _loadMessages() async {
    final messages = await messageRepo.fetchMessages(widget.chatRoom.id);

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    setState(() {
      messageList.addAll(messages);
    });
  }

  _startWebSocket() {
    webSocketClient.connect(
      'ws://localhost:8080/ws',
      {
        'Authorization': 'Bearer ....',
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    final currentParticipant = widget.chatRoom.participants.firstWhere(
      (user) => user.id == userId1,
    );

    final otherParticipant = widget.chatRoom.participants.firstWhere(
      (user) => user.id != currentParticipant.id,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Avatar(
              imageUrl: otherParticipant.avatarUrl,
              radius: 18,
            ),
            Text(
              otherParticipant.username,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: (viewInsets.bottom > 0) ? 8 : 5,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final message = messageList[index];

                    final showImage = index + 1 == messageList.length ||
                        messageList[index + 1].senderUserId !=
                            message.senderUserId;

                    return Row(
                      mainAxisAlignment: (message.senderUserId != userId1)
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (showImage && message.senderUserId == userId1)
                          Avatar(
                            imageUrl: otherParticipant.avatarUrl,
                            radius: 12,
                          ),
                        MessageBubble(message: message),
                        if (showImage && message.senderUserId != userId1)
                          Avatar(
                            imageUrl: currentParticipant.avatarUrl,
                            radius: 12,
                          ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(100),
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _sendMessage,
                          icon: Icon(Icons.send),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
