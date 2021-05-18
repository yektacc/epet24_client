import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:store/common/constants.dart';
import 'package:store/data_layer/GRepo.dart';
import 'package:store/data_layer/netclient.dart';
import 'package:store/services/chat/chat_bloc.dart';
import 'package:store/services/chat/chat_event_state.dart';
import 'package:store/services/chat/chat_repository.dart';
import 'package:store/store/login_register/login_status/login_status_bloc.dart';
import 'package:store/store/login_register/login_status/login_status_event_state.dart';

import 'inbox_event_state.dart';
import 'model.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final ChatRepository _chatRepository;
  final ChatUser _owner;
  final List<ChatBloc> _chatBlocs = [];

  InboxBloc(this._owner, Net net)
      : this._chatRepository = ChatRepository(net, _owner);

  @override
  InboxState get initialState => InboxLoading();

  @override
  Stream<InboxState> mapEventToState(InboxEvent event) async* {
    if (event is UpdateInbox) {
      var chats = await _chatRepository.getAllChats();

      yield InboxLoading();

      int newMsgCount = 0;
      chats.forEach((chat) {
        newMsgCount += chat.newMsg;
      });

      if (chats != null) {
        var blocs = await _makeChatBlocs(chats);
        _chatBlocs.clear();
        _chatBlocs.addAll(blocs);
        yield InboxLoaded(blocs, newMsgCount);
      } else {
        yield InboxLoadingFailed();
      }
    } else if (event is SendBroadcast) {
      yield SendingBroadcast();
      var success = await _chatRepository.startBroadcastChat(
          event.message, event.sessionId);
      if (success) {
        yield BroadcastSent();
      } else {
        yield InboxLoadingFailed();
      }
    } else if (event is InitiateChatWithCenter) {
      var loginState = GetIt.instance<LoginStatusBloc>().currentState;

      if (loginState is IsLoggedIn) {
        yield InitiatingChat();

        var other = CenterChatUser(event.centerId);
        var chatId = await _chatRepository.startDirectChatWith(
            other, loginState.user.sessionId);
        if (chatId != -1) {
          var bloc = ChatBloc(
              DirectChat(_owner, other, chatId, 0, event.centerName),
              _chatRepository);
          yield ChatInitiated(bloc);
        } else {
          yield ChatInitiationFailed();
        }
      } else {
        yield ChatInitiationFailed();
      }
    }
  }

  @override
  void dispose() {
    _chatBlocs.forEach((bloc) {
      bloc.dispose();
    });
    super.dispose();
  }

  Future<List<ChatBloc>> _makeChatBlocs(List<Chat> chats) async {
    return chats.map((c) {
      return ChatBloc(c, _chatRepository);
    }).toList();
  }
}
