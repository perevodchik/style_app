import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/ProfileService.dart';
import 'package:style_app/ui/CommentBlock.dart';
import 'package:style_app/ui/CorrespondenceScreen.dart';
import 'package:style_app/ui/CreateOrderScreen.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/SketchesScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  final int _masterId;

  const UserProfile(this._masterId);

  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  UserData _userData;
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future<bool> refreshUser(ProfileProvider user) async {
    var userData = await UserService.get().getFullDataById(user, widget._masterId);
    if(userData != null) {
      setState(() {
        _userData = userData;
      });
    }
    return userData != null;
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider user = Provider.of<ProfileProvider>(context);
    final ConversionProvider conversions = Provider.of<ConversionProvider>(context);
    final CitiesProvider cities = Provider.of<CitiesProvider>(context);

    _memoizer.runOnce(() async {
      var userData = await UserService.get().getFullDataById(user, widget._masterId);
      setState(() {
        _userData = userData;
      });
    });

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        floatingActionButton: Visibility(
          visible: _userData?.profileType == 1 ?? false,
          child: RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialWithModalsPageRoute(
                      builder: (context) => NewOrderScreen(_userData, null, cities.byId(_userData.city))));
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: defaultItemBorderRadius
            ),
            color: primaryColor,
            child: Text(FlutterI18n.translate(context, "record"), style: recordButtonStyle)
                .marginW(left: margin5, right: margin5)
          )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: RefreshIndicator(
          onRefresh: () async {
            await refreshUser(user);
          },
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                      Navigator.pop(context);
                    }).marginW(left: Global.blockX * 5),
                    Text(FlutterI18n.translate(context, "profile"), style: titleStyle),
                    Icon(Icons.file_upload, size: 20, color: Colors.white)
                  ],
                ).sizeW(Global.width, Global.blockY * 10),
                Expanded(
                    child: _userData == null ?
                    CircularProgressIndicator().center() :
                    Container(
                        child: Stack(children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 15,
                                      offset: Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Text( "${_userData.name} ${_userData.surname}",
                                    style: previewNameStyle)
                                    .center(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text( "${_userData.getAverageRate()} ",
                                        style: previewRateStyle),
                                    RatingBar(
                                      itemSize: Global.blockY * 2,
                                      ignoreGestures: true,
                                      initialRating: _userData.rate,
                                      minRating: 0,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: primaryColor,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    )
                                  ],
                                )
                                    .paddingW(
                                    bottom: Global.blockX * 3),
                                Visibility(
                                  visible: _userData.profileType == 1,
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(FlutterI18n.translate(context, "photos"), style: titleMediumStyle),
                                      ).paddingW(left: Global.blockX * 3),
                                      Container(
                                          child: _userData.portfolioImages.length > 0 ?
                                          Container(
                                              color: Colors.white,
                                              child: Stack(
                                                  children: <Widget>[
                                                    CarouselSlider(
                                                        options: CarouselOptions(
                                                          enableInfiniteScroll: false,
                                                        ),
                                                        items: _userData.portfolioImages.map((i) {
                                                          return Builder(
                                                              builder: (BuildContext context) {
                                                                return Container(
                                                                    width: MediaQuery.of(context)
                                                                        .size
                                                                        .width,
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal: 5.0),
                                                                    decoration: BoxDecoration(
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          10.0),
                                                                    ),
                                                                    child:
                                                                    i.getWidget().center()
                                                                        .center())
                                                                    .onClick(() {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialWithModalsPageRoute(
                                                                          builder: (context) =>
                                                                              ImagePage(_userData
                                                                                  .portfolioImages)));
                                                                });
                                                              });
                                                        }).toList()
                                                    ).center()
                                                  ]
                                              )
                                          ).sizeW(Global.blockX * 90, Global.blockY * 25) :
                                          Text(FlutterI18n.translate(context, "user_no_have_photos"))
                                      ).paddingW(
                                          top: Global.blockX * 3,
                                          bottom: Global.blockX * 3),
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(FlutterI18n.translate(context, "services"), style: titleMediumStyle),
                                      ).paddingW(left: Global.blockX * 3),
                                      Container(
                                          child: Column(
                                              children: buildServiceList(
                                                  _userData.services    // _masterData.services
                                              )))
                                          .paddingW(
                                          top: Global.blockX * 3,
                                          bottom: Global.blockX * 3)
                                    ]
                                  )
                                ),
                                Visibility(
                                  visible: _userData.about.isNotEmpty || (_userData.isShowAddress && _userData.address.isNotEmpty && _userData.isRecorded),
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(FlutterI18n.translate(context, "about"), style: titleMediumStyle),
                                      ).paddingW(left: Global.blockX * 3),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                              Text(_userData.about)
                                          ]
                                        ),
                                      ).paddingAll(Global.blockX * 3),
                                      Visibility(
                                          visible: _userData.isShowAddress && _userData.isRecorded,
                                          child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                    alignment: Alignment.bottomLeft,
                                                    child: Text( "${_userData.address}" ?? FlutterI18n.translate(context, "address_not_present"))
                                                ),
                                                // Icon(Icons.map, color: defaultColorAccent)
                                                // .onClick(() async {
                                                //   List<Location> locations = await locationFromAddress( "${_userData.address}");
                                                //
                                                // })
                                              ]
                                          ).paddingW(left: Global.blockX * 3, right: Global.blockX * 3)
                                      )
                                    ]
                                  )
                                ),
                                CommentBlock(_userData)
                              ],
                            ).paddingW(top: Global.blockY * 10),
                          ).marginW(
                              top: Global.blockY * 5,
                              left: Global.blockX * 5,
                              right: Global.blockX * 5,
                              bottom: Global.blockY * 10),
                          Container(
                            width: Global.blockX * 25,
                            height: Global.blockX * 25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: defaultCircleBorderRadius
                            ),
                            child: (_userData.avatar == null || _userData.avatar.isEmpty ? Text(
                                "${_userData.name[0]}${_userData.surname[0]}",
                                style: titleBigBlueStyle) :
                            Image.network( "$url/images/${_userData.avatar}"))
                                .center(),
                          ).positionW(
                              Global.blockX * 37.5, 0, Global.blockX * 37.5, null),
                          Visibility(
                              visible: _userData.isRecorded,
                              child: Container(
                                  height: Global.blockY * 6,
                                  width: Global.blockY * 6,
                                  decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: defaultCircleBorderRadius),
                                  child: Icon(Icons.message, color: Colors.white).center()
                              )
                                  .onClick(() async {
                                    var conversion = await conversions.getConversion(user, _userData.id);
                                    if(conversion == null) return;
                                    Navigator.push(
                                      context,
                                      MaterialWithModalsPageRoute(
                                          builder: (context) {
                                            return Correspondence(conversion);
                                          }
                                      ));
                                  })
                          ).positionW(
                              Global.blockX * 10, Global.blockX * 5, null, null),
                          Visibility(
                              visible: _userData.isRecorded && _userData.isShowPhone,
                              child: Container(
                                  height: Global.blockY * 6,
                                  width: Global.blockY * 6,
                                  decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: defaultCircleBorderRadius),
                                  child: Icon(Icons.phone, color: Colors.white).center()
                              )
                                  .onClick(() {
                                    launch( "tel:${_userData.phone}");
                              }))
                              .positionW(
                              null, Global.blockX * 5, Global.blockX * 10, null)
                        ]).scroll())
                )
              ]
          )
        )
        ).safe();
  }

  List<Widget> buildServiceList(List<Category> services) {
    List<Widget> widgets = <Widget>[];
    services.forEach((category) {
      if (category.services.isNotEmpty && category.isHaveServiceWrapper()) {
        widgets.add(Container(
            alignment: Alignment.bottomLeft,
            color: Colors.grey.withAlpha(30),
            child: Text(category.name, textAlign: TextAlign.start).paddingW(
              left: Global.blockX * 3,
              right: Global.blockX * 3,
            )));
        category.services.forEach((wrapper) {
          widgets.add(buildServiceItem(wrapper));
        });
      }
    });
    if(widgets.isEmpty) {
      widgets.add(Text(FlutterI18n.translate(context, "master_not_have_services")).center());
    }
    return widgets;
  }

  Widget buildServiceItem(Service service) {
    return service.wrapper == null ? Container() : Column(children: <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(service.name, style: service.isTatoo ? titleSmallBlueStyle : titleSmallStyle)
        .onClick(() {
          if(service.isTatoo) {
            Navigator.push(
                context,
                MaterialWithModalsPageRoute(
                  builder: (context) => SeeMasterSketchesPage(_userData.id)
                )
            );
          }
        }),
        Icon(Icons.info, color: Colors.grey.withAlpha(100), size: 20)
            .onClick(() {
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) {
                return Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        color: Colors.white),
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        Text(service.name, style: titleStyle),
                        Text(service.wrapper.description)
                      ],
                    ).paddingW(
                        left: Global.blockX * 5,
                        top: Global.blockX * 5,
                        right: Global.blockX * 5,
                        bottom: Global.blockX * 5));
              });
        }).visibility(service.wrapper?.description?.isNotEmpty ?? false)
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Visibility(
          visible: service.wrapper.time > 0,
          child: Text( "${service.wrapper.time} ${FlutterI18n.translate(context, "min")}")
        ),
        Visibility(
            visible: service.wrapper.price > 0,
            child: Text( "${service.wrapper.price} ${FlutterI18n.translate(context, "currency")}")
        )
      ])
    ]).paddingW(
        left: Global.blockX * 3,
        top: Global.blockX,
        right: Global.blockX * 3,
        bottom: Global.blockX);
  }
}