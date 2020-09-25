import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/NewRecordProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/SketchesProvider.dart';
import 'package:style_app/service/CategoryService.dart';
import 'package:style_app/service/ProfileService.dart';
import 'package:style_app/service/SketchesRepository.dart';
import 'package:style_app/ui/CreateOrderScreen.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/MasterProfileScreen.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class Sketches extends StatefulWidget {
  const Sketches();
  @override
  State<StatefulWidget> createState() => SketchesState();
}

class SketchesState extends State<Sketches> {
  List<SketchPreview> _sketches = [];
  bool _isLoading = false;
  bool _isFirstLoad = false;
  bool _hasMore = true;
  int _page = 0;
  int _itemsPerPage = 30;

  Future<List<SketchPreview>> loadList(ProfileProvider profile, int page, int perPage) async {
    print("load page $page, $perPage items");
    _isLoading = true;
    var list = await SketchesRepository.get().loadSketches(profile, page, perPage);
    return list;
  }

  void loadListAsync(ProfileProvider profile) async {
    _isLoading = true;
    SketchesRepository.get().loadSketches(profile, _page, _itemsPerPage).then((list) {
      setState(() {
        _isLoading = false;
        _isFirstLoad = true;
        _page++;
        _sketches.clear();
        _sketches.addAll(list);
        if(list.length < _itemsPerPage)
          _hasMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);

    if(!_isLoading && !_isFirstLoad)
      loadListAsync(profile);

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("112", style: TextStyle(color: Colors.transparent)),
              Container(
                child: Text("Эскизы тату", style: titleStyle),
              ),
              Icon(Icons.filter_list, color: Colors.blueAccent)
                  .onClick(() => showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (ctx) {
                    return SketchesFilterModal();
                  }))
            ],
          ).marginW(
              left: Global.blockX * 5,
              top: Global.blockY * 2,
              right: Global.blockX * 5,
              bottom: Global.blockY),
          Expanded(
            child: PagewiseGridView.count(
              pageSize: 100,
              crossAxisCount: 3,
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              childAspectRatio: 0.955,
              padding: EdgeInsets.all(15.0),
              itemBuilder: (context, SketchPreview s, _) {
                return MasterSketchPreview(s);
              },
              pageFuture: (page) =>
                  loadList(profile, page, 100)
            )
          )
        ]
    );
  }
}

class SketchPage extends StatelessWidget {
final SketchPreview preview;
SketchPage(this.preview);

@override
Widget build(BuildContext context) {
  final ProfileProvider provider = Provider.of<ProfileProvider>(context);
  Sketch sketch;

  return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: provider.profileType == 0,
        child: RaisedButton(
          onPressed: () async {
            var user = await UserService.get().getFullDataById(provider, sketch.masterId);
            Navigator.push(
                context,
                MaterialWithModalsPageRoute(
                    builder: (context) =>
                        NewOrderScreen(user, sketch.data.clone()))
            );
          },
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: defaultItemBorderRadius
          ),
          color: defaultColorAccent,
          child: Text("Записаться", style: smallWhiteStyle),
        )
      ),
      body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                    Navigator.pop(context);
                  }),
                  Text("Просмотр эскиза", style: titleStyle),
                  Container(
                      // child: sketch?.isFavorite ? Icon(Icons.favorite, size: 26, color: Colors.blueAccent)
                      //     .onClick(() {
                      //   sketch?.isFavorite = !sketch?.isFavorite;
                      //   provider.update();
                      // }) :
                      // Icon(Icons.favorite_border, size: 26, color: Colors.blueAccent)
                      //     .onClick(() {
                      //   sketch?.isFavorite = !sketch?.isFavorite;
                      //   provider.update();
                      // })
                  )
                ],
              )
                  .marginW(left: margin5, right: margin5)
                  .sizeW(Global.width, Global.blockY * 10),
              Expanded(
                  child: FutureBuilder(
                    future: SketchesRepository.get().getSketchById(provider, preview.id),
                    builder: (c, s) {
                      sketch = s.data as Sketch;
                      print("[${s.connectionState}] [${s.data}] [${s.hasData}] [${s.error}] [${s.hasError}]}");
                      if(s.connectionState == ConnectionState.done && s.hasData && !s.hasError)
                        return ListView(
                            shrinkWrap: true,
                            children: [
                              Visibility(
                                  visible: provider.id != sketch.masterId,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Мастер", style: titleSmallStyle),
                                      Text(sketch.masterFullName, style: titleSmallBlueStyle)
                                          .onClick(() => Navigator.push(
                                          context,
                                          MaterialWithModalsPageRoute(
                                              builder: (c) => UserProfile(sketch.masterId)
                                          )
                                      ))
                                    ]
                                  ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2)
                              ),
                              Text("Название", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                              Container(
                                child: Text("${sketch.data.tags}").paddingAll(Global.blockY),
                                decoration: BoxDecoration(
                                    color: defaultItemColor,
                                    borderRadius: defaultItemBorderRadius
                                ),
                              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                              Text("Стиль", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                              Container(
                                child: Text("${sketch.data.style.name ?? ""}").paddingAll(Global.blockY),
                                decoration: BoxDecoration(
                                    color: defaultItemColor,
                                    borderRadius: defaultItemBorderRadius
                                ),
                              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                              Text("Описание", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                              Container(
                                child: Text("${sketch.data.description}").paddingAll(Global.blockY),
                                decoration: BoxDecoration(
                                    color: defaultItemColor,
                                    borderRadius: defaultItemBorderRadius
                                ),
                              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                              Text("Рассположение татуировки", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                              Container(
                                child: Text("${sketch.data?.position?.name ?? ""}").paddingAll(Global.blockY),
                                decoration: BoxDecoration(
                                    color: defaultItemColor,
                                    borderRadius: defaultItemBorderRadius
                                ),
                              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                              Text("Цвет татуировки", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                              Container(
                                child: Text(sketch.data.isColored ? "Цветная" : "Черно-белая").paddingAll(Global.blockY),
                                decoration: BoxDecoration(
                                    color: defaultItemColor,
                                    borderRadius: defaultItemBorderRadius
                                ),
                              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                              Text("Размеры татуировки", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                              Container(
                                child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Text("Ширина ${sketch.data.width} см"),
                                      Text("Высота ${sketch.data.height} см")
                                    ]
                                ).paddingAll(Global.blockY),
                                decoration: BoxDecoration(
                                    color: defaultItemColor,
                                    borderRadius: defaultItemBorderRadius
                                ),
                              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                              Text("Цена", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                              Container(
                                child: Text("${sketch.data.price}").paddingAll(Global.blockY),
                                decoration: BoxDecoration(
                                    color: defaultItemColor,
                                    borderRadius: defaultItemBorderRadius
                                ),
                              ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: Global.blockY * 15,
                                ),
                                items: sketch.photos.map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text('$i', style: TextStyle(fontSize: 16.0))
                                              .center())
                                          .onClick(() {
                                        Navigator.push(
                                            context,
                                            MaterialWithModalsPageRoute(
                                                builder: (context) =>
                                                    ImagePage(sketch.photos)));
                                      });
                                    },
                                  );
                                }).toList(),
                              ).marginW(left: margin5, top: Global.blockX, right: margin5, bottom: Global.blockX)
                            ]
                        );
                      else return CircularProgressIndicator().center();
                    },
                  )
              )
            ]
        )
        ).safe();
}
}

class SeeMasterSketchesPage extends StatelessWidget {
  final UserData _masterData;
  SeeMasterSketchesPage(this._masterData);

  @override
  Widget build(BuildContext context) {
    final SketchesProvider sketches = Provider.of<SketchesProvider>(context);
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                Navigator.pop(context);
              }).marginW(left: Global.blockX * 5),
              Text("Просмотр эскизов", style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          ListView(
            shrinkWrap: true,
            children: sketches.sketches
                .where((element) => element.masterId == _masterData.id)
              .map((s) => SketchPreviewWidget(s, _masterData)).toList()
          )
        ]
      )
    ).safe();
  }
}

class SketchPreviewWidget extends StatelessWidget {
  final Sketch s;
  final UserData data;

  SketchPreviewWidget(this.s, this.data);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(Global.blockY),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 1))
            ],
            borderRadius: defaultItemBorderRadius,
            color: Colors.white
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  children: [
                    Text(data.getNames(), style: titleMediumBlueStyle)
                        .onClick(() => Navigator.push(
                        context,
                        MaterialWithModalsPageRoute(
                            builder: (c) => UserProfile(data.id)
                        )
                    )),
                    Text("${s.data.price} грн", style: titleSmallStyle)
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween
              ).paddingW(top: Global.blockX, bottom: Global.blockX),
              CarouselSlider(
                options: CarouselOptions(
                  height: Global.blockY * 15,
                ),
                items: data.portfolioImages.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text('$i', style: TextStyle(fontSize: 16.0))
                              .center())
                          .onClick(() {
                        Navigator.push(
                            context,
                            MaterialWithModalsPageRoute(
                                builder: (context) =>
                                    ImagePage(s.photos)));
                      });
                    },
                  );
                }).toList(),
              ).marginW(top: Global.blockX, bottom: Global.blockX)
            ]
        )
    )
        .marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2)
    //     .onClick(() => Navigator.push(
    //     context,
    //     MaterialWithModalsPageRoute(
    //         builder: (c) => SketchPage(s, data)
    //     )
    // ))
    ;
  }
}

class MasterSketchesPage extends StatefulWidget {
  const MasterSketchesPage();

  @override
  State<StatefulWidget> createState() => MasterSketchesState();
}

class MasterSketchesState extends State<MasterSketchesPage> {
  @override
  Widget build(BuildContext context) {
    final ProfileProvider provider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RaisedButton(
          onPressed: () => Navigator.push(context, MaterialWithModalsPageRoute(
              builder: (context) => CreateSketchPage()
          )),
          color: Colors.blueAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: defaultItemBorderRadius
          ),
          child: Text("Добавить эскиз", style: smallWhiteStyle)
      )
          .marginW(left: Global.blockY * 2, top: Global.blockX, right: Global.blockY * 2, bottom: Global.blockY),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text("Ваши эскизы", style: titleStyle),
            ).marginW(
                left: Global.blockX * 5,
                top: Global.blockY * 2,
                right: Global.blockX * 5,
                bottom: Global.blockY),
            FutureBuilder(
              future: SketchesRepository.get().getMasterSketchesPreviews(provider),
              builder: (c, s) {
                print("[${s.connectionState}] [${s.hasData}] [${s.hasError}] [${s.data}] [${s.error}]");
                if(s.connectionState == ConnectionState.done && s.hasData && !s.hasError)
                  return Expanded(
                      child: ListView(
                        shrinkWrap: true,
                          children: [
                            Wrap(
                                children: s.data
                                    .map<Widget>((p) {
                                  return MasterSketchPreview(p);
                                }).toList()
                            ).center()
                          ]
                      )
                  );
                else return CircularProgressIndicator().center();
              }
            )
          ]
      )
    );
  }
}

class MasterSketchPreview extends StatelessWidget {
  final SketchPreview preview;
  MasterSketchPreview(this.preview);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(1),
        height: Global.blockX * 30,
        width: Global.blockX * 30,
        decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: defaultItemBorderRadius
        ),
        child: Stack(
            children: [
              Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                      padding: EdgeInsets.all(Global.blockX),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
                          color: Colors.blue
                      ),
                      child: Text("${preview.price}", style: smallWhiteStyle)
                  )
              )
            ]
        )
    ).onClick(() {
      Navigator.push(
        context,
        MaterialWithModalsPageRoute(
          builder: (c) => SketchPage(preview)
        )
      );
    });
  }
}

class CreateSketchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateSketchState();
}

class CreateSketchState extends State<CreateSketchPage> {
  TextEditingController _descriptionController;
  TextEditingController _positionController;
  TextEditingController _priceController;
  TextEditingController _tagsController;
  TextEditingController _widthController;
  TextEditingController _heightController;
  SketchData _sketchData = SketchData();
  List<String> media = [];

  @override
  void initState() {
    _descriptionController = TextEditingController();
    _positionController = TextEditingController();
    _priceController = TextEditingController();
    _tagsController = TextEditingController();
    _widthController = TextEditingController();
    _heightController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _positionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _sketchData.isColored = true;
    final ProfileProvider provider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RaisedButton(
        onPressed: () {
          _sketchData.tags = _tagsController.text;
          _sketchData.description = _descriptionController.text;
          _sketchData.price = _priceController.text == null || _priceController.text.isEmpty ?
          0 :int.parse(_priceController.text);
          _sketchData.width = _widthController.text == null || _widthController.text.isEmpty ?
          0 :int.parse(_widthController.text);
          _sketchData.height = _heightController.text == null || _heightController.text.isEmpty ?
          0 :int.parse(_heightController.text);
          var sketch = Sketch(
            Random().nextInt(99999),
            provider.id,
            "",
            _sketchData,
            false,
            false,
            media
            );
          SketchesRepository.get().createSketch(provider, sketch);
          // print("create sketch [\n${sketch.toString()}"
          //     "\n ]");
          // sketches.addSketch(sketch);
          // Navigator.pop(context);
        },
        child: Text("Создать", style: smallWhiteStyle)
            .marginW(left: margin5, right: margin5),
        color: defaultColorAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: defaultItemBorderRadius
        )
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                Navigator.pop(context);
              }).marginW(left: Global.blockX * 5),
              Text("Добавление эскиза", style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          Expanded(
            child: ListView(
              children: [
                Text("Теги", style: titleMediumStyle)
                    .marginW(left: margin5, right: margin5),
                TextField(
                    controller: _tagsController,
                    minLines: 1,
                    maxLines: 10,
                    decoration: InputDecoration(
                        hintStyle: hintSmallStyle,
                        hintText: "Введите теги",
                        border: InputBorder.none
                    )
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Стиль", style: titleMediumStyle),
                    Text("Выбрать", style: titleSmallBlueStyle)
                    .onClick(() async {
                      await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (c) => SelectStyleModal(_sketchData));
                      setState(() {});
                    })
                  ]
                ).marginW(left: margin5, right: margin5),
                Container(
                    child: _sketchData.style == null ?
                    Text("Выберите стиль", style: hintSmallStyle) :
                    Text("${_sketchData.style.name}", style: textStyle)
                ).marginW(left: margin5, top: Global.blockY * 2, right: margin5, bottom: Global.blockY * 3),
                Text("Описание", style: titleMediumStyle)
                    .marginW(left: margin5, right: margin5),
                TextField(
                    controller: _descriptionController,
                    minLines: 1,
                    maxLines: 10,
                    decoration: InputDecoration(
                        hintStyle: hintSmallStyle,
                        hintText: "Введите описание",
                        border: InputBorder.none
                    )
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Рассположение на теле", style: titleMediumStyle),
                    Text("Выбрать", style: titleSmallBlueStyle)
                    .onClick(() async {
                      await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                          context: context,
                          builder: (c) => SelectPositionModal(_sketchData));
                      setState(() {});
                    }),
                  ]
                ).marginW(left: margin5, right: margin5),
                Container(
                  child: _sketchData.position == null ?
                      Text("Выберите рассположение", style: hintSmallStyle) :
                      Text("${_sketchData.position.name}", style: textStyle)
                ).marginW(left: margin5, top: Global.blockY * 2, right: margin5, bottom: Global.blockY * 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Цвет татуировки", style: titleMediumStyle),
                    Text("Выбрать", style: titleSmallBlueStyle).onClick(() async {
                      await showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (c) => SelectColorModal(_sketchData));
                      setState(() {});
                    })
                  ]
                ).marginW(left: margin5, right: margin5),
                Text(_sketchData.isColored ? "Цветная" : "Черно-белая", style: textSmallStyle).marginW(left: margin5, top: Global.blockY * 2, right: margin5, bottom: Global.blockY * 3),
                Text("Размеры", style: titleMediumStyle)
                    .marginW(left: margin5, right: margin5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
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
                Text("Стоимость", style: titleMediumStyle)
                    .marginW(left: margin5, right: margin5),
                TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintStyle: hintSmallStyle,
                        hintText: "Введите стоимость работы",
                        border: InputBorder.none
                    )
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Изображения", style: titleMediumStyle),
                      Text("Выбрать", style: titleSmallBlueStyle)
                          .onClick(() async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.getImage(source: ImageSource.gallery);
                        if(pickedFile != null)
                          setState(() {
                            media.add(pickedFile.path);
                            // _sketchData.photos.add(File(pickedFile.path));
                          });
                      })
                    ]
                ).marginW(left: margin5, right: margin5),
                Container(
                    padding: EdgeInsets.only(top: Global.blockX * 3, bottom: Global.blockX * 3),
                    decoration: BoxDecoration(
                        borderRadius: defaultItemBorderRadius
                    ),
                    child: media.isEmpty ? Text("Нету добавленных изображений", style: hintSmallStyle) :
                    CarouselSlider(
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                      ),
                      items: media.map((i) {
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
                                  builder: (context) => ImagePage(media)
                              ));
                            });
                          },
                        );
                      }).toList(),
                    ).marginW(top: Global.blockX, bottom: Global.blockX)
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 10)
              ]
            )
          )
        ]
      )
    ).safe();
  }
}