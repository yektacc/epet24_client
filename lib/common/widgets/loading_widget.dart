import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants.dart';

class LoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  LoadingIndicator({this.color = StaticAppColors.loading_indicator_color,this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCube(
      color: this.color,
      size: size,
    );
  }
}

class SmallLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(7),
      child: SpinKitDualRing(
        color: Colors.grey[300],
        size: 20.0,
      ),
    );
  }
}

class LightLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCube(
      color: StaticAppColors.light_loading_indicator_color,
      size: 50.0,
    );
  }
}
