import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/holders/CategoriesHolder.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/NewRecordProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/service/OrdersService.dart';
import 'package:style_app/ui/MasterProfileScreen.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

import 'ImagePage.dart';

class NewOrderScreen extends StatefulWidget {
  final UserData _master;
  final SketchData _sketch;

  NewOrderScreen(this._master, this._sketch);

  @override
  State<StatefulWidget> createState() => NewOrderScreenState();
}

class NewOrderScreenState extends State<NewOrderScreen> {
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  TextEditingController _priceController;
  TextEditingController _widthController;
  TextEditingController _heightController;
  final List<File> _images = [];
  final List<Service> servicesList = <Service> [];
  final SketchData sketchData = SketchData(isColored: true);


  @override
  void initState() {
    if(widget._sketch != null) {
      _nameController = TextEditingController(text:  widget._sketch.tags);
      _descriptionController = TextEditingController();
      _priceController = TextEditingController(text: "${widget._sketch.price}");
      _widthController = TextEditingController(text: "${widget._sketch.width}");
      _heightController = TextEditingController(text: "${widget._sketch.height}");
      sketchData.style = widget._sketch.style;
      sketchData.position = widget._sketch.position;
      var tatooService = CategoriesHolder.getTatooService();
      if(tatooService != null)
        servicesList.add(tatooService);
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      _widthController = TextEditingController();
      _heightController = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool containsTatooService() {
    return servicesList.firstWhere((element) => element.isTatoo ?? false, orElse: () => null) != null;
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final ServicesProvider services = Provider.of<ServicesProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      floatingActionButton: Visibility(
        visible: servicesList.isNotEmpty,
        child: RaisedButton(
          color: Colors.blueAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: defaultItemBorderRadius
          ),
          onPressed: () async {
            try {
              sketchData.width = int.parse(_widthController.text ?? "0");
              sketchData.height = int.parse(_heightController.text ?? "0");
            } catch(e) {}
            var newRecord = Order(
                Random().nextInt(99999),
                profile.id,
                widget?._master?.id ?? null,
                _priceController.text == null || _priceController.text.isEmpty ? null :
                int.parse(_priceController.text),
                0,
                null,
                _nameController.text,
                _descriptionController.text,
                servicesList,
                _images,
                false,
                DateTime.now(),
                []
              );
            if(containsTatooService())
              newRecord.sketch = sketchData;
            OrdersService.get().createOrder(profile.token, newRecord);
          },
          child: Text("Создать обьявление", style: recordButtonStyle),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                Navigator.pop(context);
              }).marginW(left: Global.blockX * 5),
              Text("Новая запись", style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          Expanded(
            child: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Мастер", style: titleSmallStyle),
                    // Row(
                    //   children: [
                    //     Container(
                    //       padding: EdgeInsets.all(Global.blockY),
                    //       decoration: BoxDecoration(
                    //         color: defaultItemColor,
                    //         borderRadius: defaultCircleBorderRadius
                    //       ),
                    //       child: Text(widget._master != null ?
                    //       (widget._master.avatar != null ? widget._master.avatar :
                    //       "${widget._master.name[0].toUpperCase()}${widget._master.surname[0].toUpperCase()}") : "").center(),
                    //     ),
                        Text(widget._master != null ? "${widget._master.name} ${widget._master.surname}" : "", style: titleSmallBlueStyle)
                            .onClick(() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => UserProfile(widget._master.id)
                              )
                          );
                        })
                      // ]
                    // )
                  ]
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Text("Введите название", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2),
                  decoration: BoxDecoration(
                    color: defaultItemColor,
                    borderRadius: defaultItemBorderRadius
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: hintSmallStyle,
                        hintText: "Название"
                    ),
                  ),
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Text("Введите комментарий", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                Container(
                    padding: EdgeInsets.only(left: Global.blockX * 2),
                    decoration: BoxDecoration(
                        color: defaultItemColor,
                        borderRadius: defaultItemBorderRadius
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      minLines: 1,
                      maxLines: 15,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: hintSmallStyle,
                          hintText: "Описание"
                      ),
                    )
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Выбранные услуги", style: titleSmallStyle),
                    Text("Добавить", style: titleSmallBlueStyle)
                    .onClick(() async {
                      await showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            print(widget._master == null ? "services.map" : "widget._master.services");
                        return SelectServiceModal(widget._master == null ? services.map : widget._master.services, servicesList, widget._master != null).background(Colors.transparent);
                      });
                      setState(() {});
                    }),
                  ],
                ).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                  decoration: BoxDecoration(
                      color: defaultItemColor,
                      borderRadius: defaultItemBorderRadius
                  ),
                  child: servicesList.isEmpty ? Text("Нету выбранных услуг", style: hintSmallStyle) :
                  ListView.builder(
                    physics: null,
                    shrinkWrap: true,
                      itemCount: servicesList.length,
                      itemBuilder: (context, i) => Container(
                        child: Text("${servicesList[i].name}", style: previewRateStyle).marginW(top: Global.blockX, bottom: Global.blockX),
                      )
                  ),
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Visibility(
                  visible: containsTatooService(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Введите стиль татуировки", style: titleSmallStyle),
                            Text("Выбрать", style: titleSmallBlueStyle).onClick(() async {
                              await showModalBottomSheet(
                                  context: context,
                                  builder: (c) => SelectStyleModal(sketchData)
                              );
                              setState(() {});
                            })
                          ]
                      ),
                      Container(
                        width: Global.width,
                        padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                        decoration: BoxDecoration(
                            color: defaultItemColor,
                            borderRadius: defaultItemBorderRadius
                        ),
                        child: Text(sketchData?.style?.name ?? "Выберите стиль"),
                      ).marginW(bottom: Global.blockY * 2),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Введите место татуировки", style: titleSmallStyle),
                            Text("Выбрать", style: titleSmallBlueStyle).onClick(() async {
                              await showModalBottomSheet(
                                  context: context,
                                  builder: (c) => SelectPositionModal(sketchData)
                              );
                              setState(() {});
                            })
                          ]
                      ),
                      Container(
                        width: Global.width,
                        padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                        decoration: BoxDecoration(
                            color: defaultItemColor,
                            borderRadius: defaultItemBorderRadius
                        ),
                        child: Text(sketchData?.position?.name ?? "Выберите позицию")
                      ).marginW(bottom: Global.blockY * 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Цвет татуировки", style: titleSmallStyle),
                          Text("Выбрать", style: titleSmallBlueStyle).onClick(() async {
                            await showModalBottomSheet(
                                context: context,
                                builder: (c) => SelectColorModal(sketchData)
                            );
                            setState(() {});
                          })
                        ]
                      ),
                      Container(
                          width: Global.width,
                          padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                          decoration: BoxDecoration(
                              color: defaultItemColor,
                              borderRadius: defaultItemBorderRadius
                          ),
                          child: Text(sketchData.isColored ? "Цветная" : "Черно-белая")
                      ).marginW(bottom: Global.blockY * 2),
                      Text("Размеры татуировки (см)", style: titleSmallStyle),
                      Container(
                          padding: EdgeInsets.only(left: Global.blockX * 2, right: Global.blockX * 2),
                          decoration: BoxDecoration(
                              color: defaultItemColor,
                              borderRadius: defaultItemBorderRadius
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: TextField(
                                        controller: _widthController,
                                        style: textSmallStyle,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintStyle: hintSmallStyle,
                                            hintText: "Ширина"
                                        )
                                    )
                                ),
                                Expanded(
                                    child: TextField(
                                        controller: _heightController,
                                        style: textSmallStyle,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintStyle: hintSmallStyle,
                                            hintText: "Высота"
                                        )
                                    )
                                )
                              ]
                          )
                      )
                    ]
                  ).marginW(left: margin5, right: margin5)
                ),
                Text("Введите стоимость", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2),
                  decoration: BoxDecoration(
                      color: defaultItemColor,
                      borderRadius: defaultItemBorderRadius
                  ),
                  child: TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: hintSmallStyle,
                        hintText: "Стоимость"
                    ),
                  ),
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Изображения", style: titleSmallStyle),
                    Text("Добавить", style: titleSmallBlueStyle)
                        .onClick(() async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.getImage(source: ImageSource.gallery);
                      if(pickedFile != null)
                        setState(() {
                          _images.add(File(pickedFile.path));
                        });
                    })
                  ]
                ).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                  decoration: BoxDecoration(
                      color: defaultItemColor,
                      borderRadius: defaultItemBorderRadius
                  ),
                  child: _images.isEmpty ? Text("Нету добавленных изображений", style: hintSmallStyle) :
                  CarouselSlider(
                    options: CarouselOptions(
                      enableInfiniteScroll: false,
                    ),
                    items: _images.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Image.file(i, fit: BoxFit.contain),
                          ).onClick(() {
                            Navigator.push(context, MaterialWithModalsPageRoute(
                                builder: (context) => ImageFilePage(_images)
                            ));
                          });
                        },
                      );
                    }).toList(),
                  ).marginW(top: Global.blockX, bottom: Global.blockX)
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 10),
              ]
            )
          )
        ]
      )
    ).safe();
  }
}

class SelectServiceModal extends StatefulWidget {
  final List<Category> categories;
  final List<Service> services;
  final bool isShowOnlyMasterServices;
  SelectServiceModal(this.categories, this.services, this.isShowOnlyMasterServices);
  @override
  State<StatefulWidget> createState() => SelectServiceModalState();
}

class SelectServiceModalState extends State<SelectServiceModal> {
  SelectServiceModalState();
  
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(15)),
            color: Colors.white),
        child: ListView(
          shrinkWrap: true,
          children: buildServiceList(widget.categories)
        ).marginAll(Global.blockX).paddingW(top: Global.blockY)
    ).background(Colors.transparent);
  }

  List<Widget> buildServiceList(List<Category> services) {
    List<Widget> widgets = <Widget> [];
    widgets.add(Text("Выберите услуги", style: titleStyle).center().marginW(bottom: Global.blockY));
    services.forEach((value) {
      if(value.services.isNotEmpty) {
        widgets.add(
            Container(
                alignment: Alignment.bottomLeft,
                color: Colors.grey.withAlpha(30),
                child: Text(value.name, style: titleMediumStyle)
            )
        );
        value.services.forEach((element) {
          if(widget.isShowOnlyMasterServices) {
            if (element.wrapper != null)
              widgets.add(buildServiceItem(element));
          } else widgets.add(buildServiceItem(element));
        });
      }
    });
    return widgets;
  }

  void toggleService(Service service) {
    setState(() {
      if(widget.services.contains(service)) {
        widget.services.remove(service);
      }
      else {
        if(service.isTatoo ?? false) {
          widget.services.clear();
          widget.services.add(service);
        }
        else if(!containsTatooService())
          widget.services.add(service);
      }
    });
  }

  bool containsTatooService() {
    widget.services.forEach((element) { if(element.wrapper != null)
    return true;
    });
    return false;
  }

  Widget buildServiceItem(Service service) {
    return Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(service.name, style: widget.services.contains(service) ? titleSmallBlueStyle : hintSmallStyle)
                    .onClick(() {
                  toggleService(service);
                }),
                Switch(
                  value: widget.services.contains(service),
                  onChanged: (value) {
                    toggleService(service);
                  },
                )
              ]
          )
        ]
    ).paddingW(left: margin5, right: margin5);
  }
}