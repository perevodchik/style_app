import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/holders/CategoriesHolder.dart';
import 'package:style_app/holders/CitiesHolder.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/City.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/OrderProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/service/OrdersService.dart';
import 'package:style_app/ui/ProfileScreen.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

import 'ImagePage.dart';

class NewOrderScreen extends StatefulWidget {
  final UserData _master;
  final Sketch _sketch;
  final City _city;

  NewOrderScreen(this._master, this._sketch, this._city);

  @override
  State<StatefulWidget> createState() => NewOrderScreenState(_city);
}

class NewOrderScreenState extends State<NewOrderScreen> {
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  TextEditingController _priceController;
  TextEditingController _widthController;
  TextEditingController _heightController;
  final List<Photo> _images = [];
  final List<Service> servicesList = <Service> [];
  final SketchData sketchData = SketchData(isColored: true);
  City city;
  bool canHideModal = true;
  NewOrderScreenState(this.city);

  @override
  void initState() {
    if(widget._sketch != null) {
      _images.addAll(widget._sketch.photos);
    }
    if(widget._sketch != null) {
      _nameController = TextEditingController(text:  widget._sketch.data.tags);
      _descriptionController = TextEditingController();
      _priceController = TextEditingController(text: "${widget._sketch.data.price}");
      _widthController = TextEditingController(text: "${widget._sketch.data.width}");
      _heightController = TextEditingController(text: "${widget._sketch.data.height}");
      sketchData.style = widget._sketch.data.style;
      sketchData.position = widget._sketch.data.position;
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
    final OrderProvider orders = Provider.of<OrderProvider>(context);
    final ServicesProvider services = Provider.of<ServicesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      floatingActionButton: Visibility(
        visible: servicesList.isNotEmpty,
        child: RaisedButton(
          color: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: defaultItemBorderRadius
          ),
          onPressed: () async {
            try {
              sketchData.width = int.parse(_widthController.text) ?? null;
              sketchData.height = int.parse(_heightController.text) ?? null;
            } catch(e) {}
            var newOrder = Order(
                Random().nextInt(99999),
                profile.id,
                widget?._master?.id ?? null,
                _priceController.text == null || _priceController.text.isEmpty ? null :
                int.parse(_priceController.text),
                0,
                city?.id ?? profile.city,
                _nameController.text,
                _descriptionController.text,
                servicesList,
                _images,
                widget._sketch != null || widget._master != null,
                DateTime.now(),
                []
              );
            if(containsTatooService())
              newOrder.sketch = sketchData;
            canHideModal = false;
            showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (c) {
                  return WillPopScope(
                      onWillPop: () {
                        return Future<bool>.value(canHideModal);
                      },
                      child: Container(
                          padding: EdgeInsets.only(top: Global.blockX * 5, bottom: Global.blockX * 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: defaultModalBorderRadius
                          ),
                          child: ListView(
                              shrinkWrap: true,
                              children: [
                                Text(FlutterI18n.translate(context, "creating_order"), style: titleSmallBlueStyle).center().marginW(bottom: Global.blockX * 5),
                                LinearProgressIndicator().center()
                              ]
                          )
                      )
                  );
                }
            );
            var s = await OrdersService.get().createOrder(profile, newOrder);
            for(var p in _images) {
              if(p.type == PhotoSource.FILE) {
                await OrdersService.get().uploadOrderImage(profile, s.id, File(p.path));
              } else if(p.type == PhotoSource.NETWORK) {
                await OrdersService.get().addExistingImage(profile, s.id, p.path);
              }
            }
            orders.addOrderPreview(
              OrderPreview(
                newOrder.id,
                newOrder.price,
                newOrder.status,
                0,
                newOrder.name
              )
            );
            canHideModal = true;
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Text(FlutterI18n.translate(context, "create_order"), style: recordButtonStyle),
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
              Text(FlutterI18n.translate(context, "new_order"), style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          Expanded(
            child: ListView(
              children: <Widget>[
                Visibility(
                  visible: widget._master != null || widget._sketch != null,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(FlutterI18n.translate(context, "master"), style: titleSmallStyle),
                        Text(
                            (widget._master != null ?
                            "${widget._master.name} ${widget._master.surname}" :
                            (
                                widget._sketch != null ? "${widget._sketch.masterFullName}" : ""
                            )), style: titleSmallBlueStyle
                        ).onClick(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => UserProfile(widget._master.id)
                                  )
                              );
                            }
                        )
                      ]
                  ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2)
                ),
                Text(FlutterI18n.translate(context, "input_order_name"), style: titleSmallStyle).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: defaultItemBorderRadius
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: hintSmallStyle,
                        hintText: FlutterI18n.translate(context, "order_name")
                    ),
                  ),
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Text(FlutterI18n.translate(context, "input_description"), style: titleSmallStyle).marginW(left: margin5, right: margin5),
                Container(
                    padding: EdgeInsets.only(left: Global.blockX * 2),
                    decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: defaultItemBorderRadius
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      minLines: 1,
                      maxLines: 15,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: hintSmallStyle,
                          hintText: FlutterI18n.translate(context, "description")
                      ),
                    )
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(FlutterI18n.translate(context, "selected_services"), style: titleSmallStyle),
                    Text(FlutterI18n.translate(context, "add"), style: titleSmallBlueStyle)
                    .onClick(() async {
                      await showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                        return SelectServiceModal(widget._master == null ? services.map : widget._master.services, servicesList, widget._master != null).background(Colors.transparent);
                      });
                      setState(() {});
                    }),
                  ],
                ).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                  decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: defaultItemBorderRadius
                  ),
                  child: servicesList.isEmpty ? Text(FlutterI18n.translate(context, "no_selected_services"), style: hintSmallStyle) :
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                      itemCount: servicesList.length,
                      itemBuilder: (context, i) => Container(
                        child: Text("${servicesList[i].name}", style: textStyle).marginW(top: Global.blockX, bottom: Global.blockX),
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
                            Text(FlutterI18n.translate(context, "input_style"), style: titleSmallStyle),
                            Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() async {
                              await showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
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
                            color: accentColor,
                            borderRadius: defaultItemBorderRadius
                        ),
                        child: Text(sketchData?.style?.name ?? FlutterI18n.translate(context, "input_style"), style: textStyle),
                      ).marginW(bottom: Global.blockY * 2),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(FlutterI18n.translate(context, "input_position"), style: titleSmallStyle),
                            Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() async {
                              await showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
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
                            color: accentColor,
                            borderRadius: defaultItemBorderRadius
                        ),
                        child: Text(sketchData?.position?.name ?? FlutterI18n.translate(context, "input_position"), style: textStyle)
                      ).marginW(bottom: Global.blockY * 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(FlutterI18n.translate(context, "input_color"), style: titleSmallStyle),
                          Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() async {
                            await showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
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
                              color: accentColor,
                              borderRadius: defaultItemBorderRadius
                          ),
                          child: Text(sketchData.isColored ? FlutterI18n.translate(context, "colored") : FlutterI18n.translate(context, "non_colored"), style: textStyle)
                      ).marginW(bottom: Global.blockY * 2),
                      Text(FlutterI18n.translate(context, "tatoo_size"), style: titleSmallStyle),
                      Container(
                          padding: EdgeInsets.only(left: Global.blockX * 2, right: Global.blockX * 2),
                          decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: defaultItemBorderRadius
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: TextField(
                                        controller: _widthController,
                                        style: textStyle,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintStyle: hintSmallStyle,
                                            hintText: FlutterI18n.translate(context, "width"),
                                        )
                                    )
                                ),
                                Expanded(
                                    child: TextField(
                                        controller: _heightController,
                                        style: textStyle,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintStyle: hintSmallStyle,
                                            hintText: FlutterI18n.translate(context, "height")
                                        )
                                    )
                                )
                              ]
                          )
                      )
                    ]
                  ).marginW(left: margin5, right: margin5)
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(FlutterI18n.translate(context, "select_city"), style: titleSmallStyle),
                      Text(FlutterI18n.translate(context, "select"), style: titleSmallBlueStyle).onClick(() async {
                        var c = await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (c) => SelectOrderCityModal(city)
                        );
                        if(c != null)
                          setState(() {
                            city = c;
                          });
                      })
                    ]
                ).marginW(left: margin5, right: margin5),
                Container(
                  width: Global.width,
                  padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                  decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: defaultItemBorderRadius
                  ),
                  child: Text(city?.name ?? FlutterI18n.translate(context, "select_city"), style: city == null ? hintSmallStyle : textStyle),
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Text(FlutterI18n.translate(context, "input_price"), style: titleSmallStyle).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2),
                  decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: defaultItemBorderRadius
                  ),
                  child: TextField(
                    controller: _priceController,
                    style: textStyle,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: hintSmallStyle,
                        hintText: FlutterI18n.translate(context, "price")
                    ),
                  ),
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(FlutterI18n.translate(context, "photos"), style: titleSmallStyle),
                    Text(FlutterI18n.translate(context, "add"), style: titleSmallBlueStyle)
                        .onClick(() async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.getImage(source: ImageSource.gallery);
                      if(pickedFile != null)
                        setState(() {
                          _images.add(Photo(pickedFile.path, PhotoSource.FILE));
                        });
                    })
                  ]
                ).marginW(left: margin5, right: margin5),
                Container(
                  padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockX * 3, bottom: Global.blockX * 3),
                  decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: defaultItemBorderRadius
                  ),
                  child: _images.isEmpty ? Text(FlutterI18n.translate(context, "no_photos"), style: hintSmallStyle) :
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
                              child: Stack(
                                children: [
                                  i.getWidget(),
                                  Positioned(
                                    right: 0, top: 0,
                                    child: Icon(Icons.clear, color: primaryColor, size: 36)
                                        .onClick(() {
                                          _images.remove(i);
                                          setState(() {});
                                    })
                                  )
                                ]
                              ),
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
    widgets.add(Text(FlutterI18n.translate(context, "select_service"), style: titleStyle).center().marginW(bottom: Global.blockY));
    services.forEach((value) {
      if((!widget.isShowOnlyMasterServices && value.services.isNotEmpty) || (widget.isShowOnlyMasterServices && value.containsMasterService())) {
        print(value.services);
        widgets.add(
            Container(
                alignment: Alignment.bottomLeft,
                color: Colors.grey.withAlpha(30),
                child: Text(value.name, style: titleSmallStyle)
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
                Text(service.name, style: widget.services.contains(service) ? titleMediumBlueStyle : hintMediumStyle)
                    .onClick(() {
                  toggleService(service);
                }),
              ]
          )
        ]
    ).paddingW(left: margin5, top: Global.blockX, right: margin5, bottom: Global.blockX);
  }
}