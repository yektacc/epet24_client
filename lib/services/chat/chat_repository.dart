import 'package:get_it/get_it.dart';
import 'package:store/common/constants.dart';
import 'package:store/data_layer/netclient.dart';
import 'package:store/services/chat/model.dart';
import 'package:store/store/login_register/login_status/login_status_bloc.dart';
import 'package:store/store/login_register/login_status/login_status_event_state.dart';

//enum SenderType { USER, CENTER }

class ChatRepository {
  final ChatUser owner;
  final Net _net;

//  String _sessionId;

  ChatRepository(this._net, this.owner);

  Future<int> startDirectChatWith(ChatUser to, String sessionId) async {
    var srvCenterId;

    if (owner is ClientChatUser && to is CenterChatUser) {
      srvCenterId = to.srvCenterId;
    } else {
      throw (Exception('the types arent valid for starting chat'));
    }

    var res = await _net.post(EndPoint.START_CHAT, cacheEnabled: false, body: {
      'session_id': sessionId,
      'srv_center_id': srvCenterId,
      'is_broadcast': '0'
    });

    if (res is SuccessResponse) {
      var chatId = Map.of(res.data)['id'];
      return chatId;
    } else {
      Helpers.showErrorToast();
      return -1;
    }
  }

  Future<bool> startBroadcastChat(String message, String sessionId) async {
    if (owner is ClientChatUser) {
      var res1 = await _net.post(EndPoint.START_CHAT,
          cacheEnabled: false,
          body: {
            'session_id': (sessionId),
            'is_broadcast': '1',
            'broadcast_title': message
          });

      if (res1 is SuccessResponse) {
        var chatId = res1.data['id'].toString();

        await Future.delayed(Duration(seconds: 5));
        var res2 =
            await _net.post(EndPoint.SEND_MESSAGE, cacheEnabled: false, body: {
          'app_user_id': (owner as ClientChatUser).appUserId.toString(),
          'sender': 'user',
          'message': message.trim().toString(),
          'chat_id': chatId,
          'is_broadcast': "1"
        });

        if (res2 is SuccessResponse) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      throw (Exception("the types aren't valid for starting chat"));
    }
  }

  Future<bool> sendMessageTo(FullMessage fullMessage) async {
    /*  var appUserId;
    var srvCenterId;
    var sender;

    if (owner is ClientChatUser && to is CenterChatUser) {
      appUserId = (owner as ClientChatUser).appUserId;
      srvCenterId = to.srvCenterId;
      sender = 'user';
    } else if (owner is CenterChatUser && to is ClientChatUser) {
      appUserId = to.appUserId;
      srvCenterId = (owner as CenterChatUser).srvCenterId;
      sender = 'srv_center';
    } else {
      throw (Exception('the types arent valid'));
    }*/

    var res =
        await _net.post(EndPoint.SEND_MESSAGE, cacheEnabled: false, body: {
      'app_user_id': fullMessage.appUserId.toString(),
      'srv_center_id': fullMessage.srvCenterId.toString(),
      'sender': fullMessage.sender,
      'message': fullMessage.text,
      'chat_id': fullMessage.chatId.toString(),
      'is_broadcast': '0'
    });

    return res is SuccessResponse;
  }

  Future<bool> acceptBroadcastChat(
      SimpleMessage message, OpenBroadcastChat bChat) async {
    if (owner is CenterChatUser) {
      var res =
          await _net.post(EndPoint.SEND_MESSAGE, cacheEnabled: false, body: {
        'app_user_id': bChat.other.id.toString(),
        'srv_center_id': owner.id.toString(),
        'sender': 'srv_center',
        'message': message.text ?? '',
        'is_broadcast': "1",
        'chat_id': bChat.chatId.toString()
      });

      return res is SuccessResponse;
    } else {
      throw Exception('user cant accept broadcast chat');
    }
  }

//  Future<List<FullMessage>> getAllMessages() async {
//    var res;
//    if (owner is ClientChatUser) {
//      res = await _net.post(EndPoint.GET_CHAT_WITH, cacheEnabled: false, body: {
//        'app_user_id': (owner as ClientChatUser).appUserId,
//      });
//    } else if (owner is CenterChatUser) {
//      res = await _net.post(EndPoint.GET_ALL_CENTER_CHATS,
//          cacheEnabled: false,
//          body: {'srv_center_id': (owner as CenterChatUser).srvCenterId});
//    } else {
//      throw (Exception('the types arent valid'));
//    }
//
//    if (res is SuccessResponse) {
//      var list = List<Map<String, dynamic>>.from(res.data);
//
//      var messages = list.map((json) => FullMessage.fromJson(json)).toList();
//
//      return messages;
//    } else {
//      Helpers.showErrorToast();
//      return null;
//    }
//  }

  Future<List<Chat>> getAllChats() async {
    if (owner is CenterChatUser) {
      var normalChatsRes = await _net.post(EndPoint.GET_ALL_CENTER_CHATS,
          cacheEnabled: false,
          body: {'srv_center_id': (owner as CenterChatUser).srvCenterId});

      var unassignedBroadcastChats = await _net.post(
          EndPoint.GET_UNASSIGNED_BROADCAST_CHATS,
          cacheEnabled: false,
          body: {'is_broadcast': "1"});

      if (normalChatsRes is SuccessResponse &&
          unassignedBroadcastChats is SuccessResponse) {
        var normal = List<Map<String, dynamic>>.from(normalChatsRes.data);
        var unassignedBroad =
            List<Map<String, dynamic>>.from(unassignedBroadcastChats.data);

        print('start parsing chats');

        List<Chat> allChats = normal
                .map((chat) => Chat.fromJson(chat, owner))
                .toList() +
            unassignedBroad.map((chat) => Chat.fromJson(chat, owner)).toList();

        print('aall chats ready: $allChats');

        return allChats;
      } else {
        Helpers.showErrorToast();
        return null;
      }
    } else if (owner is ClientChatUser) {
      var res = await _net.post(EndPoint.GET_ALL_USER_CHATS,
          cacheEnabled: false,
          body: {'app_user_id': (owner as ClientChatUser).appUserId});

      if (res is SuccessResponse) {
        var chatsJson = List<Map<String, dynamic>>.from(res.data);

        List<Chat> allChats =
            chatsJson.map((chat) => Chat.fromJson(chat, owner)).toList();

        print('all chats ready: $allChats');

        return allChats;
      } else {
        Helpers.showErrorToast();
        return null;
      }
    } else {
      throw (Exception('the types arent valid'));
    }
  }

  Future<bool> seenChat(chatId) async {
    var res = await _net.post(EndPoint.SEEN_CHAT, cacheEnabled: false, body: {
      'chat_id': chatId.toString(),
    });

    return res is SuccessResponse;
  }

  Future<List<FullMessage>> getMessagesWithId(int chatId) async {
    var res;

    res = await _net.post(EndPoint.GET_CHAT_BY_ID,
        cacheEnabled: false, body: {"chat_id": chatId.toString()});

    if (res is SuccessResponse) {

      var list = List<Map<String, dynamic>>.from(res.data);
      // bool isBroadcast = list[0]["is_broadcast"] == 1;
      var messages = list.map((json) => FullMessage.fromJson(json)).toList();

     /* if(isBroadcast) {
        return [messages.first];
      }*/
      return messages;
    } else {
      Helpers.showToast('خطا در بارگذاری پیام ها');
      return [];
    }
  }
}
