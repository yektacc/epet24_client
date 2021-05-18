import 'dart:async';
import 'dart:collection';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:rxdart/subjects.dart';
import 'package:store/services/chat/model.dart';

enum ConState { DISCONNECTED, CONNECTED, CONNECTING, FAILED }

class AMQPRepository {
  Queue _receiveQueue;

  Channel _channel;
  Client _client;

  final Chat _chat;
  static const String _host = "79.143.85.121";
  static const String _userName = "epet24";
  static const String _password = 'Epet!1263';
  StreamSubscription _messagesSub;
  BehaviorSubject<FullMessage> _messagesStream;

  AMQPRepository(this._chat) {
    ConnectionSettings settings = new ConnectionSettings(
        host: _host,
        authProvider: new PlainAuthenticator(_userName, _password));

    _client = new Client(settings: settings);
  }

  Future<Queue> _getSendQueue() async {
    if (_channel == null) {
      _channel = await _client.channel();
    }
    return await _channel.queue(
        "${_chat.chatId.toString()}_sender:${_chat.owner.uniqueId}_receiver:${_chat.other.uniqueId}",
        autoDelete: true);
  }

  Future<Queue> _getReceiveQueue() async {
    if (_channel == null) {
      _channel = await _client.channel();
    }
    return await _channel.queue(
        "${_chat.chatId.toString()}_sender:${_chat.other.uniqueId}_receiver:${_chat.owner.uniqueId}",
        autoDelete: true);
  }

  Stream<ConState> _connection() async* {
    if (_channel != null && _receiveQueue != null) {
      yield ConState.CONNECTED;
    } else {
      bool notConnected = true;

      while (notConnected) {
        try {
          yield ConState.CONNECTING;
          print("AMQP:: connecting to $_host");

          _receiveQueue = await _getReceiveQueue();

          if (_receiveQueue != null) {
            notConnected = false;
            yield ConState.CONNECTED;
          }
        } catch (e, stacktrace) {
          print("AMQP:: failed connecting to $_host : \n $e");
          print(stacktrace);
          yield ConState.FAILED;
        }

        if (notConnected) {
          print(
              "AMQP:: waiting for 5 seconds for the next try to connect to amqp server");
          await Future.delayed(Duration(seconds: 5));
        }
      }
    }
  }

  Stream<FullMessage> newMessages() async* {
    await for (ConState connectionState in _connection()) {
      if (connectionState == ConState.CONNECTED) {
        final Consumer consumer = await _receiveQueue.consume();

        _messagesStream = BehaviorSubject<FullMessage>();

        print("AMQP:: listening for messages on: _${_receiveQueue.name}");
        _messagesSub = consumer.listen((message) {
          print("AMQP:: new message : ${message.payloadAsString}");
          _messagesStream.add(FullMessage.fromJson(message.payloadAsJson));
        });

        yield* _messagesStream;
      } else {
        print(
            "AMQP:: not connected to listen to amqp messages, current connection state: $connectionState");
      }
    }
  }

  send(FullMessage message) async {
    StreamSubscription connectionSub;
    connectionSub = _connection().listen((connectionState) async {
      if (connectionState == ConState.CONNECTED) {
        print('AMQP:: sending new message: $message}');
        final q = await _getSendQueue();
        q.publish(message.toJson());
        connectionSub.cancel();
      } else {
        print(
            "AMQP:: not connected to listen to amqp messages, current connection state: $connectionState");
      }
    });
  }

  dispose() {
    _messagesSub.cancel();
    _messagesStream.close();
    _receiveQueue.delete();
    _channel.close();
    _client.close();
  }
}
