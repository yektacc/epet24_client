import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:store/common/constants.dart';
import 'package:store/common/widgets/loading_widget.dart';
import 'package:store/common/widgets/app_widgets.dart';
import 'package:store/common/widgets/buttons.dart';
import 'package:store/services/centers/center_detail_page.dart';
import 'package:store/services/centers/centers_bloc.dart';
import 'package:store/services/centers/centers_event_state.dart';
import 'package:store/services/centers/model.dart';
import 'package:store/services/chat/broadcast_chat_page.dart';
import 'package:store/services/chat/inbox_event_state.dart';
import 'package:store/services/chat/inbox_manager.dart';
import 'package:store/store/checkout/payment/payement_bloc.dart';
import 'package:store/store/checkout/zarin_pal/client.dart';

import 'centers_list_page.dart';

class CentersPage extends StatefulWidget {
  @override
  _CentersPageState createState() => _CentersPageState();
}

class _CentersPageState extends State<CentersPage> {
  CentersBloc _centersBloc;

  @override
  Widget build(BuildContext context) {
    if (_centersBloc == null) {
      _centersBloc = Provider.of<CentersBloc>(context);
      _centersBloc
          .dispatch(FetchCenters(CenterFilter(CenterFetchType.CLINICS)));
    }

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'کلینیک ها',
        light: true,
        elevation: 0,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Opacity(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/clinics_background.jpg'),
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center)),
              ),
              opacity: 0.2,
            ),
            Column(
              children: <Widget>[
                Card(
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0)),
                  elevation: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              flex: 5,
                              child: GestureDetector(
                                child: Padding(
                                  child: Card(
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 0),
                                    color: Colors.grey[50],
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                              right: 10, top: 10),
                                          child: Icon(
                                            Icons.chat,
                                            color: StaticAppColors.main_color,
                                          ),
                                          alignment: Alignment.centerRight,
                                        ),
                                        Container(
                                          alignment: Alignment.bottomRight,
                                          padding: EdgeInsets.only(
                                              top: 20, bottom: 20, right: 16),
                                          child: Text('ویزیت آنلاین',textAlign: TextAlign.center,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                        )
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => BroadcastChatPage(
                                          PaymentBloc(ZarinPalClient()))));
                                },
                              )),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              margin: EdgeInsets.only(left: 8),
                              child: Column(
                                children: <Widget>[
                                  FlatButton(
                                      child: Text(
                                        'مشاهده همه مراکز',
                                        style:
                                            TextStyle(color:StaticAppColors.main_color),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CentersListPage(
                                                        CenterFetchType
                                                            .CLINICS)));
                                      }),
//                                  Row(
//                                    mainAxisAlignment: MainAxisAlignment.end,
//                                    children: <Widget>[
//                                      Padding(
//                                        padding: EdgeInsets.only(),
//                                        child: Icon(
//                                          Icons.store,
//                                          color: Colors.grey[500],
//                                          size: 30,
//                                        ),
//                                      )
//                                    ],
//                                  )
                                ],
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: StaticAppColors.main_color),
                                  borderRadius: BorderRadius.circular(22)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: FlatButton(
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'جستجو بین مراکز خدماتی',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                showSearch(
                                  context: context,
                                  delegate: CentersSearchDelegate(
                                      CenterFetchType.CLINICS),
                                );
                              },
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(30))),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<CentersBloc, CentersState>(
                    bloc: _centersBloc,
                    builder: (context, state) {
                      if (state is CentersLoaded) {
                        return CentersMapWidget(
                          centers: state.centers,
                        );
                      } else if (state is CentersLoading) {
                        return LoadingIndicator();
                      } else {
                        return Center(
                          child: Text('خطا در بارگزاری'),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CentersMapWidget extends StatefulWidget {
  final List<CenterItem> centers;

  const CentersMapWidget({Key key, this.centers}) : super(key: key);

  @override
  _CentersMapWidgetState createState() => _CentersMapWidgetState();
}

class _CentersMapWidgetState extends State<CentersMapWidget> {
  BitmapDescriptor pinLocationIcon;
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _zanjanLocation = CameraPosition(
    target: LatLng(36.6830, 48.5087),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _zanjanLocation,
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  Set<Marker> get _markers {
    return widget.centers
        .map((c) => Marker(
            markerId: MarkerId(c.id.toString()),
            position: c.location,
            onTap: () {
              showBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: 120,
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          Helpers.image(c.logoUrl,
                              height: 120,
                              placeHolder: Container(
                                height: 120,
                                width: 120,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image,
                                  size: 70,
                                  color: Colors.grey[100],
                                ),
                              )),
                          Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    right: 12, top: 10, bottom: 6),
                                child: Text(
                                  c.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: StaticAppColors.grey,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: RatingBarIndicator(
                                      rating: 3,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 18.0,
                                      direction: Axis.horizontal,
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 40,
                                    child: Buttons.simple(
                                      "مشاهده جزییات",
                                      () => {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CenterDetailPage(c)))
                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  });
            },
            icon: pinLocationIcon))
        .toSet();
  }

  void setCustomMapPin() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(20, 20), devicePixelRatio: 2.5),
            'assets/clinics_map_pin.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
  }
}
