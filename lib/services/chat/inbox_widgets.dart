import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:store/common/constants.dart';
import 'package:store/common/widgets/loading_widget.dart';
import 'package:store/data_layer/GRepo.dart';
import 'package:store/services/chat/broadcast_chat_page.dart';
import 'package:store/services/chat/chat_bloc.dart';
import 'package:store/services/chat/chat_event_state.dart';
import 'package:store/services/chat/chat_page.dart';
import 'package:store/services/chat/chat_repository.dart';
import 'package:store/services/chat/inbox_bloc.dart';
import 'package:store/services/chat/inbox_event_state.dart';

import 'model.dart';

// chat list
class ChatListWidget extends StatefulWidget {
  final InboxBloc _inboxBloc;

  ChatListWidget(this._inboxBloc);

  @override
  _ChatListWidgetState createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  @override
  Widget build(BuildContext context) {
    widget._inboxBloc.dispatch(UpdateInbox());

    return BlocBuilder(
      bloc: widget._inboxBloc,
      builder: (context, state) {
        print('inbox state: ' + state.toString());

        if (state is InboxLoading) {
          return LoadingIndicator();
        } else if (state is InboxLoaded) {
          print('inbox loaded: ${state.chats}');

          print('state is inbox loaded');

          if (state.chats.isEmpty) {
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.inbox,
                      size: 140,
                      color: Colors.grey[200],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(
                      child: Text('شما پیامی ندارید'),
                    ),
                  )
                ],
              ),
            );
          } else {
            return ListView(
              children: state.chats
                  .where((c) => !(c.chat is OpenBroadcastChat))
                  .map((chat) => ChatListItem(chat)).toList().
                  reversed
                  .toList(),
            );
          }
        } else {
          return Center(
            child: Text('error'),
          );
        }
      },
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ChatBloc _bloc;

  ChatListItem(this._bloc);

  @override
  Widget build(BuildContext context) {
    Chat chat = _bloc.chat;

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ChatPage(_bloc)));
      },
      child: Container(
          margin: EdgeInsets.only(top: 8),
//                elevation: 5,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey[300], width: 1))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    height: 56,
                    padding: EdgeInsets.only(right: 18),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _bloc.chat.otherTitle,
                        style: TextStyle(color: Colors.blueGrey[800]),
                      ),
                    )),
              ),
              _bloc.chat is BroadcastChat
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: Colors.grey[700],
                          width: 1.3,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                      child: Text(
                        'ویزیت آنلاین',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 10),
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.only(right: 10, left: 14),
                child: chat.newMsg != 0
                    ? Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: StaticAppColors.main_color,
                            borderRadius: BorderRadius.circular(40)),
                        child: Text(
                          chat.newMsg.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      )
                    : Container(
                        height: 30,
                        width: 30,
                      ),
              ),
            ],
          )),
    );
  }
}

// online visit
class OnlineVisitWidget extends StatefulWidget {
  final InboxBloc inboxBloc;

  const OnlineVisitWidget({Key key, this.inboxBloc}) : super(key: key);

  @override
  _OnlineVisitWidgetState createState() => _OnlineVisitWidgetState();
}

class _OnlineVisitWidgetState extends State<OnlineVisitWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InboxBloc, InboxState>(
      bloc: widget.inboxBloc,
      builder: (context, state) {
        if (state is InboxLoaded) {
          final openChatsWidgets = state.chats
              .where((c) => c.chat is OpenBroadcastChat)
              .map((c) {
                return c;
              })
              .map((chat) => OnlineVisitItem(
                    chatBloc: chat,
                  ))
              .toList()
              .reversed
              .toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return openChatsWidgets[index];
            },
            itemCount: openChatsWidgets.length,
          );

//          return ListView.builder(itemBuilder: (context, index) {
//            if (state.chats[index] is OpenBroadcastChat) {
//              return OnlineVisitItem(
//                chatBloc: state.chats[index],
//              );
//            } else {
//              return Container();
//            }
//          });
//
//          ListView(
//              scrollDirection: Axis.horizontal,
//              children: state.chats
//                  .where((c) => c.chat is OpenBroadcastChat)
//                  .map((c) {
//                    print('open broadcast: ${c.chat.other.id}');
//                    return c;
//                  })
//                  .map((chat) => OnlineVisitItem(
//                        chatBloc: chat,
//                      ))
//                  .toList());
        } else if (state is InboxLoading) {
          return LoadingIndicator();
        } else {
          return LoadingIndicator();
        }
      },
    );
  }
}

class OnlineVisitItem extends StatefulWidget {
  final ChatBloc chatBloc;

  const OnlineVisitItem({Key key, this.chatBloc}) : super(key: key);

  @override
  _OnlineVisitItemState createState() => _OnlineVisitItemState();
}

class _OnlineVisitItemState extends State<OnlineVisitItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ChatPage(widget.chatBloc)));
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 20, top: 11, right: 4, left: 4),
        child: Container(
          width: 160,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 8, right: 7, left: 7),
                alignment: Alignment.bottomRight,
                child: Row(
                  children: <Widget>[
                    Padding(
                      child: Icon(
                        Icons.person_outline,
                        size: 19,
                      ),
                      padding: EdgeInsets.only(left: 5),
                    ),
                    Text(widget.chatBloc.chat.otherTitle)
                  ],
                ),
              ),
              Divider(
                indent: 0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    (widget.chatBloc.chat as OpenBroadcastChat).title ??
                        'عنوان وجود ندارد',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                  ),
                  padding: EdgeInsets.only(right: 7, left: 7),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(right: 7, top: 4, bottom: 2),
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(4)),
                      color: Colors.grey[100]),
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: <Widget>[
                      Text(
                        (widget.chatBloc.chat as OpenBroadcastChat).date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                      ),
                      Text(
                        (widget.chatBloc.chat as OpenBroadcastChat).time,
                        style: TextStyle(
                            fontSize: 13, color: StaticAppColors.main_color),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
