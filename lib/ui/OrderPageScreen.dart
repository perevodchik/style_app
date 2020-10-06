import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/model/Sentence.dart';
import 'package:style_app/service/CommentsRepository.dart';
import 'package:style_app/service/OrdersService.dart';
import 'package:style_app/service/SentenceRepository.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/ui/CommentBlock.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/ProfileScreen.dart';
import 'package:style_app/ui/SentenceCommentsScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class OrderPage extends StatefulWidget {
  final int _orderId;

  OrderPage(this._orderId);

  @override
  State<StatefulWidget> createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  OrderFull order;
  final AsyncMemoizer memozier = AsyncMemoizer();
  bool isNeedRefresh = false;

  OrderPageState();
  TextEditingController _commentController;

  @override
  void initState() {
    _commentController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);

    memozier.runOnce(() => OrdersService.get().orderById(profile, widget._orderId).then((value) {
      setState(() {
        order = value;
      });
    }));

    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: Visibility(
          visible: order?.status != 1 && order?.status != 4 ?? false,
          child: Container(
            padding: EdgeInsets.all(Global.blockX),
            decoration: BoxDecoration(
                color: defaultColorAccent,
                borderRadius: defaultCircleBorderRadius),
            child: Icon(Icons.list, color: Colors.white, size: 28)
          ),
        ).onClick(() {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) =>
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: defaultModalRadius),
                      child: profile.profileType == 0 ?
                      ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Visibility(
                            visible: profile.profileType == 0 && order.status == 2,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text("Завершить заказ?"),
                                  RaisedButton(
                                      onPressed: () async {
                                        var isUpdate = await OrdersService
                                            .get()
                                            .updateOrderStatus(
                                            profile,
                                            order.id,
                                            order.client.id,
                                            order.master.id ?? null,
                                            1
                                        );
                                        if(isUpdate) {
                                          print("norm");
                                          Navigator.pop(context);
                                          setState(() {
                                            order.status = 1;
                                          });
                                          showModalBottomSheet(
                                              backgroundColor: Colors.transparent,
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) => ResponseModal(
                                                  order.master.id, order.id));
                                        }
                                      },
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: defaultItemBorderRadius
                                      ),
                                      color: defaultColorAccent,
                                      child:
                                      Text("Завершить", style: smallWhiteStyle))
                                ]),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text("Отменить заказ?"),
                                RaisedButton(
                                    onPressed: () async {
                                      var isUpdate = await OrdersService
                                          .get()
                                          .updateOrderStatus(
                                          profile,
                                          order.id,
                                          order.client.id,
                                          order.master.id ?? null,
                                          4
                                      );
                                      if(isUpdate) {
                                        setState(() {
                                          order.status = 4;
                                        });
                                        Navigator.pop(context);
                                      }
                                    },
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: defaultItemBorderRadius
                                    ),
                                    color: Colors.white,
                                    child: Text("Отменить",
                                        style: titleSmallBlueStyle))
                              ])
                        ],
                      ) :
                      ListView(
                        shrinkWrap: true,
                          children: <Widget>[
                            Visibility(
                                visible: order?.status == 3 ?? false,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text("Подтвердить запись"),
                                      RaisedButton(
                                          onPressed: () async {
                                            var isUpdate = await OrdersService
                                                .get()
                                                .updateOrderStatus(
                                                profile,
                                                order.id,
                                                order.client.id,
                                                profile.id,
                                                2
                                            );
                                            if(isUpdate) {
                                              setState(() {
                                                order.status = 2;
                                              });
                                              Navigator.pop(context);
                                            }
                                          },
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: defaultItemBorderRadius
                                          ),
                                          color: defaultColorAccent,
                                          child:
                                          Text("Подтвердить", style: smallWhiteStyle))
                                    ])
                            ),
                            Visibility(
                                visible: order?.status == 0 || order?.status == 3,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text("Добавить предложение"),
                                      RaisedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            showModalBottomSheet(
                                                backgroundColor: Colors.transparent,
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) => SentenceModal(
                                                    order));
                                          },
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: defaultItemBorderRadius
                                          ),
                                          color: defaultColorAccent,
                                          child:
                                          Text("Добавить", style: smallWhiteStyle))
                                    ])
                            ),
                            Visibility(
                                visible: order.master == null ? false : order.master.id == profile.id,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text("Отменить заказ?"),
                                      RaisedButton(
                                          onPressed: () async {
                                            var isUpdate = await OrdersService
                                                .get()
                                                .updateOrderStatus(
                                                profile,
                                                order.id,
                                                order.client.id,
                                                order.master.id ?? null,
                                                4
                                            );
                                            if(isUpdate) {
                                              setState(() {
                                                order.status = 4;
                                              });
                                              Navigator.pop(context);
                                            }
                                            Navigator.pop(context);
                                          },
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: defaultItemBorderRadius
                                          ),
                                          color: Colors.white,
                                          child: Text("Отменить",
                                              style: titleSmallBlueStyle))
                                    ])
                            )
                          ]
                      )
                  )
          );
        }),
        appBar: null,
        body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                      Navigator.pop(context, isNeedRefresh ? "refresh" : "");
                    }).marginW(left: Global.blockX * 5),
                    Text("Просмотр записи", style: titleStyle),
                    Icon(Icons.file_upload, size: 20, color: Colors.transparent)
                  ],
                ).sizeW(Global.width, Global.blockY * 10),
                order == null ?
                CircularProgressIndicator().center() :
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          var refreshedOrder = await OrdersService.get().orderById(profile, widget._orderId);
                          if(refreshedOrder != null)
                            setState(() => order = refreshedOrder);
                        },
                        child: ListView(
                            children: <Widget>[
                              Row(
                                  children: [
                                    Container(
                                        height: Global.blockY * 5,
                                        width: Global.blockY * 5,
                                        decoration: BoxDecoration(
                                            color: defaultItemColor,
                                            borderRadius: defaultCircleBorderRadius
                                        ),
                                        child: (
                                        order?.client?.avatar == null ?
                                        Text("${order?.client?.name[0].toUpperCase()}${order?.client?.surname[0].toUpperCase()}", style: titleMediumBlueStyle) :
                                        order.client.avatar.getWidget()
                                        ).center()
                                    ),
                                    Text("${order?.client?.name} ${order?.client?.surname}", style: titleMediumBlueStyle).marginW(
                                        left: Global.blockX * 3)
                                  ]
                              ).onClick(() => Navigator.push(
                                  context,
                                  MaterialWithModalsPageRoute(
                                      builder: (c) => UserProfile(order.client.id)
                                  )
                              )).marginW(left: margin5, right: margin5),
                              Visibility(
                                  visible: order.master != null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text("Исполнитель", style: titleSmallStyle),
                                      Text("${order?.master?.name} ${order?.master?.surname}",
                                          style: titleSmallBlueStyle).onClick(() {
                                        Navigator.push(
                                            context,
                                            MaterialWithModalsPageRoute(
                                                builder: (c) => UserProfile(order?.master?.id)));
                                      })
                                    ],
                                  )).marginW(bottom: Global.blockY * 2)
                                  .marginW(left: margin5, right: margin5),
                              order.name == null || order.name.isEmpty
                                  ? Text("Запись номер ${order.id}",
                                  style: titleMediumBlueStyle)
                                  .center().marginW(left: margin5, right: margin5)
                                  : Text(order.name, style: titleMediumBlueStyle)
                                  .center().marginW(left: margin5, right: margin5),
                              Visibility(
                                visible: order.description.length > 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: defaultItemColor,
                                      borderRadius: BorderRadius.all(Radius.circular(10))),
                                  child: Text("${order.description}", style: titleSmallStyle)
                                      .paddingAll(Global.blockY)
                                ).marginW(
                                    left: margin5,
                                    top: Global.blockY * 2,
                                    right: margin5,
                                    bottom: Global.blockY * 3)
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Стоимость", style: titleSmallStyle),
                                  Container(
                                      padding: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                      margin: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                      decoration: BoxDecoration(
                                          color: defaultItemColor,
                                          borderRadius: defaultItemBorderRadius
                                      ),
                                      child: Row(
                                          children: [
                                            Text(order.price == null || order.price <= 0 ? "Не указана" : "${order.price} грн.")
                                          ]
                                      )
                                  )
                                ]
                              ).marginW(left: margin5, right: margin5),
                              Visibility(
                                visible: order.city != null,
                                child:
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Город", style: titleSmallStyle),
                                      Container(
                                          padding: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                          margin: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                          decoration: BoxDecoration(
                                              color: defaultItemColor,
                                              borderRadius: defaultItemBorderRadius
                                          ),
                                          child: Row(
                                              children: [
                                                Text(order?.city?.name ?? "Не указан")
                                              ]
                                          )
                                      )
                                    ]
                                ).marginW(left: margin5, right: margin5)
                              ),
                              Visibility(
                                visible: order.photos.isNotEmpty && order.photos.length > 0,
                                child: ExpansionTile(
                                  title: Text("Прикрепленные фотографии",
                                      style: titleSmallBlueStyle),
                                  children: <Widget>[
                                    CarouselSlider(
                                      options: CarouselOptions(
                                        enableInfiniteScroll: false,
                                      ),
                                      items: order.photos.map((i) {
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return Container(
                                              width: MediaQuery.of(context).size.width,
                                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: i.getWidget(),
                                            ).onClick(() {
                                              Navigator.push(
                                                  context,
                                                  MaterialWithModalsPageRoute(
                                                      builder: (context) =>
                                                          ImagePage(order.photos)));
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ).marginW(top: Global.blockX, bottom: Global.blockX)
                                  ],
                                ),
                              ).marginW(left: margin5, right: margin5),
                              Visibility(
                                visible: order.services.isNotEmpty,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Выбранные категории", style: titleSmallStyle),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: defaultItemColor,
                                        borderRadius: defaultItemBorderRadius
                                      ),
                                      child: Column(
                                          children: order.services
                                              .map((s) => s == null
                                              ? Container()
                                              : Row(children: <Widget>[
                                            Text(
                                              "$s",
                                              textAlign: TextAlign.start,
                                            )
                                          ]))
                                              .toList()
                                      )
                                    )
                                  ]
                                )
                                // ExpansionTile(
                                //   title:
                                //
                                //   children: <Widget>[
                                //     Column(
                                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                //         children: order.services
                                //             .map((s) => s == null
                                //             ? Container()
                                //             : Row(children: <Widget>[
                                //           Text(
                                //             "$s",
                                //             textAlign: TextAlign.start,
                                //           )
                                //         ]))
                                //             .toList())
                                //         .marginW(top: Global.blockX, bottom: Global.blockX)
                                //   ],
                                // ),
                              ).marginW(
                                  left: margin5,
                                  right: margin5),
                              order.sketchData == null ?
                              Container() :
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Позиция татуировки", style: titleSmallStyle),
                                    Container(
                                        padding: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        margin: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        decoration: BoxDecoration(
                                            color: defaultItemColor,
                                            borderRadius: defaultItemBorderRadius
                                        ),
                                        child: Row(
                                            children: [
                                              Text("${order?.sketchData?.position?.name}")
                                            ]
                                        )
                                    ),
                                    Text("Стиль татуировки", style: titleSmallStyle),
                                    Container(
                                        padding: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        margin: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        decoration: BoxDecoration(
                                            color: defaultItemColor,
                                            borderRadius: defaultItemBorderRadius
                                        ),
                                        child: Row(
                                            children: [
                                              Text("${order?.sketchData?.style?.name}")
                                            ]
                                        )
                                    ),
                                    Text("Цвет татуировки", style: titleSmallStyle),
                                    Container(
                                        padding: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        margin: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        decoration: BoxDecoration(
                                            color: defaultItemColor,
                                            borderRadius: defaultItemBorderRadius
                                        ),
                                        child: Row(
                                            children: [
                                              Text(order?.sketchData?.isColored ? "Цветная" : "Черно-белая")
                                            ]
                                        )
                                    ),
                                    Text("Размеры татуировки", style: titleSmallStyle),
                                    Container(
                                        padding: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        margin: EdgeInsets.only(top: Global.blockY * 1, bottom: Global.blockY * 1),
                                        decoration: BoxDecoration(
                                            color: defaultItemColor,
                                            borderRadius: defaultItemBorderRadius
                                        ),
                                        child: Row(
                                            children: [
                                              Text("Высота ${order?.sketchData?.width}\nШирина ${order?.sketchData?.height}")
                                            ]
                                        )
                                    ),
                                  ]
                              ).marginW(left: margin5, right: margin5),
                              order.status != 1 ?
                              Column(
                                  children: [
                                    Text("Ставки", style: titleMediumBlueStyle)
                                        .center()
                                        .marginAll(Global.blockY * 2).marginW(
                                        left: margin5,
                                        right: margin5),
                                    Container(
                                        child: order.sentences.isEmpty
                                            ? Container(
                                          padding: EdgeInsets.all(Global.blockY),
                                          decoration: BoxDecoration(
                                              color: defaultItemColor,
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(10))),
                                          child: Text("Ставок еще нет").center(),
                                        ) : Column(
                                            children: order.sentences
                                                .map((s) {
                                              print("b ${s.toString()}");
                                              return SentencePreview(order, s)
                                                  .marginW(
                                                  top: Global.blockX,
                                                  bottom: Global.blockY)
                                                  .onClick(() {

                                              });
                                            }).toList()))
                                        .marginW(
                                        left: margin5,
                                        right: margin5)
                                  ]
                              ).marginW(bottom: Global.blockY * 5) :
                              Column(
                                children: [
                                  Text("Отзыв клиента", style: titleMediumBlueStyle)
                                      .center()
                                      .marginAll(Global.blockY * 2).marginW(
                                      left: margin5,
                                      right: margin5),
                                  Container(
                                    child: order.clientComment != null ?
                                    CommentPreview(order.clientComment).marginW(
                                        left: margin5,
                                        right: margin5) :
                                    (profile.id == order.client.id ?
                                    RaisedButton(
                                        onPressed: () async {
                                            var r = await showModalBottomSheet(
                                                backgroundColor: Colors.transparent,
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) => ResponseModal(
                                                    order.master.id, order.id));
                                            if(r != null) {
                                              setState(() {
                                                order.clientComment = r;
                                              });
                                          }
                                        },
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: defaultItemBorderRadius
                                        ),
                                        color: defaultColorAccent,
                                        child:
                                        Text("Добавить отзыв", style: smallWhiteStyle)) :
                                      Text("Клиент еще не добавил отзыв о Вашей работе")
                                    )
                                  ),
                                  Text("Отзыв мастера", style: titleMediumBlueStyle)
                                      .center()
                                      .marginAll(Global.blockY * 2).marginW(
                                      left: margin5,
                                      right: margin5),
                                  Container(
                                      child: order.masterComment != null ?
                                      CommentPreview(order.masterComment).marginW(
                                          left: margin5,
                                          right: margin5) :
                                      (profile.id == order.master.id ?
                                      RaisedButton(
                                          onPressed: () async {
                                            var r = await showModalBottomSheet(
                                                backgroundColor: Colors.transparent,
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) => ResponseModal(
                                                    order.client.id, order.id));
                                            if(r != null) {
                                              setState(() {
                                                order.clientComment = r;
                                              });
                                            }
                                          },
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: defaultItemBorderRadius
                                          ),
                                          color: Colors.white,
                                          child:
                                          Text("Добавить отзыв", style: titleSmallBlueStyle)) :
                                      Text("Мастер еще не оставил отзыв о Вас")
                                      )
                                  ),
                                ]
                              ).marginW(bottom: Global.blockY * 5)
                            ]
                        )
                    )
                )
              ]
        ).safe());
  }
}

class SentencePreview extends StatelessWidget {
  final OrderFull order;
  final Sentence s;

  SentencePreview(this.order, this.s);

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
        decoration: BoxDecoration(
          color: defaultItemColor,
          borderRadius: defaultItemBorderRadius,
        ),
        padding: EdgeInsets.all(Global.blockY),
        child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        height: Global.blockX * 10,
                        width: Global.blockX * 10,
                        padding: EdgeInsets.all(Global.blockX),
                          margin: EdgeInsets.only(right: Global.blockX),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: defaultCircleBorderRadius
                          ),
                          child: (s.masterAvatar == null || s.masterAvatar.isEmpty ? Text(
                              "${s.masterName[0].toUpperCase()}${s.masterSurname[0].toUpperCase()}", style: titleMediumBlueStyle
                          ) : Image.network("$url/images/${s.masterAvatar}")
                          ).center()
                      ),
                      Text("${s.masterName} ${s.masterSurname}",
                          style: titleSmallBlueStyle)
                          .onClick(() {
                        Navigator.push(
                            context,
                            MaterialWithModalsPageRoute(
                                builder: (c) =>
                                    UserProfile(
                                        s.masterId)));
                      })
                    ]
                  ),
                  Text("Комментарии(${s.commentsCount})", style: titleSmallBlueStyle)
                      .onClick(() => Navigator.push(context,
                      MaterialWithModalsPageRoute(
                          builder: (c) => SentenceCommentsPage(order.status, s.id)
                      )
                  ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(s.price != null ? "${s.price} грн" : "",
                      style: commentHintStyle),
                  Text("${s.createDate.getFullDate()}", style: commentHintStyle)
                ],
              ).paddingW(
                  top: Global.blockX,
                  bottom: Global.blockY),
              Text("${s.text}")
            ]))
    .onClick(() async {
      if(profile.id != order.client.id) return;
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
          context: context,
          builder: (b) => Container(
            decoration: BoxDecoration(
              borderRadius: defaultModalBorderRadius,
              color: Colors.white
            ),
              child: ListView(
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       Text("Выбрать исполнителем ", style: titleSmallStyle),
                        Text("${s.masterName} ${s.masterSurname}", style: titleSmallBlueStyle).onClick(() {
                          Navigator.push(
                              context,
                              MaterialWithModalsPageRoute(
                                  builder: (c) =>
                                      UserProfile(
                                          s.masterId)));
                        }),
                        Text(" ?", style: titleSmallStyle)
                      ]
                    ).paddingW(top: Global.blockY * 2, bottom: Global.blockY * 2),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: defaultItemBorderRadius
                            ),
                            color: Colors.white,
                            child:
                            Text("Нет", style: titleMediumBlueStyle)),
                        RaisedButton(
                            onPressed: () async {
                              var isUpdate = await OrdersService
                                  .get()
                                  .updateOrderStatus(
                                  profile,
                                  order.id,
                                  order.client.id,
                                  s.masterId,
                                  2
                              );
                              if(isUpdate) {
                                Navigator.pop(context, true);
                              }
                            },
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: defaultItemBorderRadius
                            ),
                            color: defaultColorAccent,
                            child:
                            Text("Да", style: smallWhiteStyle))
                      ]
                    )
                  ]
              ).paddingW(top: Global.blockY * 2, bottom: Global.blockY * 2)
          ));
    });
  }
}

class SentenceModal extends StatefulWidget {
  final OrderFull _order;
  SentenceModal(this._order);
  @override
  State<StatefulWidget> createState() => SentenceModalState();
}

class SentenceModalState extends State<SentenceModal> {
  TextEditingController _sentenceTextController;
  TextEditingController _sentencePriceController;

  @override
  void initState() {
    _sentenceTextController = TextEditingController();
    _sentencePriceController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _sentenceTextController.dispose();
    _sentencePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: defaultItemBorderRadius
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text("Добавить предложение", style: titleMediumStyle)
              .paddingW(bottom: Global.blockY)
              .center(),
          Text("Введите стоимость", style: titleSmallStyle)
              .marginW(left: margin5, right: margin5),
          TextField(
            keyboardType: TextInputType.number,
            controller: _sentencePriceController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Стоимость",
              hintStyle: hintSmallStyle
            )
          )
              .marginW(left: margin5, right: margin5),
          Text("Введите комментарий", style: titleSmallStyle)
              .marginW(left: margin5, right: margin5),
          TextField(
              controller: _sentenceTextController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "комментарий",
                  hintStyle: hintSmallStyle
              )
          )
              .marginW(left: margin5, right: margin5),
          RaisedButton(
            onPressed: () async {
              var price;
              try {
                price = int.parse(_sentencePriceController.text);
              } catch (e) {
                print(e.toString());
              }
              var message = _sentenceTextController.text;
              var sentence = await SentenceRepository.get().createSentence(profile, widget._order.id, price, message);
              if(sentence != null) {
                widget._order.sentences.add(sentence);
                Navigator.pop(context);
              }
            },
              child: Text("Отправить", style: smallWhiteStyle),
            color: defaultColorAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: defaultItemBorderRadius
            )
          ).marginW(left: margin5, right: margin5)
        ]
      ).paddingW(top: Global.blockY)

    );
  }
}

class ResponseModal extends StatefulWidget {
  final int targetId;
  final int orderId;

  ResponseModal(this.targetId, this.orderId);

  @override
  State<StatefulWidget> createState() => ResponseModalState();
}

class ResponseModalState extends State<ResponseModal> {
  double _rate = 5;
  TextEditingController _commentController;

  @override
  void initState() {
    _commentController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: defaultModalRadius),
        child: ListView(
          shrinkWrap: true,
            children: [
              Text("Пожалуйста, оцените работу мастера",
                      style: titleMediumStyle)
                  .marginW(top: Global.blockY * 3).center(),
              RatingBar(
                itemSize: Global.blockY * 5,
                initialRating: _rate,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: defaultColorAccent,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rate = rating;
                  });
                  print(rating);
                },
              ).marginW(top: Global.blockY, bottom: Global.blockY).center(),
              TextField(
                controller: _commentController,
                minLines: 5,
                maxLines: 5,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Добавьте Ваш комментарий",
                    hintStyle: hintSmallStyle),
              ).marginW(
                  left: margin5,
                  right: margin5),
              RaisedButton(
                      onPressed: () async {
                        var r = await CommentsRepository.get().createComment(profile, widget.targetId, widget.orderId, _rate, _commentController.text);
                        print("$r");
                        Navigator.pop(context);
                      },
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: defaultItemBorderRadius
                      ),
                      color: defaultColorAccent,
                      child: Text("Отправить", style: smallWhiteStyle))
                  .marginW(left: margin5, right: margin5, bottom: Global.blockY * 3)
            ]));
  }
}