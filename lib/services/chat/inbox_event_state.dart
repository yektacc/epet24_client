import 'package:meta/meta.dart';
import 'package:store/common/bloc_state_event.dart';
import 'package:store/services/chat/chat_bloc.dart';

@immutable
abstract class InboxEvent extends BlocEvent {}

@immutable
abstract class InboxState extends BlocState {}

// STATES *******************************

class InboxLoading extends InboxState {
  InboxLoading();

  @override
  String toString() {
    return "STATE: loading";
  }
}

class InboxLoaded extends InboxState {
  final List<ChatBloc> chats;
  final int newMessages;

  InboxLoaded(this.chats, this.newMessages);

  @override
  String toString() {
    return "STATE: loaded";
  }
}

class InboxLoadingFailed extends InboxState {
  @override
  String toString() {
    return "STATE: failed";
  }
}

class SendingBroadcast extends InboxState {
  @override
  String toString() {
    return "STATE: sending broadcast";
  }
}

class BroadcastSent extends InboxState {
  BroadcastSent();

  @override
  String toString() {
    return "STATE: broadcast message sent";
  }
}

class InitiatingChat extends InboxState {
  @override
  String toString() {
    return "STATE: sending broadcast";
  }
}

class ChatInitiated extends InboxState {
  final ChatBloc bloc;

  ChatInitiated(this.bloc);

  @override
  String toString() {
    return "STATE: chat initiated successfully";
  }
}

class ChatInitiationFailed extends InboxState {
  ChatInitiationFailed();

  @override
  String toString() {
    return "STATE: chat initation failed";
  }
}

// EVENTS *******************************
/*
class SendMessage extends InboxEvent {
  final Message message;

  SendMessage(this.message);
}*/

class UpdateInbox extends InboxEvent {}

class SendBroadcast extends InboxEvent {
  final String message;
  final String sessionId;

  SendBroadcast(this.message, this.sessionId);
}

class InitiateChatWithCenter extends InboxEvent {
  final int centerId;
  final String centerName;

  InitiateChatWithCenter(this.centerId, this.centerName);
}
