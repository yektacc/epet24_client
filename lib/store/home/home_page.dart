import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:store/common/constants.dart';
import 'package:store/common/widgets/loading_widget.dart';
import 'package:store/common/widgets/app_widgets.dart';
import 'package:store/services/chat/user_inbox_page.dart';
import 'package:store/store/landing/landing_page.dart';
// import 'package:store/store/location/map/map_page.dart';
import 'package:store/store/login_register/login/login_bloc.dart';
import 'package:store/store/login_register/login/login_event_state.dart';
import 'package:store/store/login_register/login_status/login_status_bloc.dart';
import 'package:store/store/login_register/login_status/login_status_event_state.dart';
import 'package:store/store/login_register/profile/profile_bloc.dart';
import 'package:store/store/login_register/profile/profile_bloc_event_state.dart';
import 'package:store/store/login_register/profile/profile_page.dart';
import 'package:store/store/management/management_home_page.dart';
import 'package:store/store/management/management_login_event_state.dart';
import 'package:store/store/management/manager_login_bloc.dart';
import 'package:store/store/management/manager_login_page.dart';
import 'package:store/store/management/seller/shop_request_form.dart';
import 'package:store/store/order/order_page.dart';
import 'package:store/store/products/cart/cart_bloc.dart';
import 'package:store/store/products/cart/cart_page.dart';
import 'package:store/store/products/detail/product_detail_page.dart';
import 'package:store/store/products/favorites/favorites_page.dart';
import 'package:store/store/products/filter/filtered_products_bloc.dart';
import 'package:store/store/products/product/products_bloc.dart';
import 'package:store/store/products/search/search_delegate.dart';
import 'package:store/store/products/special/special_products_page.dart';
import 'package:store/store/products/special/special_products_repository.dart';
import 'package:store/store/structure/model.dart';
import 'package:store/store/structure/structure_bloc.dart';
import 'package:store/store/structure/structure_event_state.dart';
import 'package:store/store/userpet/user_pet_page.dart';

import '../../app.dart';
import 'info_page.dart';
import 'main_area.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/homepage';

  ProductsBloc _productsBloc;
  FilteredProductsBloc _filteredProductsBloc;
  StructureBloc _structureBloc;
  LoginBloc _loginBloc;
  LoginStatusBloc _loginStatusBloc;

  @override
  _HomePageState createState() => _HomePageState();
}

enum OverlayPage { MAIN_PAGE, SEARCH, MAP }

enum PageChangeEvent { MAP_SHOW, MAP_HIDE, SEARCH_SHOW, SEARCH_HIDE }

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // AnimationController mapAnimController;
  // Animation<Offset> mapPageOffset;

/*  AnimationController searchAnimController;
  Animation<Offset> searchPageOffset;*/

  PersistentBottomSheetController _controller;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearchShown = false;

  void _updateOverlay(PageChangeEvent event) {
    if (event == PageChangeEvent.MAP_SHOW) {
      _showMap();
    } else if (event == PageChangeEvent.MAP_HIDE) {
      _hideMap();
    } else if (event == PageChangeEvent.SEARCH_SHOW) {
      _isSearchShown = true;
      _showSearch();
    } else if (event == PageChangeEvent.SEARCH_HIDE) {
      _isSearchShown = false;
      _hideSearch();
    }
  }

  void _showMap() {
    // if (mapAnimController.status != AnimationStatus.completed) {
    //   mapAnimController.forward();
    // }
  }

  void _hideMap() {
    // mapAnimController.reverse();
  }

  void _showSearch() {
    showSearch(context: context, delegate: CustomSearchDelegate(AllItems()));
  }

  void _hideSearch() {
/*
    searchAnimController.reverse();
*/
    setState(() {
      if (_controller != null) _controller.close();
    });
  }

  @override
  void initState() {
    super.initState();

    // mapAnimController =
    //     AnimationController(duration: Duration(milliseconds: 250));
    //
    // mapPageOffset =
    //     Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset(0.0, 0.0))
    //         .animate(CurvedAnimation(
    //   parent: mapAnimController,
    //   curve: Curves.fastOutSlowIn,
    // ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    /* searchAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));

    searchPageOffset = Tween<Offset>(
            begin: Offset(0.0, 1 - (56 / MediaQuery.of(context).size.height)),
            end: Offset(0.0, (59 / MediaQuery.of(context).size.height)))
        .animate(CurvedAnimation(
      parent: searchAnimController,
      curve: Curves.fastOutSlowIn,
    ));*/
  }

  CustomAppBar _buildAppBar(BuildContext context) {
    return new CustomAppBar(
      titleText: '??????????????',
      light: true,
      /*title: FlatButton(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
            ),
            BlocBuilder<MyLocationBloc, MyLocationState>(
              bloc: Provider.of<MyLocationBloc>(context),
              builder: (context, MyLocationState state) {
                if (state is MyLocationLoaded) {
                  return Text(
                    state.myLocation.city.name,
                    style: TextStyle(color: Colors.white),
                  );
                } else {
                  return Text(
                    "?????????? ????",
                    style: TextStyle(color: Colors.white),
                  );
                }
              },
            ),
          ],
        ),
        onPressed: () {
          _updateOverlay(PageChangeEvent.MAP_SHOW);
        },
      ),*/
      actions: <Widget>[
        CartButton(Provider.of<CartBloc>(context)),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LandingPage()));
          },
          icon: (Icon(
            Icons.home,
            color: Colors.grey[700],
          )),
        ),
        /*Container(
          width: 70,
          child: BlocBuilder(
            bloc: Provider.of<CartBloc>(context),
            builder: (context, CartState state) {
              if (state is CartLoaded) {
                return CartButton(state.count);
              } else {
                return CartButton(0);
              }
            },
          ),
        )*/
      ],
    );
  }

  Widget _buildDrawer() {
    return SafeArea(
      child: new Drawer(
        child: Column(
          children: <Widget>[
            Container(
                height: 90,
                decoration: new BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 0.0),
                    // 10% of the width, so there are ten blinds.
                    colors: [
                      StaticAppColors.main_color,
                      StaticAppColors.main_color,
                    ],
                    // whitish to gray
                    tileMode:
                        TileMode.clamp, // repeats the gradient over the canvas
                  ),
                ),
/*
                color: AppColors.main_color,
*/
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: new BlocBuilder(
                      bloc: widget._loginStatusBloc,
                      builder: (context, LoginStatusState state) {
                        if (state is NotLoggedIn) {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        side: BorderSide(color: Colors.white)),
                                    onPressed: () {
                                      Navigator.push(context,
                                          AppRoutes.loginPage(context));
                                    },
                                    child: Text(
                                      "???????? / ?????? ??????",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        side: BorderSide(color: Colors.white)),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LandingPage()));
                                    },
                                    child: Text(
                                      "??????????",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        } else if (state is IsLoggedIn) {
                          return new Align(
                            alignment: Alignment.bottomCenter,
                            child: new Column(
                              children: <Widget>[
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(right: 10),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Center(
                                            child: BlocBuilder(
                                                bloc: Provider.of<ProfileBloc>(
                                                    context),
                                                builder: (BuildContext context,
                                                    ProfileState state) {
                                                  if (state is ProfileLoaded) {
                                                    return Container(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return ProfilePage();
                                                          }));
                                                        },
                                                        child: Text(
                                                          state.profile
                                                                  .firstName +
                                                              '  ' +
                                                              state.profile
                                                                  .lastName,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return Container();
                                                  }
                                                }),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child:
                                                /*Text(
                                                (state.status as LoggedInStatus)
                                                    .user
                                                    .phoneNo,style: TextStyle(color: Colors.white),)*/
                                                Container(),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (state is StatusLoading) {
                          return new Center(child: LoadingIndicator());
                        } else {
                          return Container();
                        }
                      }),
                )),
            Expanded(
              child: BlocBuilder(
                  bloc: widget._loginStatusBloc,
                  builder: (context, LoginStatusState state) {
                    var managerLoginBloc =
                    Provider.of<ManagerLoginBloc>(context);

                    return new Container(
//                    height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.only(right: 4, top: 20),
                      child: ListView(
                        children: <Widget>[
                          state is IsLoggedIn
                              ? _buildDrawerItem(() {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return ProfilePage();
                                }));
                          }, Icons.person, "?????????????? ????????????")
                              : Container(),
                          state is IsLoggedIn
                              ? _buildDrawerItem(() {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return UserInboxPage();
                                }));
                          }, Icons.chat, "????????????")
                              : Container(),
                          _buildDrawerItem(() {
                            Navigator.of(context).pushNamed(CartPage.routeName);
                          }, Icons.shopping_cart, "?????? ????????"),
                          _buildDrawerItem(() {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return InfoPage();
                            }));
                          }, Icons.info, "???????? ?? ????????????"),
                          state is IsLoggedIn
                              ? _buildDrawerItem(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserOrderPage()));
                          }, Icons.history, "?????????? ?????? ??????")
                              : Container(),
                          state is IsLoggedIn
                              ? _buildDrawerItem(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserPetPage()));
                          }, Icons.pets, "?????????? ?????????? ??????")
                              : Container(),
                          state is IsLoggedIn ? Divider() : Container(),
                          state is IsLoggedIn
                              ? _buildDrawerItem(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FavoritesPage()));
                          }, Icons.favorite, "????????????????????? ????")
                              : Container(),
                          Divider(),
                          _buildDrawerItem(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SpecialProductsPage(
                                        SpecialProductType.BEST_SELLER)));
                          }, Icons.local_offer, "???????????????????? ??????????????"),
                          _buildDrawerItem(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SpecialProductsPage(
                                        SpecialProductType.NEWEST)));
                          }, Icons.new_releases, "??????????????????? ??????????????"),
                          Divider(),
                          !(managerLoginBloc.currentState is ManagerLoggedIn)
                              ? _buildDrawerItem(() {
                            if (!(managerLoginBloc.currentState
                            is ManagerLoggedIn)) {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ManagerLoginPage()));
                            }
                          }, Icons.store, "???????? ???? ???????? ????????????")
                              : GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  ManagementHomePage.routeName);
                            },
                            child: Card(
                              color: Colors.blueGrey[50],
                              margin:
                              EdgeInsets.only(right: 12, left: 55),
                              child: Container(
                                alignment: Alignment.centerRight,
                                height: 75,
                                width: double.infinity,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            child: Icon(
                                              Icons.store,
                                              color: Colors.grey[800],
                                              size: 22,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10),
                                          ),
                                          Text(
                                            "???????? ???? ???????? ??????????????????",
                                            style: TextStyle(
                                                color: Colors.grey[800]),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        child: Text(
                                          (managerLoginBloc.currentState
                                          as ManagerLoggedIn)
                                              .user
                                              .email,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        decoration: BoxDecoration(
                                            color: StaticAppColors.main_color,
                                            borderRadius:
                                            BorderRadius.only(
                                                bottomLeft:
                                                Radius.circular(
                                                    4),
                                                bottomRight:
                                                Radius.circular(
                                                    4))),
                                        alignment: Alignment.centerRight,
                                        padding:
                                        EdgeInsets.only(right: 12),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          state is IsLoggedIn &&
                              !(managerLoginBloc.currentState
                              is ManagerLoggedIn)
                              ? _buildDrawerItem(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SellerRequestPage(
                                        state.user.appUserId)));
                          }, Icons.favorite, "?????????????? ?????????????? ??????")
                              : Container(),
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(VoidCallback onPressed, IconData icon, String title) {
    return Container(
      height: 45,
      child: FlatButton(
          onPressed: onPressed,
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: Colors.grey[600],
                size: 22,
              ),
              Padding(
                padding: EdgeInsets.only(right: 20),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              )
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget._productsBloc == null) {
      widget._productsBloc = Provider.of<ProductsBloc>(context);
/*
      widget._productsBloc.dispatch(LoadPopularProducts(AllItems()));
*/
    }

    if (widget._filteredProductsBloc == null) {
      widget._filteredProductsBloc = Provider.of<FilteredProductsBloc>(context);
    }

    if (widget._structureBloc == null) {
      widget._structureBloc = Provider.of<StructureBloc>(context);
      widget._structureBloc.dispatch(FetchStructure());
    }

    if (widget._loginStatusBloc == null) {
      widget._loginStatusBloc = Provider.of<LoginStatusBloc>(context);
    }

    if (widget._loginBloc == null) {
      widget._loginBloc = Provider.of<LoginBloc>(context);
      if (widget._loginStatusBloc.currentState is NotLoggedIn) {
        widget._loginBloc.dispatch(AttemptLastLogin());
      }
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: <Widget>[
          new Scaffold(
              resizeToAvoidBottomInset: false,
              key: _scaffoldKey,
              drawer: _isSearchShown ? null : _buildDrawer(),
              backgroundColor: Colors.grey[100],
              appBar: _buildAppBar(context),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: MainArea(),
                  ),
                  GestureDetector(
                    child: CustomAppBar(
                      light: true,
                      leading: Padding(
                        padding: EdgeInsets.only(right: 14),
                        child: Icon(
                          Icons.search,
                          color: StaticAppColors.main_color,
                        ),
                      ),
                      title: Container(
                        alignment: Alignment.centerRight,
                        height: 45,
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          '?????????? ?????? ??????????????',
                          style:
                          TextStyle(fontSize: 12, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    onTap: () {
                      _updateOverlay(PageChangeEvent.SEARCH_SHOW);
                    },
                  )
                  /* SearchArea(() {
                    searchAnimController.forward();
                  })*/
                ],
              )),
          // new SlideTransition(
          
          //   position: mapPageOffset,
          //   child: SizedBox(
          //     height: double.infinity,
          //     width: double.infinity,
          //     child: Container(
          //       color: Colors.grey[300],
          //       child: MapPage(() {
          //         _updateOverlay(PageChangeEvent.MAP_HIDE);
          //       }),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    /* return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            content: new Text('?????? ??????????????????? ???? ???? ???????? ??????????'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('??????'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('??????'),
              ),
            ],
          ),
        )) ??
        false;
  */
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingPage()));
    return true;
  }
}

class Spaces {
  static const EdgeInsets listInsets =
      EdgeInsets.symmetric(vertical: 4, horizontal: 4);

  static const EdgeInsets listCardInsets =
      EdgeInsets.symmetric(vertical: 2, horizontal: 2);
}
