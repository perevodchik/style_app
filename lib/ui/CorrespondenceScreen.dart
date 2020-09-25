import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Conversion.dart';
import 'package:style_app/model/Message.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/MastersProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/MastersRepository.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/MasterProfileScreen.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class Correspondence extends StatefulWidget {
  final Conversion conversion;
  const Correspondence(this.conversion);

  @override
  State<StatefulWidget> createState() => CorrespondenceState(conversion);
}

class CorrespondenceState extends State<Correspondence> {
  final Conversion conversion;
  TextEditingController _messageController;
  CorrespondenceState(this.conversion);

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider user = Provider.of<ProfileProvider>(context);
    final ConversionProvider conversions = Provider.of<ConversionProvider>(context);
    final MastersRepository masterService = MastersRepository();

    var data = user.profileType == 0 ?
        masterService.getMasterById(conversion.masterId) : masterService.getClientById(conversion.clientId);
    var avatar = data.avatar.isEmpty ? "${data.name[0]}${data.surname[0]}" : data.avatar;
    var title = data.getNames();

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future<bool>.value(false);
      },
      child: Scaffold(
          appBar: null,
          backgroundColor: Colors.white,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withAlpha(30),
                      spreadRadius: 2,
                      blurRadius: 15,
                      offset: Offset(0, 10))
                ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Container(
                          width: Global.blockX * 8,
                          height: Global.blockX * 8,
                          child: Text(avatar, style: titleSmallBlueStyle).center(),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(Global.blockX * 10)))
                          .marginW(left: Global.blockY, right: Global.blockY),
                      Text(title, style: titleSmallBlueStyle)
                    ])
                        .onClick(() => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            UserProfile(conversion.masterId))
                    )
                    ),
                    Icon(Icons.close).marginW(right: Global.blockY)
                        .onClick(() => Navigator.pop(context))
                  ],
                )
                    .sizeW(Global.width, Global.blockY * 5)
                    .paddingAll(Global.blockY),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {},
                  child: Container(
                    constraints: BoxConstraints(
                    ),
                    child: ListView.builder(
                        itemCount: conversion.messages.length,
                        reverse: true,
                        itemBuilder: (c, i) {
                          return MessageItem(conversion.messages[i]);
                        }
                    ),
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withAlpha(30),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, -10))
                  ]),
                  width: Global.blockX * 100,
                  constraints: BoxConstraints(
                      minHeight: Global.blockY * 5, maxHeight: Global.blockY * 20),
                  child:
//                  RecordsService().isRecordToMaster(user.id, profile.id) ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.camera_enhance, color: Colors.blueAccent)
                          .marginW(left: Global.blockY, right: Global.blockY * 2)
                      .onClick(() async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.getImage(source: ImageSource.gallery);
                        if(pickedFile != null) {
                          var message = Message(Random().nextInt(9999), conversion.id, user.id, "");
                          message.hasMedia = true;
                          message.media = File(pickedFile.path);
                          print("send ${message.toString()}");
                          conversions.sendMessage(conversion, message);
                        }
                      }),
                      Container(
                        width: Global.blockX * 70,
                        decoration: BoxDecoration(),
                        child: TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 3,
                          maxLengthEnforced: true,
                        ),
                      ),
                      Icon(Icons.send, color: Colors.blueAccent)
                          .marginW(right: Global.blockY)
                          .onClick(() {
                        print("null? ${_messageController.text == null}");
                        print("empty? ${_messageController.text.isEmpty}");
                        if(_messageController.text == null || _messageController.text.isEmpty)
                          return;
                        var message = Message(
                            Random().nextInt(11111),
                            widget.conversion.id,
                            user.id,
                            _messageController.text
                        );
                        _messageController.text = "";
                        conversions.sendMessage(conversion, message);
                      })
                    ],
                  ).paddingAll(Global.blockY)
//                      : Text("Для отправки сообщений Вы должны быть записаны к данному мастеру", style: titleSmallStyle).marginAll(Global.blockY)
              )
            ],
          )
      ).safe(),
    );
  }
}

class MessageItem extends StatelessWidget {
  final Message _message;
  MessageItem(this._message);
  @override
  Widget build(BuildContext context) {
    final ProfileProvider user = Provider.of<ProfileProvider>(context);
            return Row(
                mainAxisAlignment: _message.senderId != user.id ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: <Widget>[
                  Wrap(
                    crossAxisAlignment: _message.senderId != user.id ? WrapCrossAlignment.start : WrapCrossAlignment.end,
                    direction: Axis.vertical,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            color: _message.senderId != user.id ? Colors.grey.withOpacity(0.2) : Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: _message.hasMedia ?
                        Container(
                          height: Global.blockX * 20,
                          width: Global.blockX * 20,
                          child: Image.file(_message.media),
                        ).onClick(() {
                          Navigator.push(
                              context,
                              MaterialWithModalsPageRoute(
                                builder: (c) => ImageFilePage([_message.media])
                              )
                          );
                        }) :
                        Text("${_message.text}").paddingAll(5),
                      ),
                      Text("${DateTime.now().hour}:${DateTime.now().minute}", style: serviceSubtitleStyle)
                    ],
                  ).marginW(left: Global.blockX * 2, right: Global.blockX * 2)
                ],
            );
  }
}
