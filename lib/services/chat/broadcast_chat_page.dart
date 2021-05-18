import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:store/common/constants.dart';
import 'package:store/common/widgets/loading_widget.dart';
import 'package:store/common/widgets/app_widgets.dart';
import 'package:store/common/widgets/buttons.dart';
import 'package:store/common/widgets/form_fields.dart';
import 'package:store/data_layer/GRepo.dart';
import 'package:store/data_layer/netclient.dart';
import 'package:store/services/chat/inbox_bloc.dart';
import 'package:store/services/chat/inbox_event_state.dart';
import 'package:store/store/checkout/payment/payement_bloc.dart';
import 'package:store/store/login_register/login/login_page.dart';
import 'package:store/store/login_register/login_status/login_status_bloc.dart';
import 'package:store/store/login_register/login_status/login_status_event_state.dart';
import 'package:store/store/products/filter/filter.dart';

import 'inbox_manager.dart';

class BroadcastChatPage extends StatefulWidget {
  final PaymentBloc _paymentBloc;

  BroadcastChatPage(this._paymentBloc);

  @override
  _BroadcastChatPageState createState() => _BroadcastChatPageState();
}

class _BroadcastChatPageState extends State<BroadcastChatPage> {
  InboxManager _inboxMngr;
  final TextEditingController messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_inboxMngr == null) {
      _inboxMngr = Provider.of<InboxManager>(context);
    }

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'پیام به کلینیک ها',
        light: true,
        elevation: 0,
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        bloc: widget._paymentBloc,
        builder: (context, state) {
          if (state is PaymentSuccessful) {
            var loginStatus =
                Provider.of<LoginStatusBloc>(context).currentState;

            if (loginStatus is IsLoggedIn) {
              _inboxMngr.userInbox.dispatch(
                SendBroadcast(messageCtrl.text, loginStatus.user.sessionId),
              );
              return BlocBuilder<InboxBloc, InboxState>(
                bloc: _inboxMngr.userInbox,
                builder: (context, state) {
                  if (state is SendingBroadcast) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          margin:
                              EdgeInsets.only(bottom: 40, right: 10, left: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text('در حال ارسال پیام ...'),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 30),
                                child: LoadingIndicator(
                                  size: 30,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  } else if (state is BroadcastSent) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Card(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child:
                                          Text('پیام شما با موفقیت ارسال شد.'),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 30),
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      size: 30,
                                      color: StaticAppColors.main_color,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                  top: 10,
                                  bottom: 20,
                                ),
                                child: Buttons.simple(
                                    'بستن',
                                    () => Navigator.pop(
                                        context)) /*Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                  ],
                                )*/
                                ,
                              )
                            ],
                          ),
                        ),
                      ],
                    ));
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              Helpers.showErrorToast();
              return Container();
            }
          } else if (state is Idle) {
            final height = MediaQuery.of(context).size.height;

            return Container(
              height: height,
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Card(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)),
                        elevation: 12,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          child: FutureBuilder(
                            future:
                                GetIt.instance<GRepo>().getOnlineVisitMessage(),
                            builder: (context, snapshot) {
                              if (snapshot == null || snapshot.data == null) {
                                return Container();
                              } else {
                                return
                                  Html(
                                    data: snapshot.data,
                                  );
                                /*  Text(
                                  snapshot.data,
                                  style: TextStyle(fontSize: 16),
                                );*/
                              }
                            },
                          ),
                        )),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FormFields.big("پیام شما", messageCtrl)
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          Buttons.simple(
                            'پرداخت و ارسال پیام',
                            () {
                              var loginState = GetIt.instance<LoginStatusBloc>()
                                  .currentState;

                              if (loginState is IsLoggedIn) {
                                widget._paymentBloc
                                    .dispatch(StartPayment(Price(500)));
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                              }
                            },
                          ),
                          Buttons.simple(
                            'تست بدون پرداخت',
                            () {
                              var loginState = GetIt.instance<LoginStatusBloc>()
                                  .currentState;

                              if (loginState is IsLoggedIn) {
                                widget._paymentBloc
                                    .dispatch(StartTestPayment());
                              } else {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return LoadingIndicator();
          }
        },
      ),
    );
  }
}
