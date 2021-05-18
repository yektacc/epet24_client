import 'package:flutter/material.dart';

import '../constants.dart';

class Buttons {
  static Widget sized(String title, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 34,
        width: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: StaticAppColors.main_color),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Text(
          title,
          style: TextStyle(fontSize: 13, color: StaticAppColors.main_color),
        ),
      ),
    );
  }

  static Widget simple(String title, Function() onPressed,{padding : const EdgeInsets.symmetric(vertical: 4,horizontal: 6)}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: StaticAppColors.main_color),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Text(
          title,
          style: TextStyle(fontSize: 13, color: StaticAppColors.main_color),
        ),
      ),
    );
  }


  static Widget small(String title, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: StaticAppColors.main_color),
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Text(
          title,
          style: TextStyle(fontSize: 11, color: StaticAppColors.main_color),
        ),
      ),
    );
  }
}
