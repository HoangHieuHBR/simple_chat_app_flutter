import 'dart:convert';

import 'package:api/src/repositories/message_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final MessageRepository messageRepo = context.read<MessageRepository>();
  final handler = webSocketHandler((channel, protocol) {
    channel.stream.listen((message) {
      if (message is! String) {
        channel.sink.addError('Invalid message');
        return;
      }

      Map<String, dynamic> messageJson = jsonDecode(message);

      final event = messageJson['event'];
      final data = messageJson['data'];
      print('event: $event, data: $data');

      switch (event) {
        case 'message.create':
          messageRepo.createMessage(data).then(
            (message) {
              channel.sink.add(
                jsonEncode({
                  'event': 'message.created',
                  'data': message,
                }),
              );
            },
          ).catchError((err) {
            print('Something went wrong');
          });
          break;
        default:
          channel.sink.addError('Invalid event');
      }
    });
  });
  return handler(context);
}
