import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:store/common/constants.dart';
import 'package:store/common/widgets/app_widgets.dart';
import 'package:store/services/chat/inbox_event_state.dart';
import 'package:store/services/chat/inbox_manager.dart';
import 'package:store/services/chat/inbox_widgets.dart';
import 'package:store/services/chat/model.dart';

import '../model.dart';

class ServiceManagementPage extends StatefulWidget {
  static const routeName = 'sercviceManagementPage';

  final ServiceIdentifier _identifier;

  ServiceManagementPage(this._identifier);

  @override
  _ServiceManagementPageState createState() => _ServiceManagementPageState();
}

class _ServiceManagementPageState extends State<ServiceManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: Colors.grey[800],
          elevation: 0,
          title: Text(
            "مراکز",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        body: Theme(
          data: ThemeData(
              canvasColor: Colors.transparent,
              fontFamily: "IranSans",
              primaryColor: StaticAppColors.main_color_mat,
              primarySwatch: Colors.green,
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: "IranSans",
                    bodyColor: StaticAppColors.text_main,
                    displayColor: Colors.pink,
                  )),
          child: Builder(
            builder: (context) {
              return Stack(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                          ),
                          padding:
                              EdgeInsets.only(right: 12, top: 10, bottom: 10),
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.message,
                                color: Colors.white,
                                size: 22,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Text(
                                  'پیامها',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            color: Colors.grey[100],
                            padding: EdgeInsets.only(top: 16, bottom: 16),
                            child: ChatListWidget(
                                Provider.of<InboxManager>(context)
                                    .managerInbox),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                      ),
                      BottomSh(),
                    ],
                  )
                ],
              );
            },
          ),
        ));
  }

  @override
  void dispose() {
    Provider.of<InboxManager>(context).managerInbox.dispose();
    super.dispose();
  }
}

class BottomSh extends StatefulWidget {
  @override
  _BottomShState createState() => _BottomShState();
}

class _BottomShState extends State<BottomSh> {
  var openBrChatCount;
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: getTop(),
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return getBottomSheet();
            });
      },
    );
  }

  Widget getBottomSheet() {
    return Container(
      height: 285,
      decoration: BoxDecoration(borderRadius: BorderRadius.vertical()),
      child: Column(
        children: <Widget>[
          getTop(),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.vertical()),
            margin: EdgeInsets.only(left: 8, right: 8),
            elevation: 10,
            child: Container(
              height: 200,
              child: OnlineVisitWidget(
                inboxBloc: Provider.of<InboxManager>(context).managerInbox,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTop() {
    try {
      var state = Provider.of<InboxManager>(context).managerInbox.currentState
          as InboxLoaded;
      openBrChatCount =
          state.chats.where((c) => c.chat is OpenBroadcastChat).length;
    } catch (e) {
      openBrChatCount = -1;
    }

    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      margin: EdgeInsets.only(left: 8, right: 8, top: 5),
      child: Container(
        height: 80,
        padding: EdgeInsets.only(right: 10),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
//            color: Colors.grey[300],
            borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.keyboard_arrow_up,
              color: StaticAppColors.main_color,
            ),
            Container(
              child: Text(
                'ویزیت آنلاین',
                style: TextStyle(color: StaticAppColors.main_color, fontSize: 15),
              ),
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            ),
            Expanded(
              child: Container(),
            ),
            openBrChatCount == -1
                ? Container()
                : Container(
                    child: Text(
                      openBrChatCount.toString() + " مورد برای ویزیت آنلاین",
                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  )
          ],
        ),
      ),
    );
  }
}
