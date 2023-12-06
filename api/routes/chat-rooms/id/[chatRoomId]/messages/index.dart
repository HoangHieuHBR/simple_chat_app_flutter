import 'dart:async';
import 'dart:io';

import 'package:api/src/repositories/message_repository.dart';
import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context, String chatRoomId) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, chatRoomId);
    case HttpMethod.post:
    case HttpMethod.put:
    case HttpMethod.delete:
    case HttpMethod.patch:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String chatRoomId) async {
  final messageRepo = context.read<MessageRepository>();
  
  try {
    final messages = await messageRepo.fetchMessages(chatRoomId);
    return Response.json(
      body: {'messages': messages},
    );
  } catch (e) {
    return Response.json(
        body: {'error': e.toString()},
        statusCode: HttpStatus.internalServerError);
  }
}
