import 'package:store/services/chat/chat_amqp_repository.dart';
import 'package:store/services/chat/model.dart';
import 'package:flutter/widgets.dart';


void main() {
  final ChatUser owner = ClientChatUser(-1);
  final ChatUser other = CenterChatUser(-1);
  final Chat chat = DirectChat(owner, other, -1, 0, "test_chat");
  final AMQPRepository amqpRepo = AMQPRepository(chat);

  final msgToSend =
      SimpleMessage("test message amqp", true, false, "").toFullMessage(chat);

  amqpRepo.send(msgToSend);

  amqpRepo.newMessages().listen((event) {
    print("waiting for messages");
    print('new event: $event');
  });
}


