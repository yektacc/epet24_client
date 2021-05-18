import 'package:http/http.dart';
import 'package:quiver/core.dart';
import 'package:store/common/constants.dart';
import 'package:store/services/chat/chat_repository.dart';

// message

abstract class Message {}

class FullMessage extends Message {
  final int id;
  final int chatId;
  final String text;
  final String date;
  final int srvCenterId;
  final int appUserId;
  final String sender;
  final bool seen;

  FullMessage(this.id, this.chatId, this.text, this.srvCenterId, this.appUserId,
      this.sender, this.seen, this.date);

  factory FullMessage.fromJson(Map<String, dynamic> json) {
    print("234234234: ");
    print(json['id']);

    return FullMessage(
        json['id'],
        json['chat_id'],
        json['message'],
        json['srv_center_id'],
        json['app_user_id'],
        json['sender'],
        json['is_seen'] == 1,
        json['created_at']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'chat_id': chatId,
        'message': text,
        'srv_center_id': srvCenterId,
        'app_user_id': appUserId,
        'sender': sender,
        'is_seen': seen ? 1 : 0,
        'created_at': date
      };

  SimpleMessage toSimpleMessage(ChatUser _owner) {
    bool sentByMe = false;
    if (_owner is ClientChatUser && sender == 'user' ||
        _owner is CenterChatUser && sender == 'srv_center') {
      sentByMe = true;
    }
    return SimpleMessage(text, sentByMe, seen, date, id: id);
  }

  @override
  String toString() {
    return 'full message: id: $id - message: $text - srv_center_id: $srvCenterId - app_user_id: $appUserId - sender : $sender';
  }
}

class SimpleMessage extends Message {
  final int id;
  final bool sentByMe;
  final String text;
  final bool seen;
  final String _date;
  final String _persianDate;

  int get day {
    print(_persianDate);
    print(_date);
    try {
      return int.parse(_persianDate.split("/")[2]);
    } catch (e, stack) {
      print(e);
      print(stack);
      return 0;
    }
  }

  int get month {
    try {
      return int.parse(_persianDate.split("/")[1]);
    } catch (e, stack) {
      print(e);
      print(stack);
      return 0;
    }
  }

  String get time => Helpers.getIranTime(_date);

  // if the message is being constructed for sending the id will be 0
  SimpleMessage(this.text, this.sentByMe, this.seen, this._date, {this.id = 0})
      : this._persianDate = Helpers.getPersianDate(_date);

  FullMessage toFullMessage(Chat chat) {
    int appUserId;
    int srvCenterId;
    String sender;
    final owner = chat.owner;
    final to = chat.other;

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
    }

    return FullMessage(
        id, chat.chatId, text, srvCenterId, appUserId, sender, seen, _date);
  }
}

class TestMsg extends FullMessage {
  TestMsg(String text) : super(-1, 0, text, 0, 0, "test person", false, "date");
}
// user

abstract class ChatUser {
  ChatUser();

  int get id;
  String get uniqueId;

  @override
  bool operator ==(other) {
    return other is ChatUser &&
        this.runtimeType == other.runtimeType &&
        this.id == other.id;
  }

  @override
  int get hashCode {
    return hash2(this.runtimeType, this.id);
  }
}

class ClientChatUser extends ChatUser {
  final int appUserId;

  ClientChatUser(this.appUserId);

  @override
  int get id => appUserId;

  @override
  String toString() {
    return "user:$appUserId";
  }

  @override
  String get uniqueId => "U$id";
}

class CenterChatUser extends ChatUser {
  final int srvCenterId;

  CenterChatUser(this.srvCenterId);

  @override
  int get id => srvCenterId;

  @override
  String toString() {
    return "center:$srvCenterId";
  }

  @override
  String get uniqueId => "C$id";
}

abstract class Chat {
  final int chatId;
  final ChatUser owner;
  final ChatUser other;
  final int newMsg;
  final String otherTitle;

  Chat(
    this.owner,
    this.other,
    this.chatId,
    this.newMsg,
    this.otherTitle,
  );

  factory Chat.fromJson(Map<String, dynamic> chatJson, ChatUser owner) {
    try {
      int srvCenterId = chatJson['srv_center_id'] ?? -1;
      int appUserId = chatJson['app_user_id'];

      String otherName;
      print('srv center id in initial parsing of json: $srvCenterId');

      ChatUser other;
      if (owner.id == appUserId) {
        other = CenterChatUser(srvCenterId);
        otherName = chatJson['center_name'];
      } else if (owner.id == srvCenterId || srvCenterId == -1) {
        other = ClientChatUser(appUserId);
        if (owner.id == srvCenterId) {
          otherName = chatJson['mobile_number'];
        }
      } else {
        throw Exception(
            'neither srvcenterid nor appuserid matches the owner of repository\n'
            ' repository owner id: ${owner.id}\n appuserid: $appUserId \n srvcenterid: $srvCenterId');
      }

      if (srvCenterId == -1) {
        otherName = "${chatJson['firstname']} ${chatJson['lastname']}";
        // corresponding to the broadcast chats
        int chatId = chatJson['chat_id'];
        return OpenBroadcastChat(
            owner,
            other,
            chatId,
            1,
            chatJson['broadcast_title'],
            Helpers.getPersianDate(chatJson['created_at']),
            Helpers.getIranTime(chatJson['created_at']),
            otherName);
      } else {
        // directed chats
        bool broadcast = chatJson['is_broadcast'] == 1;
        int chatId = chatJson['chat_id'];

        int newMsgCount = chatJson['unseen_count'];

        if (broadcast) {
          return DirectedBroadcastChat(
              owner, other, chatId, newMsgCount, otherName);
        } else {
          return DirectChat(owner, other, chatId, newMsgCount, otherName);
        }
      }
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      throw Exception('error parsing chat');
    }
  }
}

class OpenBroadcastChat extends Chat implements BroadcastChat {
  final String title;
  final String date;
  final String time;

  OpenBroadcastChat(ChatUser owner, ChatUser other, int chatId, int newMsg,
      this.title, this.date, this.time, String userInfo)
      : super(owner, other, chatId, newMsg, userInfo);
}

class DirectChat extends Chat {
  DirectChat(
    ChatUser owner,
    ChatUser other,
    int chatId,
    int newMsg,
    otherContactName,
  ) : super(owner, other, chatId, newMsg, otherContactName);
}

class DirectedBroadcastChat extends DirectChat implements BroadcastChat {
  DirectedBroadcastChat(ChatUser owner, ChatUser other, int chatId, int newMsg,
      String otherContactName)
      : super(owner, other, chatId, newMsg, otherContactName);
}

class ChatIdentifier {
  final int centerId;
  final int appUserId;

  ChatIdentifier(this.centerId, this.appUserId);
}

class BroadcastChat {}

// misc

//class ContactInfo {
//  final String title;
//
//  ContactInfo(this.title);
//}
