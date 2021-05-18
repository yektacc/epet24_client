//import 'package:ably_flutter_plugin/ably.dart';

import 'netclient.dart';
//import 'package:ably_flutter_plugin/ably.dart' as ably;

class GRepo {
  final Net _net;

  GRepo(this._net);

  Future<String> getOnlineVisitMessage() async {
    var res =
        await _net.post(EndPoint.GET_SITE_INFO, cacheEnabled: true, body: {
      'type': 'VisitOnline',
    });

    if (res is SuccessResponse) {
      return res.data[0]['description'];
//      String rawText = res.data[0]['description'];
//      return rawText.substring(3, rawText.length - 8);
    } else {
      return "...";
    }
  }

//  Stream<String> getAblyStreamAndPublishSomething() {
//    final clientOptions =
//        ably.ClientOptions.fromKey("D6jXTA.pJS9Ug:5nvD3Qn9yDI-KVmj");
//    clientOptions.logLevel = ably.LogLevel.verbose; //optional
//    ably.Rest rest = ably.Rest(options: clientOptions);
//    ably.RestChannel channel = rest.channels.get('test');
//    publishMessages(channel);
//  }
//
//  void publishMessages(RestChannel channel) async {
//    //passing both name and data
//    await channel.publish(name: "Hello", data: "Ably");
//    //passing just name
//    await channel.publish(name: "Hello");
//    //passing just data
//    await channel.publish(data: "Ably");
//    //publishing an empty message
//    await channel.publish();
//  }
//
//  void realtime() {
//    final clientOptions =
//        ably.ClientOptions.fromKey("D6jXTA.pJS9Ug:5nvD3Qn9yDI-KVmj");
//    clientOptions.logLevel = ably.LogLevel.verbose; //
//    ably.Realtime realtime = ably.Realtime(options: clientOptions);
////  Listen to connection state change event
//
////  realtime.channels.get(name)
//
//    realtime.connection
//        .on()
//        .listen((ably.ConnectionStateChange stateChange) async {
//      print('Realtime connection state changed: ${stateChange.event}');
////    setState(() { _realtimeConnectionState = stateChange.current; });
//    });
////Listening to a particular event: connected
//
//    realtime.connection
//        .on(ably.ConnectionEvent.connected)
//        .listen((ably.ConnectionStateChange stateChange) async {
//      print('Realtime connection state changed: ${stateChange.event}');
////    setState(() { _realtimeConnectionState = stateChange.current; });
//    });
//
////Connect and disconnect to a realtime instance
//
//    realtime.connect(); //connect to realtime
////  realtime.disconnect();
//  }
//
//
//  Future<ContactInfo> getContactInfo(ChatUser chatUser) async {
//    if (chatUser is ClientChatUser) {
//      var res = await _net.post(EndPoint.GET_CONTACT_INFO,
//          body: {'id': chatUser.appUserId.toString()});
//
//      if (res is SuccessResponse) {
//        var info = List<Map<String, dynamic>>.from(res.data)[0];
//
//        var fn = info['firstname'];
//        var ln = info['lastname'];
//
//        var title;
//
//        if (fn != '' || ln != '') {
//          title = fn + " " + ln;
//        } else {
//          title = 'نام مشخص نشده است';
//        }
//
//        return ContactInfo(title);
//      } else {
//        return ContactInfo('');
//      }
//    } else if (chatUser is CenterChatUser) {
//      var res = await _net.post(EndPoint.GET_CENTERS,
//          body: {'center_id': chatUser.srvCenterId});
//
//      if (res is SuccessResponse) {
//        var info = List<Map<String, dynamic>>.from(res.data)[0];
//
//        var centerName = info['center_name'];
//
//        return ContactInfo(centerName);
//      } else {
//        return ContactInfo('');
//      }
//    } else {
//      throw Exception('invalid type: $chatUser');
//    }
//  }

}
