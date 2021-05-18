import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:store/common/bloc_state_event.dart';
import 'package:store/common/constants.dart';
import 'package:store/store/checkout/zarin_pal/client.dart';
import 'package:store/store/products/filter/filter.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ZarinPalClient _zpClient;
  StreamSubscription _linkingSub;

  PaymentBloc(this._zpClient) {
    _linkingSub ??= getLinksStream().listen((String link) async {
      if (link.contains(LiteralConstants.callbackUrl)) {
        dispatch(VerifyPayment());
      }
    }, onError: (err) {
      print(err);
    });
  }

  @override
  PaymentState get initialState => Idle();

  @override
  void dispose() {
    _linkingSub.cancel();
    super.dispose();
  }

  @override
  Stream<PaymentState> mapEventToState(PaymentEvent event) async* {
    if (event is StartTestPayment) {
      yield PaymentSuccessful(); //test

    } else if (event is StartPayment) {
//      yield PaymentSuccessful(); //test

      if (currentState is Idle) {
        var response =
            await _zpClient.getPaymentURL(ZPPaymentRequest(event.price));

        if (response is ZPFetchUrlSuccessful) {
          var ls = await launch(response.getURL());
          if (ls) {
            yield InGateway(response.authority, event.price);
          } else {
            yield PaymentFailed(PaymentError.CANT_LAUNCH_GATEWAY);
          }
        } else if (response is ZPFailedFetchingUrl) {
          yield PaymentFailed(PaymentError.CANT_GET_URL);
        }
      }
    } else if (event is VerifyPayment) {
      if (currentState is InGateway) {
        var inGateway = currentState as InGateway;

        var res = await _zpClient.verifyPayment(
            ZPVerifyRequest(inGateway.authority, inGateway.price.amount));

        if (res is ZPVerifyError) {
          yield PaymentFailed(PaymentError.CANT_VERIFY);
        } else if (res is ZPVerifySuccess) {
          yield PaymentSuccessful();
        }
      }
    }
  }
}

class PaymentState extends BlocState {}

class PaymentEvent extends BlocEvent {}

// states
class Idle extends PaymentState {}

class PaymentFailed extends Idle {
  final PaymentError error;

  PaymentFailed(this.error);
}

class InGateway extends PaymentState {
  final String authority;
  final Price price;

  InGateway(this.authority, this.price);
}

class VerifyingPayment extends PaymentState {
  VerifyingPayment();
}

enum PaymentError { CANT_VERIFY, CANT_GET_URL, CANT_LAUNCH_GATEWAY }

class PaymentSuccessful extends PaymentState {
  PaymentSuccessful();
}

// events
class StartPayment extends PaymentEvent {
  final Price price;

  StartPayment(this.price);
}

class StartTestPayment extends PaymentEvent {
  StartTestPayment();
}

class VerifyPayment extends PaymentEvent {}
