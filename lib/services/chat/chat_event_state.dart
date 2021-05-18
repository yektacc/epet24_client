import 'package:meta/meta.dart';
import 'package:store/common/bloc_state_event.dart';
import 'package:store/services/chat/chat_repository.dart';

import 'model.dart';

@immutable
abstract class ChatEvent extends BlocEvent {}

@immutable
abstract class ChatState extends BlocState {}

// STATES *******************************

class FullLoading extends ChatState {
  FullLoading();

  @override
  String toString() {
    return "STATE: full loading";
  }
}

class PartialLoading extends ChatState {
  final List<SimpleMessage> messages;

  PartialLoading(this.messages);

  @override
  String toString() {
    return "STATE: partial loading";
  }
}

class MessagesLoaded extends ChatState {
  final Chat chat;
  final List<SimpleMessage> messages;

  MessagesLoaded(this.messages, this.chat);

  @override
  String toString() {
    return "STATE: loaded";
  }
}

class FailedLoadingMessages extends ChatState {
  @override
  String toString() {
    return "STATE: failed";
  }
}

// EVENTS *******************************

class SendMessage extends ChatEvent {
  final SimpleMessage message;

  SendMessage(this.message);

  @override
  String toString() {
    return "send message: $message";
  }
}

class UpdateMessages extends ChatEvent {}

class UpdateMessagesWithOne extends UpdateMessages {
  final FullMessage newMessage;

  UpdateMessagesWithOne(this.newMessage);
}

class SeenMessages extends ChatEvent {
  final Chat chat;

  SeenMessages(this.chat);
}
