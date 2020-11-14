import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_app/holders/CitiesHolder.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/City.dart';
import 'package:style_app/model/NotifySettings.dart';
import 'package:style_app/model/Position.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/ServiceWrapper.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/model/Style.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/RecordProvider.dart';
import 'package:style_app/providers/SearchFilterProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/providers/SettingProvider.dart';
import 'package:style_app/providers/SketchesFilterProvider.dart';
import 'package:style_app/providers/SketchesProvider.dart';
import 'package:style_app/holders/PositionsHolder.dart';
import 'package:style_app/holders/StylesHolder.dart';
import 'package:style_app/service/PositionsRepository.dart';
import 'package:style_app/service/ProfileService.dart';
import 'package:style_app/service/ServicesRepository.dart';
import 'package:style_app/service/StylesRepository.dart';
import 'package:style_app/ui/FindMasterScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Widget.dart';
import 'package:style_app/utils/Style.dart';

class SelectCityModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final CitiesProvider cities = Provider.of<CitiesProvider>(context);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(10)),
            color: Colors.white),
        child: Wrap(
          children: [
            Text(FlutterI18n.translate(context, "select_city"), style: titleMediumStyle)
                .marginW(top: Global.blockY * 2)
                .center(),
            ListView.builder(
                shrinkWrap: true,
                itemCount: cities.cities.length,
                controller: ScrollController(),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder:
                    (context, position) {
                  var city = cities.cities[position];
                  return Container(
                      height:
                      Global.blockY * 5,
                      child: ListTile(
                        dense: true,
                        leading: Text(
                            "${city.name}", style: city.id == profile.city ? titleSmallBlueStyle : titleSmallStyle)
                            .onClick(() {
                          profile.city = city.id;
                        }),
                      ).onClick(() =>
                          Navigator.pop(
                              context)));
                })
          ]
        )
    );
  }
}

class SelectOrderCityModal extends StatelessWidget {
  final City city;
  SelectOrderCityModal(this.city);

  @override
  Widget build(BuildContext context) {
    final CitiesProvider cities = Provider.of<CitiesProvider>(context);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(10)),
            color: Colors.white),
        child: Wrap(
          children: [
            Text(FlutterI18n.translate(context, "select_city"), style: titleMediumStyle)
            .marginW(top: Global.blockY)
            .center(),
            ListView.builder(
                shrinkWrap: true,
                itemCount: cities.cities.length,
                controller: ScrollController(),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder:
                    (context, position) {
                  var city0 = cities.cities[position];
                  return Container(
                      height:
                      Global.blockY * 5,
                      child: ListTile(
                        dense: true,
                        leading: Text(
                            city0.name, style: city0.id == city.id ? titleSmallBlueStyle : titleSmallStyle),
                      ).onClick(() =>
                          Navigator.pop(
                              context, city0 == city ? null : city0)));
                })
          ]
        )
    );
  }
}

class SelectLanguageModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SettingProvider settings = Provider.of<SettingProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: defaultItemBorderRadius
      ),
      child: Wrap(
        children: [
          Text(FlutterI18n.translate(context, "select_language"), style: titleMediumStyle)
              .marginW(top: Global.blockY * 2)
              .center(),
          ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: Languages.languages.map((l) =>
                  Text(l.name, style: settings.language.id == l.id ? titleSmallBlueStyle : titleSmallStyle)
                      .onClick(() async {
                    var s = await SharedPreferences.getInstance();
                    await FlutterI18n.refresh(context, l.locale);
                    settings.language = l;
                    s.setInt("locale", l.id);
                    print("set string ${l.locale.languageCode}_${l.locale.countryCode}");
                  }).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2)
              ).toList()
          ).marginW(top: Global.blockY * 2)
        ]
      )
    );
  }
}

class FindOrdersFilterModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OrdersProvider orders = Provider.of<OrdersProvider>(context);
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: defaultItemBorderRadius
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${FlutterI18n.translate(context, "selected_cities_count")} ${orders.cities.length}",
                  style: titleSmallStyle),
              Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => OrderSelectCityModalSheet());
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${FlutterI18n.translate(context, "selected_services_count")} ${orders.services.length}",
                  style: titleSmallStyle),
              Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => OrderSelectServiceModalSheet());
              }),
            ],
          ).marginW(top: Global.blockY * 2, bottom: Global.blockY),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(FlutterI18n.translate(context, "show_only_with_city"),
                  style: titleSmallStyle),
              Switch(
                value: orders.isOnlyWithCity,
                onChanged: (v) => orders.isOnlyWithCity = v,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(FlutterI18n.translate(context, "show_only_with_price"),
                  style: titleSmallStyle),
              Switch(
                value: orders.isOnlyWithPrice,
                onChanged: (v) => orders.isOnlyWithPrice = v,
              )
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                    onPressed: () async {
                      Navigator.pop(
                          context,
                        {
                          "isUseFilter": false,
                          "filter": ""
                        }
                      );
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: defaultItemBorderRadius
                    ),
                    color: Colors.white,
                    child:
                    Text(FlutterI18n.translate(context, "clean"), style: titleSmallBlueStyle)),
                RaisedButton(
                    onPressed: () async {
                      var filterString = "";
                      var filters = <String> [];
                      if(orders.cities.isNotEmpty) {
                        filters.add("cities=${orders.cities.map<int>((city) => city.id).toList().join(",")}");
                      }
                      if(orders.services.isNotEmpty) {
                        filters.add("services=${orders.services.map<int>((service) => service.id).toList().join(",")}");
                      }
                      filters.add("price=${orders.isOnlyWithPrice}");
                      filters.add("city=${orders.isOnlyWithCity}");
                      filterString = filters.join("&");
                      print(filterString);
                      Navigator.pop(context,
                          {
                            "isUseFilter": true,
                            "filter": filterString
                          }
                      );
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: defaultItemBorderRadius
                    ),
                    color: primaryColor,
                    child:
                    Text(FlutterI18n.translate(context, "filter"), style: smallWhiteStyle))
              ]
          )
        ]
      ).marginW(left: margin5, top: Global.blockY * 2, right: margin5)
    );
  }
}

class OrderSelectCityModalSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OrderSelectCityModalSheetState();
}

class OrderSelectCityModalSheetState extends State<OrderSelectCityModalSheet> {
  OrderSelectCityModalSheetState();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Global.blockY * 75,
        decoration: BoxDecoration(
            borderRadius: defaultItemBorderRadius,
            color: Colors.white),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text("Выберите город", style: titleStyle)
                .marginW(top: Global.blockY * 2)
                .center(),
            Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: CitiesHolder.cities.length,
                    itemBuilder: (context, position) {
                      return SelectableCityPreview(CitiesHolder.cities[position]);
                    }))
          ],
        ).paddingW(left: Global.blockX * 5, right: Global.blockX * 5));
  }
}

class SelectableCityPreview extends StatelessWidget {
  final City city;

  SelectableCityPreview(this.city);

  @override
  Widget build(BuildContext context) {
    final OrdersProvider records = Provider.of<OrdersProvider>(context);
    return Container(
        height: Global.blockY * 5,
        width: Global.blockX * 60,
        child: ListTile(
          dense: true,
          leading: Text(city.name,
              style: records.cities.contains(city)
                  ? titleSmallBlueStyle
                  : titleSmallStyle)
              .onClick(() {
            records.toggleCity(city);
          }),
        ).onClick(() => Navigator.pop(context)));
  }
}

class OrderSelectServiceModalSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OrderSelectServiceModalSheetState();
}

class OrderSelectServiceModalSheetState extends State<OrderSelectServiceModalSheet> {
  @override
  Widget build(BuildContext context) {
    final SearchFilterProvider filter =
    Provider.of<SearchFilterProvider>(context);
    final ServicesProvider services = Provider.of<ServicesProvider>(context);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            color: Colors.white),
        child: ListView(
            shrinkWrap: true,
            children:
            buildServiceList(filter, services.map))
            .marginAll(Global.blockX))
        .background(Colors.transparent);
  }

  List<Widget> buildServiceList(
      SearchFilterProvider filter, List<Category> map) {
    List<Widget> widgets = <Widget>[];
    widgets.add(Text("Выберите услуги", style: titleStyle)
        .center()
        .marginW(bottom: Global.blockY));
    map.forEach((value) {
      widgets.add(Container(
          alignment: Alignment.bottomLeft,
          color: Colors.grey.withOpacity(0.1),
          child: Text(value.name, style: titleMediumStyle)));
      value.services?.forEach((service) {
        widgets.add(SelectableServicePreview(service));
      });
    });
    return widgets;
  }
}

class SelectableServicePreview extends StatelessWidget {
  final Service service;

  SelectableServicePreview(this.service);

  @override
  Widget build(BuildContext context) {
    final OrdersProvider order = Provider.of<OrdersProvider>(context);
    return Column(children: <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(service.name,
            style: order.services.contains(service)
                ? titleSmallBlueStyle
                : hintSmallStyle)
            .onClick(() {
          order.toggleService(service);
        }),
        Switch(
          value: order.services.contains(service),
          onChanged: (value) => order.toggleService(service),
        )
      ])
    ]).paddingW(left: Global.blockX * 3, right: Global.blockX * 3);
  }
}

class SketchesFilterModal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SketchesFilterModalState();
}

class SketchesFilterModalState extends State<SketchesFilterModal> {
  TextEditingController _tagsController;
  TextEditingController _minPriceController;
  TextEditingController _maxPriceController;

  @override
  void initState() {
    _tagsController = TextEditingController();
    _minPriceController = TextEditingController();
    _maxPriceController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SketchesProvider sketches = Provider.of<SketchesProvider>(context);
    final SketchesFilterProvider filter = Provider.of<SketchesFilterProvider>(context);

    _minPriceController.text = "${filter.min ?? ""}";
    _maxPriceController.text = "${filter.max ?? ""}";
    _tagsController.text = filter.tags;

    return Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: defaultModalRadius
        ),
        child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(FlutterI18n.translate(context, "price"), style: titleSmallStyle),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: Global.blockY),
                          width: Global.blockX * 25,
                          child: TextField(
                            controller: _minPriceController,
                            minLines: 1,
                            maxLines: 10,
                            decoration: InputDecoration(
                                hintText: "От",
                                hintStyle: hintSmallStyle,
                                border: InputBorder.none
                            )
                          )
                        ),
                        Container(
                          width: Global.blockX * 25,
                          child: TextField(
                              controller: _maxPriceController,
                              minLines: 1,
                              maxLines: 10,
                              decoration: InputDecoration(
                                  hintText: "До",
                                  hintStyle: hintSmallStyle,
                                  border: InputBorder.none
                              )
                          )
                        )
                      ]
                    )
                  ]
              ),
              TextField(
                controller: _tagsController,
                minLines: 1,
                maxLines: 10,
                decoration: InputDecoration(
                    hintText: "Введите теги",
                    hintStyle: hintSmallStyle,
                    border: InputBorder.none
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(FlutterI18n.translate(context, "show_only_favorites"), style: titleSmallBlueStyle),
                    Switch(
                        value: filter.isJustFavorite,
                        onChanged: (v) {
                          filter.isJustFavorite = v;
                        }
                    )
                  ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                        onPressed: () async {
                          filter.min = null;
                          filter.max = null;
                          filter.tags = "";
                          Navigator.pop(context, {
                            "isUseFilter": false
                          });
                        },
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: defaultItemBorderRadius
                        ),
                        color: Colors.white,
                        child:
                        Text(FlutterI18n.translate(context, "clean"), style: titleSmallBlueStyle)),
                    RaisedButton(
                        onPressed: () async {
                          var filterString = "";
                          var filters = <String> [];
                          if(_minPriceController.text.isNotEmpty && _minPriceController.text.length > 0) {
                            var min = int.parse(_minPriceController.text ?? "-1");
                            if(min > -1) {
                              filters.add("min=$min");
                              filter.min = min;
                            }
                          }
                          if(_maxPriceController.text.isNotEmpty && _maxPriceController.text.length > 0) {
                            var max = int.parse(_maxPriceController.text ?? "-1");
                            if(max > -1) {
                              filters.add("max=$max");
                              filter.max = max;
                            }
                          }
                          if(_tagsController.text.isNotEmpty && _tagsController.text.length > 0) {
                            var tags = _tagsController
                                .text
                                .replaceAll(" ,", ",")
                                .replaceAll(", ", ",")
                                .replaceAll(" ", ",")
                                .replaceAll("\n", ",");
                            filters.add("tags=$tags");
                            filter.tags = tags;
                          }
                          filters.add("favorites=${filter.isJustFavorite}");
                          filterString = filters.join("&");
                          print(filterString);
                          Navigator.pop(context, {
                            "isUserFilter": true,
                            "filter": filterString
                          });
                        },
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: defaultItemBorderRadius
                        ),
                        color: primaryColor,
                        child:
                        Text(FlutterI18n.translate(context, "filter"), style: smallWhiteStyle))
                  ]
              )
            ]
        ).paddingAll(Global.blockY)
    );
  }
}

class MastersFilterModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SearchFilterProvider filter =
    Provider.of<SearchFilterProvider>(context);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            color: Colors.white),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${FlutterI18n.translate(context, "selected_cities_count")} ${filter.cities.length}",
                    style: titleSmallStyle),
                Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SelectCityModalSheet());
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${FlutterI18n.translate(context, "selected_services_count")} ${filter.services.length}",
                    style: titleSmallStyle),
                Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SelectServiceModalSheet());
                }),
              ],
            ).marginW(top: Global.blockY * 3, bottom: Global.blockY),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(FlutterI18n.translate(context, "show_only_with_high_rate"), style: titleSmallStyle),
                Switch(
                  value: filter.isShowWithHighRate,
                  onChanged: (v) {
                    filter.isShowWithHighRate = v;
                  },
                )
              ],
            ).marginW(bottom: Global.blockY),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                    onPressed: () async {
                      Navigator.pop(context, {
                        "isUseFilter": false
                      });
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: defaultItemBorderRadius
                    ),
                    color: Colors.white,
                    child:
                    Text(FlutterI18n.translate(context, "clean"), style: titleSmallBlueStyle)),
                RaisedButton(
                    onPressed: () async {
                      var filterString = "";
                      var filters = <String> [];
                      if(filter.cities.isNotEmpty) {
                        filters.add("cities=${filter.cities.map<int>((city) => city.id).toList().join(",")}");
                      }
                      if(filter.services.isNotEmpty) {
                        filters.add("services=${filter.services.map<int>((service) => service.id).toList().join(",")}");
                      }
                      filters.add("rate=${filter.isShowWithHighRate}");
                      filterString = filters.join("&");
                      Navigator.pop(context, {
                        "isUserFilter": true,
                        "filter": filterString
                      });
                    },
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: defaultItemBorderRadius
                    ),
                    color: primaryColor,
                    child:
                    Text(FlutterI18n.translate(context, "filter"), style: smallWhiteStyle))
              ]
            )
          ],
        ).paddingW(
            left: Global.blockX * 5,
            top: Global.blockY * 2,
            right: Global.blockX * 5));
  }
}

class PrivateSettingsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
      padding: EdgeInsets.only(top: Global.blockY, bottom: Global.blockY * 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: defaultItemBorderRadius
      ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(FlutterI18n.translate(context, "privacy_settings"), style: titleMediumStyle)
                .marginW(bottom: Global.blockY * 2)
                .center(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(FlutterI18n.translate(context, "show_address")),
                  Switch(
                    value: profile.isShowAddress,
                    onChanged: (v) async => UserService.get().updatePrivacy(profile, 0, !profile.isShowAddress)
                  )
                ]
            ).marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(FlutterI18n.translate(context, "show_phone")),
                  Switch(
                      value: profile.isShowPhone,
                      onChanged: (v) async => UserService.get().updatePrivacy(profile, 1, !profile.isShowPhone)
                  )
                ]
            ).marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(FlutterI18n.translate(context, "show_email")),
                  Switch(
                    value: profile.isShowEmail,
                    onChanged: (v) async => UserService.get().updatePrivacy(profile, 2, !profile.isShowEmail)
                  )
                ]
            ).marginW(left: margin5, right: margin5),
          ]
        )
    );
  }
}

class SelectStyleModal extends StatefulWidget {
  final SketchData data;
  SelectStyleModal(this.data);
  @override
  State<StatefulWidget> createState() => SelectStyleState();
}

class SelectStyleState extends State<SelectStyleModal> {
  SelectStyleState();
  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
        height: Global.blockY * 45,
        padding: EdgeInsets.only(top: Global.blockY * 2),
        decoration: BoxDecoration(
            borderRadius: defaultModalBorderRadius,
            color: Colors.white
        ),
        child: FutureBuilder(
          future: StylesRepository.get().getAllStyles(profile),
          builder: (c, s) {
            if(s.hasData) {
              StylesHolder.styles.clear();
              StylesHolder.styles.addAll(s.data);
            }
            if(s.hasData && s.connectionState == ConnectionState.done) {
              return Wrap(
                children: [
                  Text(FlutterI18n.translate(context, "select_style"), style: titleMediumStyle)
                  .center(),
                  buildStylesList(s.data)
                ]
              );
            }
            else if(StylesHolder.styles.isNotEmpty) {
              return Wrap(
                  children: [
                    Text(FlutterI18n.translate(context, "select_style"), style: titleMediumStyle)
                    .center(),
                    buildStylesList(StylesHolder.styles)
                  ]
              );
            }
            else if(StylesHolder.styles.isEmpty)
              return CircularProgressIndicator().center();
            else {
              return Text(FlutterI18n.translate(context, "no_data")).center();
            }
          },
        )
    );
  }

  Widget buildStylesList(List<Style> styles) {
    return ListView(
        shrinkWrap: true,
        children: styles.map((style) =>
            Container(
                margin: EdgeInsets.only(bottom: Global.blockY),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(style.name, style: style.id == widget?.data?.style?.id ? titleMediumBlueStyle : textStyle),
                    ]
                )
            ).marginW(left: margin5, right: margin5)
                .onClick(() {
              setState(() => widget.data.style = style);
            })
        ).toList()
    );
  }
}

class SelectPositionModal extends StatefulWidget {
  final SketchData data;
  SelectPositionModal(this.data);
  @override
  State<StatefulWidget> createState() => SelectPositionState();
}

class SelectPositionState extends State<SelectPositionModal> {
  SelectPositionState();
  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
      height: Global.blockY * 45,
      padding: EdgeInsets.only(top: Global.blockY * 2),
      decoration: BoxDecoration(
          borderRadius: defaultModalBorderRadius,
          color: Colors.white
      ),
      child: FutureBuilder(
        future: PositionsRepository.get().getAllPositions(profile),
        builder: (c, s) {
          if(s.hasData) {
            PositionsHolder.positions.clear();
            PositionsHolder.positions.addAll(s.data);
          }
          if(s.hasData && s.connectionState == ConnectionState.done) {
            return Wrap(
              children: [
                Text(FlutterI18n.translate(context, "select_position"), style: titleMediumStyle).center(),
                buildPositionsList(s.data)
              ],
            );
          }
          else if(PositionsHolder.positions.isNotEmpty) {
            return Wrap(
              children: [
                Text(FlutterI18n.translate(context, "select_position"), style: titleMediumStyle).center(),
                buildPositionsList(PositionsHolder.positions)
              ]
            );
          }
          else if(PositionsHolder.positions.isEmpty)
            return CircularProgressIndicator().center();
          else {
            return Text(FlutterI18n.translate(context, "no_data")).center();
          }
        },
      )
    );
  }

  Widget buildPositionsList(List<Position> positions) {
    return ListView(
        shrinkWrap: true,
        children: PositionsHolder.positions.map((position) =>
            Container(
                margin: EdgeInsets.only(bottom: Global.blockY),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(position.name, style: position.id == widget?.data?.position?.id ?? false ? titleMediumBlueStyle : textStyle),
                    ]
                )
            ).marginW(left: margin5, right: margin5)
                .onClick(() {
              setState(() => widget.data.position = position);
            })
        ).toList()
    );
  }
}

class SelectColorModal extends StatefulWidget {
  final SketchData _data;
  SelectColorModal(this._data);

  @override
  State<StatefulWidget> createState() => SelectColorState(_data);
}

class SelectColorState extends State<SelectColorModal> {
  final SketchData _data;
  SelectColorState(this._data);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: Global.blockY * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: defaultModalBorderRadius
      ),
      child: Wrap(
        children: [
          Text(FlutterI18n.translate(context, "select_color"), style: titleMediumStyle).center(),
          ListView(
              shrinkWrap: true,
              children: [
                Text(FlutterI18n.translate(context, "colored"), style: _data.isColored ? titleSmallBlueStyle : textSmallStyle)
                    .marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY)
                    .onClick(() {
                  if(!_data.isColored)
                    setState(() {
                      _data.isColored = true;
                    });
                }) ,
                Text(FlutterI18n.translate(context, "non_colored"), style: !_data.isColored ? titleSmallBlueStyle : textSmallStyle)
                    .marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY)
                    .onClick(() {
                  if(_data.isColored)
                    setState(() {
                      _data.isColored = false;
                    });
                })
              ]
          )
        ]
      )
    );
  }
}

class EditMasterServiceModal extends StatefulWidget {
  final Service service;
  EditMasterServiceModal(this.service);

  @override
  State<StatefulWidget> createState() => EditMasterServiceState();
}

class EditMasterServiceState extends State<EditMasterServiceModal> {
  TextEditingController _commentServiceController;
  TextEditingController _priceServiceController;
  TextEditingController _timeServiceController;
  bool _isInProcess = false;

  @override
  void initState() {
    _commentServiceController = TextEditingController(text: widget.service?.wrapper?.description != null ? widget.service.wrapper.description : "");
    _priceServiceController = TextEditingController(text: widget.service?.wrapper?.price != null ? "${widget.service.wrapper.price}" : "");
    _timeServiceController = TextEditingController(text: widget.service?.wrapper?.time != null ? "${widget.service.wrapper.time}" : "");
    super.initState();
  }

  @override
  void dispose() {
    _commentServiceController.dispose();
    _priceServiceController.dispose();
    _timeServiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: defaultModalBorderRadius
        ),
        child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(FlutterI18n.translate(context, "delete"), style: widget.service.wrapper == null ? TextStyle(color: Colors.transparent) : titleSmallBlueStyle)
                  .onClick(() async {
                    if(widget.service.wrapper != null) {
                      var r = await ServicesRepository.get().deleteMasterService(profile, widget.service.wrapper);
                      if(r)
                        setState(() {
                          widget.service.wrapper = null;
                        });
                    }
                  }),
                  Text(FlutterI18n.translate(context, "edit_services"), style: titleMediumStyle),
                  _isInProcess ?
                  CircularProgressIndicator().sizeW(Global.blockY * 3, Global.blockY * 3) :
                  Text(FlutterI18n.translate(context, "save"), style: titleSmallBlueStyle)
                      .onClick(() async {
                        setState(() {
                          _isInProcess = true;
                        });
                        if(widget.service.wrapper == null) {
                          var wrapper = ServiceWrapper(
                              0,
                              widget.service.id,
                              _priceServiceController.text.isEmpty ? null : int.parse(_priceServiceController.text),
                              _timeServiceController.text.isEmpty ? null : int.parse(_timeServiceController.text),
                              _commentServiceController?.text ?? "");
                          var r = await ServicesRepository.get().createMasterService(profile, wrapper);
                          if(r != null) {
                            setState(() {
                              wrapper.id = r.id;
                              widget.service.wrapper = wrapper;
                            });
                          }
                        } else {
                          var r = await ServicesRepository.get().updateMasterService(
                              profile,
                              widget.service.wrapper,
                              _commentServiceController.text,
                              int.parse(_priceServiceController.text),
                              int.parse(_timeServiceController.text)
                          );
                          if(r != null) {
                            widget.service.wrapper.description = _commentServiceController.text;
                            widget.service.wrapper.price = int.parse(_priceServiceController.text);
                            widget.service.wrapper.time = int.parse(_timeServiceController.text);
                          }
                        }
                        setState(() {
                          _isInProcess = false;
                        });
                  })
                ]
              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(FlutterI18n.translate(context, "work_price"), style: titleSmallStyle),
                        Container(
                            width: Global.blockX * 40,
                            child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _priceServiceController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: FlutterI18n.translate(context, "price"),
                                    hintStyle: hintSmallStyle
                                )
                            )
                        )
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(FlutterI18n.translate(context, "work_time"), style: titleSmallStyle),
                        Container(
                            width: Global.blockX * 40,
                            child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _timeServiceController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: FlutterI18n.translate(context, "work_time"),
                                    hintStyle: hintSmallStyle
                                )
                            )
                        )
                      ]
                    )
                  ]
              ).marginW(left: margin5, right: margin5),
              Text(FlutterI18n.translate(context, "comment_for_service"), style: titleSmallStyle).marginW(left: margin5, right: margin5),
              TextField(
                controller: _commentServiceController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: FlutterI18n.translate(context, "comment_for_service"),
                    hintStyle: hintSmallStyle
                ),
              ).marginW(left: margin5, right: margin5)
            ]
        )
    );
  }
}