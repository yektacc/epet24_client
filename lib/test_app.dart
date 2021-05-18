import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it/get_it.dart';

import 'common/constants.dart';

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  Widget build(BuildContext context) {

    print(GetIt.I<AppColors>().main_color);

    return MaterialApp(
      title: 'epet24',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: "IranSans",
          primaryColor: GetIt.I<AppColors>().main_color_mat,
          primarySwatch: Colors.purple,
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: "IranSans",
                bodyColor: Colors.black,
                displayColor: Colors.pink,
              )),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("fa", "IR"),
      ],
      locale: Locale("fa", "IR"),
      home: Scaffold(
        appBar: AppBar(),
        body: Container(),
      ),
    );
  }
}
