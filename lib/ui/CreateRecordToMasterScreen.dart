import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/ServiceWrapper.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/NewRecordProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/RecordProvider.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class RecordingToTheMaster extends StatefulWidget {
  final UserData _masterData;
  final Sketch _sketch;
  RecordingToTheMaster(this._masterData, this._sketch);
  @override
  State<StatefulWidget> createState() => RecordingToTheMasterState(_masterData, _sketch);
}

class RecordingToTheMasterState extends State<RecordingToTheMaster> {
  TextEditingController _nameController;
  TextEditingController _commentController;
  TextEditingController _priceController;
  TextEditingController _widthController;
  TextEditingController _heightController;
  UserData _masterData;
  Order _record;
  SketchData _data = SketchData();
  final Sketch _sketch;
  List<String> _media = [];
  RecordingToTheMasterState(this._masterData, this._sketch);

  @override
  void initState() {
    _nameController = TextEditingController(text: _sketch != null ? _sketch.data.tags : "");
    _commentController = TextEditingController(text: _sketch != null ? _sketch.data.description : "");
    _priceController = TextEditingController(text: _sketch != null ? "${_sketch.data.price}" : "");
    _widthController = TextEditingController(text: _sketch != null ? "${_sketch.data.width}" : "");
    _heightController = TextEditingController(text: _sketch != null ? "${_sketch.data.height}" : "");
    if(_sketch != null)
      _media.addAll(_sketch.photos);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    _priceController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NewRecordProvider record = Provider.of<NewRecordProvider>(context);
    final RecordProvider recordProvider = Provider.of<RecordProvider>(context);
    final ProfileProvider user = Provider.of<ProfileProvider>(context);
    return Scaffold(
        appBar: null,
        backgroundColor: Colors.white,
        floatingActionButton: Visibility(
          visible: record.services.isNotEmpty,
          child: RaisedButton(
            onPressed: () {
              _record = Order(111,
                  user.id,
                  _masterData.id,
                  _priceController.text == null || _priceController.text.isEmpty ? null : int.parse(_priceController.text),
                  3,
                  null,
                  _nameController.text,
                  _commentController.text,
                  record.services,
                  [],
                  true,
                  DateTime.now(),
                  [],
                  // sketch: _sketch..clone()
              );
              recordProvider.addRecord(_record);
              record.services.clear();
              Navigator.pop(context, "refresh");
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: defaultItemBorderRadius
            ),
            color: Colors.blueAccent,
            child: Text("Подтвердить запись", style: recordButtonStyle),
          )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios, size: 20).onClick(() => Navigator.pop(context)),
                  Text("Запись к мастеру", style: titleMediumStyle),
                  Icon(Icons.arrow_back_ios, color: Colors.white)
                ]
              ).marginW(left: margin5, right: margin5)
                  .sizeW(Global.width, Global.blockY * 10),
              Expanded(
                child: Container(
                  width: Global.width,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          width: Global.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 15,
                                    offset: Offset(0, 10))
                              ]
                          ),
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${_masterData.name} ${_masterData.surname}", style: titleMediumStyle).center(),
                              Text("Название", style: titleMediumStyle)
                                  .paddingW(left: Global.blockX * 5, right: Global.blockX * 5),
                              Container(
                                child: TextField(
                                    controller: _nameController,
                                    style: textSmallStyle,
                                    decoration: InputDecoration(
                                        hintText: "Введите теги для названия",
                                        hintStyle: hintSmallStyle,
                                        border: InputBorder.none
                                    )
                                )
                              ).marginW(left: margin5, right: margin5),
                              Visibility(
                                visible: _sketch == null,
                                child: Column(
                                  children: [
                                    Text("Услуги", style: titleMediumStyle)
                                        .paddingW(left: Global.blockX * 5, right: Global.blockX * 5),
                                    // Container(
                                    //     child: Column(
                                    //         children: buildServiceList(
                                    //             _masterData.services
                                    //         )
                                    //     )
                                    // ).paddingW(top: Global.blockX * 3, bottom: Global.blockX * 3)
                                  ]
                                )
                              ),
                              Visibility(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                       Text("Стили", style: titleMediumStyle),
                                       Text("выбрать", style: titleSmallBlueStyle)
                                        .onClick(() async {
                                          await showModalBottomSheet(
                                              backgroundColor: Colors.transparent,
                                              context: context,
                                              builder: (c) => SelectStyleModal(_data));
                                          setState(() {});
                                       })
                                      ]
                                    ),
                                    Container(
                                      child: _data.style == null ?
                                      Text("Стиль не выбран").paddingW(top: Global.blockY, bottom: Global.blockY) :
                                      Text(_data.style.name)
                                    ).marginW(top: Global.blockY, bottom: Global.blockY)
                                  ]
                                )
                              ).marginW(left: margin5, right: margin5),
                              Visibility(
                                  visible: record.containsTatooService(),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Рассположение татуировки", style: titleMediumStyle)
                                            .paddingW(left: Global.blockX * 5, right: Global.blockX * 5),
                                        Text("${_data.position == null ? "Рассположение" : _data.position.name }", style: titleSmallBlueStyle)
                                            .marginW(left: margin5, top: Global.blockY * 2, right: margin5, bottom: Global.blockY * 2)
                                        .onClick(() async {
                                          await showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (c) => SelectPositionModal(_data)
                                          );
                                          setState(() {});
                                        })
                                      ]
                                  )
                              ),
                              Visibility(
                                  visible: record.containsTatooService(),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Цвет татуировки", style: titleMediumStyle)
                                            .paddingW(left: Global.blockX * 5, right: Global.blockX * 5),
                                        Text(_data.isColored ? "Йветная" : "Черно-белая", style: titleSmallBlueStyle)
                                            .marginW(left: margin5, top: Global.blockY * 2, right: margin5, bottom: Global.blockY * 2)
                                        .onClick(() async {
                                          await showModalBottomSheet(
                                            context: context,
                                            backgroundColor: Colors.transparent,
                                            builder: (c) => SelectPositionModal(_data)
                                          );
                                          setState(() {});
                                        })
                                      ]
                                  )
                              ),
                              Visibility(
                                  visible: record.containsTatooService(),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Цвет татуировки", style: titleMediumStyle),
                                            Text("выбрать", style: titleSmallBlueStyle)
                                            .onClick(() async {
                                              await showModalBottomSheet(
                                                backgroundColor: Colors.transparent,
                                                  context: context,
                                                  builder: (c) => SelectColorModal(_sketch.data));
                                              setState(() {});
                                            }),
                                          ]
                                        )
                                            .paddingW(left: Global.blockX * 5, right: Global.blockX * 5),
                                        Text(_data.isColored ? "Цветная" : "Черно-белая", style: textSmallStyle)
                                            .marginW(left: margin5, top: Global.blockY * 2, right: margin5, bottom: Global.blockY * 2)
                                      ]
                                  )
                              ),
                              Visibility(
                                  visible: record.containsTatooService(),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Введите размеры татуировки, см", style: titleMediumStyle)
                                            .paddingW(left: Global.blockX * 5, right: Global.blockX * 5),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: TextField(
                                                      style: textSmallStyle,
                                                      controller: _widthController,
                                                      decoration: InputDecoration(
                                                          hintStyle: hintSmallStyle,
                                                          hintText: "Ширина",
                                                          border: InputBorder.none
                                                      )
                                                  )
                                              ),
                                              Expanded(
                                                  child: TextField(
                                                      style: textSmallStyle,
                                                      controller: _heightController,
                                                      decoration: InputDecoration(
                                                          hintStyle: hintSmallStyle,
                                                          hintText: "Высота",
                                                          border: InputBorder.none
                                                      )
                                                  )
                                              )
                                            ]
                                        ).marginW(left: margin5, right: margin5),
                                      ]
                                  )
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Изображения", style: titleMediumStyle),
                                    Text("добавить", style: titleSmallBlueStyle)
                                        .onClick(() async {
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.getImage(source: ImageSource.gallery);
                                      if(pickedFile != null)
                                        setState(() {
                                          _media.add(pickedFile.path);
                                          // _media.add(File(pickedFile.path));
                                        });
                                    })
                                  ]
                              ).paddingW(left: margin5,
                                  right: margin5,
                                  top: Global.blockX,
                                  bottom: Global.blockX * 3),
                              Container(
                                  padding: EdgeInsets.only(top: Global.blockX, bottom: Global.blockY * 2),
                                  child: _media.isEmpty ? Container(
                                      child: Text("Нету добавленных изображений")
                                  ).marginW(left: margin5,
                                      right: margin5) :
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      enableInfiniteScroll: false,
                                    ),
                                    items: _media.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: Text('$i', style: TextStyle(fontSize: 16.0)).center()
                                            // Image.file(i, fit: BoxFit.contain),
                                          ).onClick(() {
                                            Navigator.push(context, MaterialWithModalsPageRoute(
                                                builder: (context) => ImagePage(_media)
                                            ));
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ).marginW(top: Global.blockX, bottom: Global.blockX)
                              ),
                              Text("Комментарий", style: titleMediumStyle)
                                  .marginW(left: margin5, right: margin5),
                              TextField(
                                controller: _commentController,
                                maxLines: 15,
                                minLines: 1,
                                style: textSmallStyle,
                                decoration: InputDecoration(
                                    hintText: "Оставьте комментарий",
                                    hintStyle: hintSmallStyle,
                                    border: InputBorder.none
                                ),
                              ).marginW(left: margin5, right: margin5),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Цена", style: titleMediumStyle)
                                        .marginW(left: margin5, right: margin5),
                                    TextField(
                                        enabled: !record.containsTatooService(),
                                        style: textSmallStyle,
                                        keyboardType: TextInputType.number,
                                        controller: _priceController,
                                        decoration: InputDecoration(
                                            hintText: "Введите цену",
                                            hintStyle: hintSmallStyle,
                                            border: InputBorder.none
                                        )
                                    )
                                        .marginW(left: margin5, right: margin5)
                                  ]
                              )
                            ]
                          ).paddingW(top: Global.blockY * 10)
                      ).marginW(top: Global.blockY * 7.5, left: Global.blockX * 5, right: Global.blockX * 5, bottom: Global.blockY * 10),
                      Container(
                        width: Global.blockX * 25,
                        height: Global.blockX * 25,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: Text("${_masterData.name[0]} ${_masterData.surname[0]}", style: titleBigBlueStyle).center(),
                      )
                          .positionW(Global.blockX * 37.5, 0, Global.blockX * 37.5, null),
                    ],
                  ).scroll(),
                ),
              )
            ]
        )
    ).safe();
  }

  List<Widget> buildServiceList(Map<Category, List<ServiceWrapper>> services) {
    List<Widget> widgets = <Widget> [];
    services.forEach((key, value) {
      if(value.isNotEmpty) {
        widgets.add(
            Container(
                alignment: Alignment.bottomLeft,
                color: Colors.grey.withAlpha(30),
                child: Text(key.name, textAlign: TextAlign.start).paddingW(
                  left: Global.blockX * 3, right: Global.blockX * 3,
                ))
        );
        // value.forEach((wrapper) {
        //   widgets.add(ServiceItem(wrapper));
        // });
      }
    });
    return widgets;
  }
}

class ServiceItem extends StatefulWidget {
  final Service service;
  ServiceItem(this.service);
  @override
  State<StatefulWidget> createState() => ServiceItemState();
}

class ServiceItemState extends State<ServiceItem> {
  ServiceItemState();
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    final NewRecordProvider record = Provider.of<NewRecordProvider>(context);
    return Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(widget.service.name, style: serviceTitleStyle),
                Checkbox(
                    value: record.services.contains(widget.service.id),
                    onChanged: (value) {
                      // if(widget.service.isTatoo)
                        // record.toggleService(widget.service.id);
                      // else if(!record.containsTatooService())
                      //   record.toggleService(widget.wrapper.serviceId);
                    }
                )
              ]
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${widget.service.wrapper.time} мин"),
                Row(
                    children: <Widget>[
                      Text("${widget.service.wrapper.price} ", style: serviceTitleStyle),
                      Text("грн"),
                    ]
                )
              ]
          )
        ]
    ).paddingW(left: Global.blockX * 5, top: 0, right: Global.blockX * 5, bottom: 0);
  }
}