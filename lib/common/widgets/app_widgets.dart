import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:store/common/constants.dart';
import 'package:store/data_layer/province/province_repository.dart';
import 'package:store/store/location/provinces/model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final PreferredSizeWidget bottom;
  final String titleText;
  final Widget leading;
  final List<Widget> actions;
  final Color backgroundColor;
  final bool altMainColor;
  final double elevation;
  final bool light;

  CustomAppBar(
      {Key key,
      this.title,
      this.leading,
      this.titleText,
      this.actions,
        this.altMainColor = false,
      this.backgroundColor,
      this.elevation,
      this.bottom,
      this.light = false})
      : preferredSize = bottom != null
            ? Size.fromHeight(kToolbarHeight * 2)
            : Size.fromHeight(kToolbarHeight),
        super(key: key) {
    assert(this.titleText == null || this.title == null);
  }

  @override
  final Size preferredSize; // default is 56.0

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title ??
          Text(
            titleText,
            style: TextStyle(
                color: light ? StaticAppColors.text_main : Colors.white,
                fontSize: 15),
          ),
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor != null
          ? backgroundColor
          : light
              ? Colors.grey[50]
          : altMainColor ? StaticAppColors.second_color : StaticAppColors.main_color,
      iconTheme: IconThemeData(
          color: light
              ? altMainColor ? StaticAppColors.second_color : StaticAppColors.main_color
              : Colors.white),
      elevation: elevation,
      bottom: this.bottom,
    );
  }
}

class ProvinceCitySelectionRow extends StatefulWidget {
  final Function(Province, City) onChange;
  BehaviorSubject<bool> required = BehaviorSubject.seeded(false);
  bool validate;
  City initialCity;
  Province initialProvince;

  ProvinceCitySelectionRow(this.onChange,
      {this.initialCity,
      this.initialProvince,
      this.validate = false,
      this.required}) {
    assert(!validate || required != null);
  }

  @override
  _ProvinceCitySelectionRowState createState() =>
      _ProvinceCitySelectionRowState();
}

class _ProvinceCitySelectionRowState extends State<ProvinceCitySelectionRow> {
  Province currentProvince;
  City currentCity;

  @override
  Widget build(BuildContext context) {
    var showError = false;

    return StreamBuilder<bool>(
      stream: widget.required,
      builder: (context, snapshot) {
        showError = snapshot.data != null &&
            snapshot.data &&
            currentProvince == null &&
            currentCity == null;

        return Padding(
          padding: AppDimensions.defaultFormPadding,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  new Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          border: Border.all(color: Colors.grey[300])),
                      height: 60,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      child: DropdownButton<Province>(
                        iconEnabledColor: StaticAppColors.main_color,
                        itemHeight: 60,
                        underline: Container(),
                        isExpanded: true,
                        hint: Text("??????????"),
                        value: currentProvince == null &&
                                widget.initialProvince != null
                            ? widget.initialProvince
                            : currentProvince,
                        elevation: 16,
                        style: TextStyle(color: Colors.grey[900], fontSize: 14),
                        onChanged: (Province newValue) {
                          setState(() {
                            currentProvince = newValue;
                            currentCity = null;

                            widget.initialProvince = null;
                            widget.initialCity = null;
                            widget.onChange(currentProvince, currentCity);
                          });
                        },
                        items: (Provider.of<ProvinceRepository>(context)
                                .getAll())
                            .map<DropdownMenuItem<Province>>((Province value) {
                          return DropdownMenuItem<Province>(
                            value: value,
                            child: Text(value == null ? "??????????" : value.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  new Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            border: Border.all(color: Colors.grey[300])),
                        height: 60,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(right: 12),
                        child: new DropdownButton<City>(
                          iconEnabledColor: StaticAppColors.main_color,
                          itemHeight: 60,
                          underline: Container(),
                          icon: Icon(Icons.location_city),
                          isExpanded: true,
                          hint: Text("??????"),
                          value:
                              currentCity == null && widget.initialCity != null
                                  ? widget.initialCity
                                  : currentCity,
                          elevation: 16,
                          style:
                              TextStyle(color: Colors.grey[900], fontSize: 14),
                          onChanged: (City newValue) {
                            setState(() {
                              currentCity = newValue;
                              widget.initialCity = null;
                              widget.onChange(currentProvince, currentCity);
                            });
                          },
                          items: currentProvince == null &&
                                  widget.initialProvince != null
                              ? widget.initialProvince.cities
                                  .map<DropdownMenuItem<City>>((City value) {
                                  return DropdownMenuItem<City>(
                                    value: value,
                                    child: Text(
                                        value == null ? "??????" : value.name),
                                  );
                                }).toList()
                              : currentProvince == null
                                  ? []
                                  : currentProvince.cities
                                      .map<DropdownMenuItem<City>>(
                                          (City value) {
                                      return DropdownMenuItem<City>(
                                        value: value,
                                        child: Text(
                                            value == null ? "??????" : value.name),
                                      );
                                    }).toList(),
                        )),
                  )
                ],
              ),
              showError
                  ? Container(
                      height: 40,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        "???????? ?????? ?? ?????????? ?????? ???? ???????????? ????????",
                        style: TextStyle(
                            fontSize: 13, color: StaticAppColors.main_color),
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
