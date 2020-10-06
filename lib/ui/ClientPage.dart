import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/NotifySettings.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/RecordProvider.dart';
import 'package:style_app/ui/CommentBlock.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class ClientPage extends StatelessWidget {
  final UserData data;
  ClientPage(this.data);
  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final ConversionProvider conversions = Provider.of<ConversionProvider>(context);
    final OrdersProvider records = Provider.of<OrdersProvider>(context);
    bool isRecorded = records.isRecord(clientId: data.id, masterId: profile.id);
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
              Text("Страница клиента", style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          Expanded(
            child: Container(
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
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text("${data.name} ${data.surname}", style: titleMediumStyle)
                            .marginW(left: margin5, right: margin5)
                            .center(),
                        Visibility(
                            visible: isRecorded && data.phone != null && data.phone.isNotEmpty,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Мобильный", style: titleMediumStyle),
                                  Text("${data.phone}")
                                ]
                            ).marginW(left: margin5,
                                top: Global.blockY,
                                right: margin5)
                        ),
                        Visibility(
                          visible: isRecorded && data.city != null && data.city >= 0,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Город", style: titleMediumStyle),
                                  Text("${data.city != null ? Cities.cities[data.city] : ""}")
                                ]
                            ).marginW(left: margin5,
                                top: Global.blockY,
                                right: margin5)
                        ),
                        Visibility(
                            visible: isRecorded && data.email != null && data.email.isNotEmpty,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("E-mail", style: titleMediumStyle),
                                  Text("${data.email}")
                                ]
                            ).marginW(left: margin5,
                                top: Global.blockY,
                                right: margin5)
                        ),
                        CommentBlock(data)
                      ]
                    ).marginW(top: Global.blockY * 12.5)
                  ).marginW(
                      top: Global.blockY * 5,
                      left: Global.blockX * 5,
                      right: Global.blockX * 5,
                      bottom: Global.blockY * 5),
                  Container(
                    width: Global.blockX * 25,
                    height: Global.blockX * 25,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(Global.blockY * 10)),
                        boxShadow: [
                        ]),
                    child: data.avatar.isEmpty ? Container(
                      child: Text("${data.name[0]}${data.surname[0]}", style: titleBigBlueStyle).center(),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(70),
                        borderRadius:
                        BorderRadius.circular(Global.blockX * 50),
                      ),
                    ) : Container(),
//                    Image.network(data.avatar),
                  ).positionW(
                      Global.blockX * 37.5, 0, Global.blockX * 37.5, null),
                  Visibility(
                      visible: records
                          .isRecord(clientId: data.id, masterId: profile.id),
                      child: Container(
                        height: Global.blockY * 6,
                        width: Global.blockY * 6,
                          decoration: BoxDecoration(
                              color: defaultColorAccent,
                              borderRadius: defaultCircleBorderRadius),
                          child: Icon(Icons.message, color: Colors.white).center()
                              )
                      //     .onClick(() => Navigator.push(
                      //     context,
                      //     MaterialWithModalsPageRoute(
                      //         builder: (context) {
                      //           return Correspondence(
                      //               conversions.getConversion(data.id, profile.id));
                      //         }
                      //     )
                      // )
                      // )
                  ).positionW(
                      Global.blockX * 10, Global.blockX * 5, null, null)
                ]).scroll()),
          )
        ]
      )
    ).safe();
  }


}