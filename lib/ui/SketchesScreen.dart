import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/holders/CitiesHolder.dart';
import 'package:style_app/holders/SketchesHolder.dart';
import 'package:style_app/holders/UserHolder.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/model/Sketch.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/SketchesProvider.dart';
import 'package:style_app/service/ProfileService.dart';
import 'package:style_app/service/SketchesRepository.dart';
import 'package:style_app/ui/CreateOrderScreen.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/ProfileScreen.dart';
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
  String filter = "";
  Future<List<SketchPreview>> loadList(ProfileProvider profile, int page, int perPage, {String filter = ""}) async {
    SketchesHolder.isLoading = true;
    var list = await SketchesRepository.get().loadSketches(profile, page, perPage, filter: filter);
    return list;
  }

  void loadListAsync(ProfileProvider profile, SketchesProvider sketches, {String filter}) async {
    SketchesHolder.isLoading = true;
    SketchesRepository.get().loadSketches(profile, SketchesHolder.page, SketchesHolder.itemsPerPage, filter: filter).then((list) {
      setState(() {
        SketchesHolder.isLoading = false;
        SketchesHolder.page++;
        sketches.setPreviews(list);
        SketchesHolder.hasMore = list.length <= SketchesHolder.itemsPerPage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final SketchesProvider sketches = Provider.of<SketchesProvider>(context);

    SketchesHolder.memoizer.runOnce(() =>
        loadListAsync(profile, sketches, filter: ""));

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
                  .onClick(() async {
                    var data = await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) {
                        return SketchesFilterModal();
                      });
                    if(data != null) {
                      var newList = await loadList(
                          profile, 0, SketchesHolder.itemsPerPage,
                          filter: data["filter"] ?? "");
                      setState(() {
                        SketchesHolder.page = 1;
                        SketchesHolder.hasMore =
                            newList.length >= SketchesHolder.itemsPerPage;
                        sketches.setPreviews(newList);
                        filter = data["filter"] ?? "";
                        SketchesHolder.isLoading = false;
                      });
                    }
              })
            ],
          ).marginW(
              left: Global.blockX * 5,
              top: Global.blockY * 2,
              right: Global.blockX * 5,
              bottom: Global.blockY),
          Expanded(
            child: Container(
              child: RefreshIndicator(
               onRefresh: () async {
                 if(!SketchesHolder.isLoading) {
                   var r = await loadList(profile, 0, SketchesHolder.itemsPerPage, filter: filter);
                   setState(() {
                     sketches.setPreviews(r);
                     SketchesHolder.hasMore = r.length >= SketchesHolder.itemsPerPage;
                     SketchesHolder.page = 1;
                     SketchesHolder.isLoading = false;
                   });
                 }
               },
               child: SketchesHolder.isLoading && sketches.previews.isEmpty ?
               CircularProgressIndicator().center() :
               GridView.builder(
                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                   itemCount: sketches.previews.length,
                   itemBuilder: (_, i) {
                     if(SketchesHolder.hasMore && i >= sketches.previews.length - 1 && !SketchesHolder.isLoading) {
                       loadList(profile, SketchesHolder.page++, SketchesHolder.itemsPerPage, filter: filter).then((value) {
                         setState(() {
                           SketchesHolder.isLoading = false;
                           sketches.previews.addAll(value);
                           SketchesHolder.hasMore = value.length == SketchesHolder.itemsPerPage;
                         });
                       });
                       return CircularProgressIndicator().center();
                     }
                     return MasterSketchPreview(sketches.previews[i]);
                   }
               )
              )
            )
            )
        ]
    );
  }
}

class SketchPage extends StatefulWidget {
  final int sketchId;
  SketchPage(this.sketchId);

  @override
  State<StatefulWidget> createState() => SketchPageState();
}

class SketchPageState extends State<SketchPage> {
  final AsyncMemoizer memoizer = AsyncMemoizer();
  Sketch sketch;

@override
Widget build(BuildContext context) {
  final ProfileProvider provider = Provider.of<ProfileProvider>(context);
  final SketchesProvider sketches = Provider.of<SketchesProvider>(context);
  final CitiesProvider cities = Provider.of<CitiesProvider>(context);

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
                        NewOrderScreen(user, sketch.clone(), cities.byId(user.city)))
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
                  sketch == null ? Container() :
                  (provider.profileType == 0 ?
                  Container(
                      child: Icon(sketch.isFavorite ? Icons.favorite : Icons.favorite_border, size: 26, color: Colors.blueAccent)
                          .onClick(() async {
                        var isFavorite = await SketchesRepository.get().likeSketch(provider, sketch.isFavorite, sketch.id);
                        setState(() {
                          sketch.isFavorite = isFavorite;
                        });
                      })
                  ) :
                  Container(
                      child: Icon(Icons.delete_forever, size: 26, color: Colors.blueAccent)
                          .onClick(() async {
                        showPlatformDialog(
                          context: context,
                          builder: (_) => PlatformAlertDialog(
                            content: Text('Вы действительно хотите удалить эскиз?'),
                            actions: <Widget>[
                              PlatformDialogAction(
                                  child: Text("Отмена"),
                                  onPressed: () => Navigator.pop(context)
                              ),
                              PlatformDialogAction(
                                child: Text("Да"),
                                onPressed: () async {
                                  var r = await SketchesRepository.get().deleteSketch(provider, sketch);
                                  if(r) {
                                    sketches.removeSketch(sketch);
                                  }
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              )
                            ]
                          )
                        );
                      })
                  ))
                ],
              )
                  .marginW(left: margin5, right: margin5)
                  .sizeW(Global.width, Global.blockY * 10),
              Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      var refreshedSketch = await SketchesRepository.get().getSketchById(provider, widget.sketchId);
                      setState(() {
                        sketch = refreshedSketch;
                      });
                    },
                    child: FutureBuilder(
                      future: memoizer.runOnce(() async {
                        var s = await SketchesRepository.get().getSketchById(provider, widget.sketchId);
                        setState(() {
                          sketch = s;
                        });
                        return s;
                      }),
                      builder: (c, s) {
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
                                  child: Text("${sketch.data.tags}", style: textStyle).paddingAll(Global.blockY),
                                  decoration: BoxDecoration(
                                      color: defaultItemColor,
                                      borderRadius: defaultItemBorderRadius
                                  ),
                                ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                                Text("Стиль", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                                Container(
                                  child: Text("${sketch.data.style.name ?? ""}", style: textStyle).paddingAll(Global.blockY),
                                  decoration: BoxDecoration(
                                      color: defaultItemColor,
                                      borderRadius: defaultItemBorderRadius
                                  ),
                                ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                                Text("Описание", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                                Container(
                                  child: Text("${sketch.data.description}", style: textStyle).paddingAll(Global.blockY),
                                  decoration: BoxDecoration(
                                      color: defaultItemColor,
                                      borderRadius: defaultItemBorderRadius
                                  ),
                                ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                                Text("Рассположение татуировки", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                                Container(
                                  child: Text("${sketch.data?.position?.name ?? ""}", style: textStyle).paddingAll(Global.blockY),
                                  decoration: BoxDecoration(
                                      color: defaultItemColor,
                                      borderRadius: defaultItemBorderRadius
                                  ),
                                ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                                Text("Цвет татуировки", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                                Container(
                                  child: Text(sketch.data.isColored ? "Цветная" : "Черно-белая", style: textStyle).paddingAll(Global.blockY),
                                  decoration: BoxDecoration(
                                      color: defaultItemColor,
                                      borderRadius: defaultItemBorderRadius
                                  ),
                                ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                                Visibility(
                                  visible: sketch.data.width > 0 || sketch.data.height > 0,
                                  child: Column(
                                    children: [
                                      Text("Размеры татуировки", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                                      Container(
                                        child: ListView(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            children: [
                                              Visibility(
                                                  visible: sketch.data.width > 0,
                                                  child: Text("Ширина ${sketch.data.width} см")
                                              ),
                                              Visibility(
                                                  visible: sketch.data.height > 0,
                                                  child: Text("Высота ${sketch.data.height} см")
                                              )
                                            ]
                                        ).paddingAll(Global.blockY),
                                        decoration: BoxDecoration(
                                            color: defaultItemColor,
                                            borderRadius: defaultItemBorderRadius
                                        ),
                                      ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2)
                                    ]
                                  )
                                ),
                                Text("Цена", style: titleSmallStyle).marginW(left: margin5, right: margin5),
                                Container(
                                  child: Text("${sketch.data.price}", style: textStyle).paddingAll(Global.blockY),
                                  decoration: BoxDecoration(
                                      color: defaultItemColor,
                                      borderRadius: defaultItemBorderRadius
                                  ),
                                ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockY * 2),
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: Global.blockY * 35,
                                    enableInfiniteScroll: false
                                  ),
                                  items: sketch.photos.map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                                            decoration: BoxDecoration(
                                              // color: Colors.grey.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Image.network("$url/images/${i.path}")
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
                      }
                    )
                  )
              )
            ]
        )
        ).safe();
}
}

class SeeMasterSketchesPage extends StatelessWidget {
  final int userId;
  SeeMasterSketchesPage(this.userId);

  @override
  Widget build(BuildContext context) {
    final ProfileProvider provider = Provider.of<ProfileProvider>(context);
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
          Expanded(
            child: FutureBuilder(
              future: SketchesRepository.get().getMasterSketchesPreviews(provider, userId),
              builder: (c, s) {
                // print("[${s.connectionState}] [${s.hasData}] [${s.data}] [${s.hasError}] [${s.error}]");
                if(s.connectionState == ConnectionState.done && s.hasData && !s.hasError) {
                  if(s.data.length > 0) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemCount: s.data.length,
                      itemBuilder: (_, i) {
                        return MasterSketchPreview(s.data[i]);
                      },
                    );
                  } else return Container();
                } else if(s.connectionState == ConnectionState.waiting)
                  return CircularProgressIndicator().center();
                else return Container();
              },
            )
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

  void loadListAsync(ProfileProvider profile, SketchesProvider sketches, {String filter}) async {
    SketchesHolder.isLoading = true;
    await SketchesRepository.get().getMasterSketchesPreviews(profile, profile.id).then((list) {
      setState(() {
        SketchesHolder.isLoading = false;
        SketchesHolder.page++;
        sketches.setPreviews(list);
        SketchesHolder.hasMore = list.length <= SketchesHolder.itemsPerPage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider provider = Provider.of<ProfileProvider>(context);
    final SketchesProvider sketches = Provider.of<SketchesProvider>(context);
    SketchesHolder.memoizer.runOnce(() => loadListAsync(provider, sketches));

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
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  var previews = await SketchesRepository.get().getMasterSketchesPreviews(provider, provider.id);
                  sketches.setPreviews(previews);
                  return true;
                },
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemCount: sketches.previews.length,
                    itemBuilder: (c, i) => MasterSketchPreview(sketches.previews[i])
                )
              )
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
        height: Global.blockX * 32.5,
        width: Global.blockX * 32.5,
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: defaultItemBorderRadius
        ),
        child: Stack(
            children: [
              Positioned(
                left: 0, top: 0,
                right: 0, bottom: 0,
                child: (
                    preview.photos != null && preview.photos.isNotEmpty && preview.photos.length > 1 ?
                    Image.network("$url/images/${preview.photos}") :
                Container()).center()
              ),
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
          builder: (c) => SketchPage(preview.id)
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
  File image;
  bool canHideModal = true;

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
    final SketchesProvider sketches = Provider.of<SketchesProvider>(context);
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RaisedButton(
        onPressed: () async {
          _sketchData.tags = _tagsController.text;
          _sketchData.description = _descriptionController.text;
          _sketchData.price = _priceController.text == null || _priceController.text.isEmpty ?
          null :int.parse(_priceController.text);
          _sketchData.width = _widthController.text == null || _widthController.text.isEmpty ?
          null :int.parse(_widthController.text);
          _sketchData.height = _heightController.text == null || _heightController.text.isEmpty ?
          null :int.parse(_heightController.text);
          var sketch = Sketch(
            -1,
            provider.id,
            "",
            _sketchData,
            false,
            false,
            []
            );
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
                            Text("Создание эскиза...", style: titleSmallBlueStyle).center().marginW(bottom: Global.blockX * 5),
                            LinearProgressIndicator().center()
                          ]
                      )
                  )
                );
              }
          );
          var s = await SketchesRepository.get().createSketch(provider, sketch);
          var i = await SketchesRepository.get().uploadSketchImage(provider, s.id, image);
          s.photos.add(Photo(i, PhotoSource.NETWORK));
          sketches.addSketchPreview(SketchPreview(sketch.id, sketch.masterId, sketch.data.price, sketch?.photos?.first?.path ?? ""));
          canHideModal = true;
          Navigator.pop(context);
          Navigator.pop(context);
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
                      Text("Изображение", style: titleMediumStyle),
                      Text("Выбрать", style: titleSmallBlueStyle)
                          .onClick(() async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.getImage(source: ImageSource.gallery);
                        if(pickedFile != null)
                          setState(() {
                            image = File(pickedFile.path);
                            // media.add(pickedFile.path);
                            // _sketchData.photos.add(File(pickedFile.path));
                          });
                      })
                    ]
                ).marginW(left: margin5, right: margin5),
                Container(
                  height: Global.blockY * 30,
                    padding: EdgeInsets.only(top: Global.blockX * 3, bottom: Global.blockX * 3),
                    decoration: BoxDecoration(
                        borderRadius: defaultItemBorderRadius
                    ),
                    child: image == null
                    // media.isEmpty
                        ? Text("Изображение не выбрано", style: hintSmallStyle) :
                    Image.file(image)
                    // CarouselSlider(
                    //   options: CarouselOptions(
                    //     enableInfiniteScroll: false,
                    //   ),
                    //   items: media.map((i) {
                    //     return Builder(
                    //       builder: (BuildContext context) {
                    //         return Container(
                    //           width: MediaQuery.of(context).size.width,
                    //           margin: EdgeInsets.symmetric(horizontal: 5.0),
                    //           decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(10.0),
                    //           ),
                    //           child: Text('$i', style: TextStyle(fontSize: 16.0)).center()
                    //           // Image.file(i, fit: BoxFit.contain),
                    //         ).onClick(() {
                    //           Navigator.push(context, MaterialWithModalsPageRoute(
                    //               builder: (context) => ImagePage(media)
                    //           ));
                    //         });
                    //       },
                    //     );
                    //   }).toList(),
                    // )
                        .marginW(top: Global.blockX, bottom: Global.blockX)
                ).marginW(left: margin5, right: margin5, bottom: Global.blockY * 10)
              ]
            )
          )
        ]
      )
    ).safe();
  }
}