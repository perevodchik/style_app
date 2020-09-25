import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/Comment.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Service.dart';
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

class UserProfile extends StatefulWidget {
  final int _masterId;

  const UserProfile(this._masterId);

  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  UserData _userData;
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final ProfileProvider user = Provider.of<ProfileProvider>(context);
    final ConversionProvider conversions = Provider.of<ConversionProvider>(context);

    _memoizer.runOnce(() async {
      var userData = await UserService.get().getFullDataById(user, widget._masterId);
      print("run ${i++}");
      setState(() {
        _userData = userData;
      });
    });

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        floatingActionButton: Visibility(
          visible: _userData != null && _userData.profileType == 1,
          child: RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialWithModalsPageRoute(
                      builder: (context) => NewOrderScreen(_userData, null)));
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: defaultItemBorderRadius
            ),
            color: Colors.blueAccent,
            child: Text("Записаться", style: recordButtonStyle)
                .marginW(left: margin5, right: margin5)
          )
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                    Navigator.pop(context);
                  }).marginW(left: Global.blockX * 5),
                  Text("Профиль", style: titleStyle),
                  Icon(Icons.file_upload, size: 20, color: Colors.white)
                ],
              ).sizeW(Global.width, Global.blockY * 10),
              Expanded(
                child: _userData == null ?
                    CircularProgressIndicator().center() :
                Container(
                    child: Stack(children: <Widget>[
                      Container(
                        width: Global.width,
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
                            Text("${_userData.name} ${_userData.surname}",
                                style: previewNameStyle)
                                .center(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("${_userData.getAverageRate()} ",
                                    style: previewRateStyle),
                                RatingBar(
                                  itemSize: Global.blockY * 2,
                                  ignoreGestures: true,
                                  initialRating: _userData.getAverageRate(),
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.blueAccent,
                                  ),
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                  },
                                )
                              ],
                            ),
                            Container(
                                color: Colors.white,
                                child: Stack(
                                    children: <Widget>[
                                      CarouselSlider(
                                          options: CarouselOptions(
                                            height: Global.blockY * 20,
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
                                                        color: Colors.blueAccent,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                      ),
                                                      child: Text('$i',
                                                          style: TextStyle(
                                                              fontSize: 16.0))
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
                            ).sizeW(Global.blockX * 90, Global.blockY * 25),
                            Visibility(
                                visible: _userData.isShowAddress,
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          width: Global.blockX * 60,
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                              "Красноярск, улица Маерчака 38"))
                                    ]
                                ).paddingW(left: Global.blockX * 3)),
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Text("Услуги", style: titleMediumStyle),
                            ).paddingW(left: Global.blockX * 3),
                            Container(
                                child: Column(
                                    children: buildServiceList(
                                        _userData.services    // _masterData.services
                                    )))
                                .paddingW(
                                top: Global.blockX * 3,
                                bottom: Global.blockX * 3),
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Text("О себе", style: titleMediumStyle),
                            ).paddingW(left: Global.blockX * 3),
                            Container(
                              child: Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                style: profileDescriptionStyle,
                              ),
                            ).paddingAll(Global.blockX * 3),
                            CommentBlock(_userData)
                          ],
                        ).paddingW(top: Global.blockY * 10),
                      ).marginW(
                          top: Global.blockY * 6,
                          left: Global.blockX * 5,
                          right: Global.blockX * 5,
                          bottom: Global.blockY * 10),
                      Container(
                        width: Global.blockX * 25,
                        height: Global.blockX * 25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: defaultCircleBorderRadius,
                        ),
                        child: Text(
                            "${_userData.name[0]}${_userData.surname[0]}",
                            style: titleBigBlueStyle)
                            .center(),
                      ).positionW(
                          Global.blockX * 37.5, 0, Global.blockX * 37.5, null),
                      Visibility(
                          visible: _userData.isShowAddress,
                          child: Container(
                              height: Global.blockY * 6,
                              width: Global.blockY * 6,
                              decoration: BoxDecoration(
                                  color: defaultColorAccent,
                                  borderRadius: defaultCircleBorderRadius),
                              child: Icon(Icons.message, color: Colors.white).center()
                          )
                              .onClick(() => Navigator.push(
                              context,
                              MaterialWithModalsPageRoute(
                                  builder: (context) {
                                    return Correspondence(
                                        conversions.getConversion(user.id, _userData.id));
                                  }
                              ))))
                          .positionW(
                          Global.blockX * 10, Global.blockX * 5, null, null)
                    ]).scroll())
                // FutureBuilder(
                //   future: _fetch(user),
                //   builder: (c, s) {
                //     print(s.toString());
                //     print("[${s.connectionState}] [${s.hasData}] [${s.data}] [${s.hasError}] [${s.error}]");
                //     if(s.connectionState == ConnectionState.done && s.hasData && !s.hasError) {
                //       _userData = s.data;
                //       return Container(
                //           child: Stack(children: <Widget>[
                //             Container(
                //               width: Global.width,
                //               decoration: BoxDecoration(
                //                   color: Colors.white,
                //                   borderRadius: BorderRadius.all(Radius.circular(10)),
                //                   boxShadow: [
                //                     BoxShadow(
                //                         color: Colors.grey.withOpacity(0.3),
                //                         spreadRadius: 2,
                //                         blurRadius: 15,
                //                         offset: Offset(0, 10))
                //                   ]),
                //               child: Column(
                //                 children: <Widget>[
                //                   Text("${_userData.name} ${_userData.surname}",
                //                       style: previewNameStyle)
                //                       .center(),
                //                   Row(
                //                     mainAxisAlignment: MainAxisAlignment.center,
                //                     children: <Widget>[
                //                       Text("${_userData.getAverageRate()} ",
                //                           style: previewRateStyle),
                //                       RatingBar(
                //                         itemSize: Global.blockY * 2,
                //                         ignoreGestures: true,
                //                         initialRating: _userData.getAverageRate(),
                //                         minRating: 0,
                //                         direction: Axis.horizontal,
                //                         allowHalfRating: true,
                //                         itemCount: 5,
                //                         itemBuilder: (context, _) => Icon(
                //                           Icons.star,
                //                           color: Colors.blueAccent,
                //                         ),
                //                         onRatingUpdate: (rating) {
                //                           print(rating);
                //                         },
                //                       )
                //                     ],
                //                   ),
                //                   Container(
                //                       color: Colors.white,
                //                       child: Stack(
                //                           children: <Widget>[
                //                             CarouselSlider(
                //                                 options: CarouselOptions(
                //                                   height: Global.blockY * 20,
                //                                 ),
                //                                 items: _userData.portfolioImages.map((i) {
                //                                   return Builder(
                //                                       builder: (BuildContext context) {
                //                                         return Container(
                //                                             width: MediaQuery.of(context)
                //                                                 .size
                //                                                 .width,
                //                                             margin: EdgeInsets.symmetric(
                //                                                 horizontal: 5.0),
                //                                             decoration: BoxDecoration(
                //                                               color: Colors.blueAccent,
                //                                               borderRadius:
                //                                               BorderRadius.circular(
                //                                                   10.0),
                //                                             ),
                //                                             child: Text('$i',
                //                                                 style: TextStyle(
                //                                                     fontSize: 16.0))
                //                                                 .center())
                //                                             .onClick(() {
                //                                           Navigator.push(
                //                                               context,
                //                                               MaterialWithModalsPageRoute(
                //                                                   builder: (context) =>
                //                                                       ImagePage(_userData
                //                                                           .portfolioImages)));
                //                                         });
                //                                       });
                //                                 }).toList()
                //                             ).center()
                //                           ]
                //                       )
                //                   ).sizeW(Global.blockX * 90, Global.blockY * 25),
                //                   Visibility(
                //                       visible: _userData.isShowAddress,
                //                       child: Row(
                //                           mainAxisAlignment:
                //                           MainAxisAlignment.spaceBetween,
                //                           children: <Widget>[
                //                             Container(
                //                                 width: Global.blockX * 60,
                //                                 alignment: Alignment.bottomLeft,
                //                                 child: Text(
                //                                     "Красноярск, улица Маерчака 38"))
                //                           ]
                //                       ).paddingW(left: Global.blockX * 3)),
                //                   Container(
                //                     alignment: Alignment.bottomLeft,
                //                     child: Text("Услуги", style: titleMediumStyle),
                //                   ).paddingW(left: Global.blockX * 3),
                //                   Container(
                //                       child: Column(
                //                           children: buildServiceList(
                //                               _userData.services    // _masterData.services
                //                           )))
                //                       .paddingW(
                //                       top: Global.blockX * 3,
                //                       bottom: Global.blockX * 3),
                //                   Container(
                //                     alignment: Alignment.bottomLeft,
                //                     child: Text("О себе", style: titleMediumStyle),
                //                   ).paddingW(left: Global.blockX * 3),
                //                   Container(
                //                     child: Text(
                //                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                //                       style: profileDescriptionStyle,
                //                     ),
                //                   ).paddingAll(Global.blockX * 3),
                //                   CommentBlock(_userData)
                //                 ],
                //               ).paddingW(top: Global.blockY * 10),
                //             ).marginW(
                //                 top: Global.blockY * 6,
                //                 left: Global.blockX * 5,
                //                 right: Global.blockX * 5,
                //                 bottom: Global.blockY * 10),
                //             Container(
                //               width: Global.blockX * 25,
                //               height: Global.blockX * 25,
                //               decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 borderRadius: defaultCircleBorderRadius,
                //               ),
                //               child: Text(
                //                   "${_userData.name[0]}${_userData.surname[0]}",
                //                   style: titleBigBlueStyle)
                //                   .center(),
                //             ).positionW(
                //                 Global.blockX * 37.5, 0, Global.blockX * 37.5, null),
                //             Visibility(
                //                 visible: _userData.isShowAddress,
                //                 child: Container(
                //                     height: Global.blockY * 6,
                //                     width: Global.blockY * 6,
                //                     decoration: BoxDecoration(
                //                         color: defaultColorAccent,
                //                         borderRadius: defaultCircleBorderRadius),
                //                     child: Icon(Icons.message, color: Colors.white).center()
                //                 )
                //                     .onClick(() => Navigator.push(
                //                     context,
                //                     MaterialWithModalsPageRoute(
                //                         builder: (context) {
                //                           return Correspondence(
                //                               conversions.getConversion(user.id, _userData.id));
                //                         }
                //                     ))))
                //                 .positionW(
                //                 Global.blockX * 10, Global.blockX * 5, null, null)
                //           ]).scroll());
                //     } else if(s.connectionState == ConnectionState.done && !s.hasData) {
                //       return Text("Пользователь не найден").center();
                //     }
                //     else return CircularProgressIndicator().center();
                //   },
                // )
              )
            ])).safe();
  }

  List<Widget> buildCommentBlock(List<Comment> comments) {
    List<Widget> widgets = <Widget>[];
    for (int i = 0; i < comments.length; i++) {
      var v = Container(
              decoration: BoxDecoration(
                color: defaultItemColor,
                  borderRadius: defaultItemBorderRadius),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius:
                                  defaultItemBorderRadius),
                        ).sizeW(Global.blockX * 5, Global.blockX * 5).marginW(
                            top: Global.blockY,
                            right: Global.blockX * 2,
                            bottom: Global.blockY),
                        Text(
                        "client",
                            style: titleSmallStyle)
                      ]),
                      Text("", style: hintExtraSmallStyle)
                    ],
                  ).paddingW(top: Global.blockX),
                  Row(children: <Widget>[
                    RatingBar(
                      itemSize: Global.blockY * 2,
                      ignoreGestures: true,
                      initialRating: comments[i].rate,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.blueAccent,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    )
                  ]),
                  Text(comments[i].message, style: commentTextStyle)
                      .paddingAll(Global.blockX)
                ],
              ).marginW(left: Global.blockX * 2, right: Global.blockX * 2))
          .marginW(bottom: Global.blockY * 2);
      widgets.add(v);
    }

    return widgets;
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
      widgets.add(Text("Мастер не еще не добавил список услуг").center());
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
                  builder: (context) => SeeMasterSketchesPage(_userData)
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
        Text("${service.wrapper.time} мин"),
        Text("${service.wrapper.price} грн"),
      ])
    ]).paddingW(
        left: Global.blockX * 3,
        top: Global.blockX,
        right: Global.blockX * 3,
        bottom: Global.blockX);
  }
}