import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:store/common/constants.dart';
import 'package:store/data_layer/GRepo.dart';
import 'package:store/services/chat/chat_amqp_repository.dart';
import 'package:store/services/chat/inbox_manager.dart';
import 'package:store/services/chat/model.dart';

import 'chat_event_state.dart';
import 'chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final AMQPRepository _amqpRepo;
  final List<SimpleMessage> simpleMessages = [];

  final Chat chat;

  ChatBloc(
    this.chat,
    this._chatRepository,
  ) : _amqpRepo = AMQPRepository(chat) {
    _amqpRepo.newMessages().listen((msg) {
      dispatch(UpdateMessagesWithOne(msg));
    });
  }

  @override
  ChatState get initialState => FullLoading();

  @override
  void onError(Object error, StackTrace stacktrace) {
    print(error);
    print(stacktrace);
  }

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is SendMessage) {
      if (chat is OpenBroadcastChat) {
        yield FullLoading();
        var sent =
            await _chatRepository.acceptBroadcastChat(event.message, chat);
        if (sent) {
          dispatch(UpdateMessages());
          GetIt.I<InboxManager>().syncInboxes();
        } else {
          Helpers.showToast('خطا در ارسال پیام، لطفا مجددا تلاش نمایید');
        }
      } else if (chat is DirectChat) {
        yield FullLoading();
        final fullMessage = event.message.toFullMessage(chat);
        var sent = await _chatRepository.sendMessageTo(fullMessage);
        _amqpRepo.send(fullMessage);

        if (sent) {
          dispatch(UpdateMessagesWithOne(fullMessage));
        } else {
          Helpers.showToast('خطا در ارسال پیام، لطفا مجددا تلاش نمایید');
        }
      }
    } else if (event is UpdateMessages) {
      if (event is UpdateMessagesWithOne) {
        yield PartialLoading(simpleMessages);
        simpleMessages.add(event.newMessage.toSimpleMessage(chat.owner));
        yield MessagesLoaded(simpleMessages, chat);
      } else {
        yield FullLoading();
        var loadedMessages =
            await _chatRepository.getMessagesWithId(chat.chatId);

        if (loadedMessages != null && loadedMessages.isNotEmpty) {
          simpleMessages.clear();
          simpleMessages.addAll(
              loadedMessages.map((full) => full.toSimpleMessage(chat.owner)));

          yield MessagesLoaded(
              loadedMessages
                  .map((msg) => msg.toSimpleMessage(chat.owner))
                  .toList(),
              chat);
        } else {
          yield FailedLoadingMessages();
        }
      }
    } else if (event is SeenMessages) {
      await _chatRepository.seenChat(event.chat.chatId);
    }
  }

  @override
  void dispose() {
    _amqpRepo.dispose();
    super.dispose();
  }
}
