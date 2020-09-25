import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Category.dart';
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
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: cities.cities.length,
            controller: ScrollController(),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder:
                (context, position) {
              var city = cities.cities[position];
              print("build $position");
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
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: Languages.languages.length,
          itemBuilder: (context, i) =>
              Text("${Languages.languages[i]}", style: settings.language == i ? titleSmallBlueStyle : titleSmallStyle)
                  .onClick(() {
                settings.language = i;
              }).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2)
      ).marginW(top: Global.blockY * 2)
    );
  }
}

class FindRecordsFilterModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RecordProvider records = Provider.of<RecordProvider>(context);
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
              Text("Выбрано городов: ${records.filterByCities.length}",
                  style: titleSmallStyle),
              Text("выбрать", style: titleSmallBlueStyle).onClick(() {
                showMaterialModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context, s) => RecordSelectCityModalSheet());
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Выбрано специализаций: ${records.filterByServices.length}",
                  style: titleSmallStyle),
              Text("выбрать", style: titleSmallBlueStyle).onClick(() {
                showMaterialModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context, s) => RecordSelectServiceModalSheet());
              }),
            ],
          ).marginW(top: Global.blockY * 2, bottom: Global.blockY),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Показать только с городом"),
              Switch(
                value: records.isOnlyWithCity,
                onChanged: (v) => records.isOnlyWithCity = v,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Показать только с ценой"),
              Switch(
                value: records.isOnlyWithPrice,
                onChanged: (v) => records.isOnlyWithPrice = v,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Включить фильтр"),
              Switch(
                value: records.isFilterEnable,
                onChanged: (v) => records.isFilterEnable = v,
              )
            ],
          )
        ]
      ).marginW(left: margin5, top: Global.blockY * 2, right: margin5)
    );
  }
}

class RecordSelectCityModalSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecordSelectCityModalSheetState();
}

class RecordSelectCityModalSheetState extends State<RecordSelectCityModalSheet> {
  RecordSelectCityModalSheetState();

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
            Text("Выберите город", style: titleStyle),
            Container(
                height: Global.blockY * 50,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Cities.cities.length,
                    itemBuilder: (context, position) {
                      return SelectableCityPreview(position);
                    }))
          ],
        ).paddingW(left: Global.blockX * 5, right: Global.blockX * 5));
  }
}

class SelectableCityPreview extends StatelessWidget {
  final int position;

  SelectableCityPreview(this.position);

  @override
  Widget build(BuildContext context) {
    final RecordProvider records = Provider.of<RecordProvider>(context);
    return Container(
        height: Global.blockY * 5,
        width: Global.blockX * 60,
        child: ListTile(
          dense: true,
          leading: Text("${Cities.cities[position]}",
              style: records.filterByCities.contains(position)
                  ? titleSmallBlueStyle
                  : titleSmallStyle)
              .onClick(() {
            records.toggleCity(position);
          }),
        ).onClick(() => Navigator.pop(context)));
  }
}

class RecordSelectServiceModalSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RecordSelectServiceModalSheetState();
}

class RecordSelectServiceModalSheetState extends State<RecordSelectServiceModalSheet> {
  @override
  Widget build(BuildContext context) {
    final SearchFilterProvider filter =
    Provider.of<SearchFilterProvider>(context);
    final ServicesProvider services = Provider.of<ServicesProvider>(context);
    return Container(
        height: Global.blockY * 75,
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
    final RecordProvider records = Provider.of<RecordProvider>(context);
    return Column(children: <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(service.name,
            style: records.filterByServices.contains(service)
                ? titleSmallBlueStyle
                : hintSmallStyle)
            .onClick(() {
          records.toggleService(service);
        }),
        Switch(
          value: records.filterByServices.contains(service),
          onChanged: (value) => records.toggleService(service),
        )
      ])
    ]).paddingW(left: Global.blockX * 3, right: Global.blockX * 3);
  }
}

// ignore: must_be_immutable
class SketchesFilterModal extends StatelessWidget {
  final TextEditingController _tagsController = TextEditingController();
  Timer _tagsTimer;
  @override
  Widget build(BuildContext context) {
    final SketchesProvider sketches = Provider.of<SketchesProvider>(context);
    final SketchesFilterProvider sketchesFilter = Provider.of<SketchesFilterProvider>(context);
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
                    Text("Стоимость"),
                    RangeSlider(
                      onChanged: (v) {
                        sketchesFilter.values = v;
                      },
                      divisions: 20,
                      labels: RangeLabels(
                        sketchesFilter.values.start.round().toString(),
                        sketchesFilter.values.end.round().toString(),
                      ),
                      min: 0,
                      max: sketches.getMaxPrice(),
                      values: sketchesFilter.values,
                    )
                  ]
              ),
              TextField(
                onChanged: (v) {
                  var timer = Timer(Duration(milliseconds: 500), () {
                    sketchesFilter.tags = _tagsController.text.split(",").map((s) => s.trim()).toList();
                    print(sketchesFilter.tags);
                  });
                  if(_tagsTimer != null)
                    _tagsTimer.cancel();
                  _tagsTimer = timer;
                },
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
                    Text("Только избранные", style: titleSmallBlueStyle),
                    Switch(
                        value: sketchesFilter.isJustFavorite,
                        onChanged: (v) {
                          sketchesFilter.isJustFavorite = v;
                        }
                    )
                  ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Включить фильтр", style: titleSmallBlueStyle),
                    Switch(
                        value: sketchesFilter.isUseFilter,
                        onChanged: (v) {
                          sketchesFilter.isUseFilter = v;
                        }
                    )
                  ]
              )
            ]
        ).paddingAll(Global.blockY)
    );
  }
}

class FilterModal extends StatelessWidget {
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
                Text("Выбрано городов: ${filter.cities.length}",
                    style: titleSmallStyle),
                Text("выбрать", style: titleSmallBlueStyle).onClick(() {
                  showMaterialModalBottomSheet(
                      context: context,
                      builder: (context, s) => SelectCityModalSheet());
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Выбрано специализаций: ${filter.services.length}",
                    style: titleSmallStyle),
                Text("выбрать", style: titleSmallBlueStyle).onClick(() {
                  showMaterialModalBottomSheet(
                      context: context,
                      builder: (context, s) => SelectServiceModalSheet());
                }),
              ],
            ).marginW(top: Global.blockY * 2, bottom: Global.blockY),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Только с высоким рейтингом", style: titleSmallStyle),
                Switch(
                  value: filter.isShowWithHighRate,
                  onChanged: (v) {
                    filter.isShowWithHighRate = v;
                  },
                )
              ],
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
    final SettingProvider settings = Provider.of<SettingProvider>(context);
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
            Text("Настройки приватности", style: titleMediumStyle)
                .marginW(bottom: Global.blockY * 2)
                .center(),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Показывать адресс"),
                  Switch(
                    value: profile.isShowAddress,
                    onChanged: (v) async => UserService.get().updatePrivacy(profile, 0, !profile.isShowAddress)
                  )
                ]
            ).marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Показывать мобильный"),
                  Switch(
                      value: profile.isShowPhone,
                      onChanged: (v) async => UserService.get().updatePrivacy(profile, 1, !profile.isShowPhone)
                  )
                ]
            ).marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Показывать email"),
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
  State<StatefulWidget> createState() => SelectStyleState(data);
}

class SelectStyleState extends State<SelectStyleModal> {
  final SketchData data;
  SelectStyleState(this.data);
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
            print("${s.connectionState}, ${s.hasData}, ${s.hasError}, ${s.data}");
            if(s.hasData) {
              StylesHolder.styles.clear();
              StylesHolder.styles.addAll(s.data);
            }
            if(s.hasData && s.connectionState == ConnectionState.done) {
              return buildStylesList(s.data);
            }
            else if(StylesHolder.styles.isNotEmpty) {
              return buildStylesList(StylesHolder.styles);
            }
            else if(StylesHolder.styles.isEmpty)
              return CircularProgressIndicator();
            else {
              return Text("Нету данных").center();
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
                      Text("${style.name}", style: style.id == widget?.data?.style?.id ? titleMediumBlueStyle : textStyle),
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
  State<StatefulWidget> createState() => SelectPositionState(data);
}

class SelectPositionState extends State<SelectPositionModal> {
  final SketchData data;
  SelectPositionState(this.data);
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
          print("${s.connectionState}, ${s.hasData}, ${s.hasError}, ${s.data}");
          if(s.hasData) {
            PositionsHolder.positions.clear();
            PositionsHolder.positions.addAll(s.data);
          }
          if(s.hasData && s.connectionState == ConnectionState.done) {
            return buildPositionsList(s.data);
          }
          else if(PositionsHolder.positions.isNotEmpty) {
            return buildPositionsList(PositionsHolder.positions);
          }
          else if(PositionsHolder.positions.isEmpty)
            return CircularProgressIndicator();
          else {
            return Text("Нету данных").center();
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
                      Text("${position.name}", style: position == widget.data.position ? titleMediumBlueStyle : textStyle),
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
      child: ListView(
        shrinkWrap: true,
        children: [
         Text("Цветная", style: _data.isColored ? titleSmallBlueStyle : textSmallStyle)
             .marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY)
             .onClick(() {
           if(!_data.isColored)
             setState(() {
               _data.isColored = true;
             });
         }) ,
         Text("Черно-белая", style: !_data.isColored ? titleSmallBlueStyle : textSmallStyle)
             .marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY)
             .onClick(() {
           if(_data.isColored)
             setState(() {
               _data.isColored = false;
             });
         })
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
    print("service ${widget.service.toString()}");
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: defaultModalBorderRadius
        ),
        child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Удалить", style: widget.service.wrapper == null ? TextStyle(color: Colors.transparent) : titleSmallBlueStyle)
                  .onClick(() async {
                    if(widget.service.wrapper != null) {
                      var r = await ServicesRepository.get().deleteMasterService(profile, widget.service.wrapper);
                      if(r)
                        setState(() {
                          widget.service.wrapper = null;
                        });
                    }
                  }),
                  Text("Редактирование услуг", style: titleMediumStyle),
                  _isInProcess ?
                  CircularProgressIndicator().sizeW(Global.blockY * 3, Global.blockY * 3) :
                  Text("Сохранить", style: titleSmallBlueStyle)
                      .onClick(() async {
                        setState(() {
                          _isInProcess = true;
                        });
                        if(widget.service.wrapper == null) {
                          var wrapper = ServiceWrapper(0,
                              widget.service.id,
                              _priceServiceController.text == null ? null : int.parse(_priceServiceController.text),
                              _timeServiceController.text == null ? null : int.parse(_timeServiceController.text),
                              _commentServiceController.text);
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
                        Text("Стоимость работы, грн", style: titleSmallStyle),
                        Container(
                            width: Global.blockX * 40,
                            child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _priceServiceController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Стоимость, грн",
                                    hintStyle: hintSmallStyle
                                )
                            )
                        )
                      ]
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Время работы, мин", style: titleSmallStyle),
                        Container(
                            width: Global.blockX * 40,
                            child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _timeServiceController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Время работы, мин",
                                    hintStyle: hintSmallStyle
                                )
                            )
                        )
                      ]
                    )
                  ]
              ).marginW(left: margin5, right: margin5),
              Text("Ваш комментарий", style: titleSmallStyle).marginW(left: margin5, right: margin5),
              TextField(
                controller: _commentServiceController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Комментарий к услуге",
                    hintStyle: hintSmallStyle
                ),
              ).marginW(left: margin5, right: margin5)
            ]
        )
    );
  }
}