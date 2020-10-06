import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Conversion.dart';
import 'package:style_app/model/Message.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/ConversionsRepository.dart';
import 'package:style_app/ui/ProfileScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class Correspondence extends StatefulWidget {
  final Conversion conversion;
  const Correspondence(this.conversion);

  @override
  State<StatefulWidget> createState() => CorrespondenceState();
}

class CorrespondenceState extends State<Correspondence> {
  final AsyncMemoizer memoizer = AsyncMemoizer();
  TextEditingController _messageController;
  bool isLoading = false;
  bool hasMore = true;
  int page = 0;
  final int itemsPerPage = 10;
  CorrespondenceState();

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

  Future<List<Message>> loadList(ProfileProvider profile, int page, int perPage, {String filter = ""}) async {
    isLoading = true;
    var data = await ConversionsRepository.get().getMessagesByConversion(profile, widget.conversion.id, page, perPage);
    if(data.isEmpty)
      return <Message>[];
    var canSendMessages = data["canSendMessage"];
    if(canSendMessages != null) {
      if(widget.conversion.canSendMessage != canSendMessages)
        setState(() {
          widget.conversion.canSendMessage = canSendMessages;
        });
    }

    return data["messages"];
  }

  void loadListAsync(ProfileProvider profile) async {
    isLoading = true;
    ConversionsRepository.get().getMessagesByConversion(profile, widget.conversion.id, page, itemsPerPage).then((data) {
      setState(() {
        isLoading = false;
        page++;
        if(data.isNotEmpty) {
          widget.conversion.messages.clear();
          widget.conversion.messages.addAll(data["messages"]);
          hasMore = data["messages"].length <= itemsPerPage;
          var canSendMessages = data["canSendMessage"];
          if(canSendMessages != null) {
            if(widget.conversion.canSendMessage != canSendMessages)
              setState(() {
                widget.conversion.canSendMessage = canSendMessages;
              });
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final ConversionProvider conversions = Provider.of<ConversionProvider>(context);

    memoizer.runOnce(() async {
      loadListAsync(profile);
    });

    return Scaffold(
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
                    offset: Offset(0, 10)
                )
              ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(children: <Widget>[
                    Container(
                        width: Global.blockX * 8,
                        height: Global.blockX * 8,
                        child: (widget.conversion.userShort.avatar == null ? Text(
                            "${widget.conversion.userShort.name[0]} ${widget.conversion.userShort.surname[0]}",
                            style: titleBigBlueStyle) : widget.conversion.userShort.avatar.getWidget()).center(),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(Global.blockX * 10)))
                        .marginW(left: Global.blockY, right: Global.blockY),
                      Text("${widget.conversion.userShort.name} ${widget.conversion.userShort.surname}", style: titleSmallBlueStyle)
                    ]
                  )
                      .onClick(() => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          UserProfile(widget.conversion.userShort.id))
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
                onRefresh: () async {
                  if(!isLoading) {
                    var r = await loadList(profile, 0, itemsPerPage);
                    setState(() {
                      widget.conversion.messages.clear();
                      widget.conversion.messages.addAll(r);
                      hasMore = r.length >= itemsPerPage;
                      page = 1;
                      isLoading = false;
                    });
                  }
                },
                child: Container(
                  child: (widget.conversion.messages.isEmpty ?
                    CircularProgressIndicator().center() :
                    ListView.builder(
                        itemCount: widget.conversion.messages.length,
                        reverse: true,
                        itemBuilder: (c, i) {
                          if(i == 0) {
                            if(widget.conversion.lastReadMessageId != widget.conversion.messages[i].id) {
                                widget.conversion.lastReadMessageId = widget.conversion.messages[i].id;
                                widget.conversion.isRead = true;
                                ConversionsRepository.get()
                                    .read(
                                    profile,
                                    widget.conversion.id,
                                    widget.conversion.messages[i].id);
                            }
                          }
                          if(hasMore && i >= widget.conversion.messages.length - 1 && !isLoading) {
                            print("loadList 1");
                            loadList(profile, page++, itemsPerPage).then((value) {
                              setState(() {
                                isLoading = false;
                                widget.conversion.messages.addAll(value);
                                hasMore = value.length == itemsPerPage;
                              });
                            });
                            return CircularProgressIndicator().center();
                          }
                          return Container(
                            margin: EdgeInsets.only(
                              top: i == widget.conversion.messages.length - 1 ? Global.blockY * 2 : 0,
                              bottom: i == 0 ? Global.blockY * 2 : Global.blockX,
                            ),
                            child: buildWidget(widget.conversion.messages, i)
                          );
                        }
                    )
                  )
                )
              )
            ),
            Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withAlpha(30),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, -10))
                ]),
                constraints: BoxConstraints(
                    minHeight: Global.blockY * 5, maxHeight: Global.blockY * 20),
                child:
                  (widget.conversion.canSendMessage ?? false ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.camera_enhance, color: Colors.blueAccent)
                          .marginW(left: Global.blockY, right: Global.blockY * 2)
                          .onClick(() async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.getImage(source: ImageSource.gallery);
                        if(pickedFile != null) {
                          var fileName = await ConversionsRepository.get().uploadMedia(profile, File(pickedFile.path));
                          // await ConversionsRepository.get().uploadMedia(profile, File(pickedFile.path));
                          var message = Message(
                              -1,
                              widget.conversion.id,
                              profile.id,
                              fileName,
                              DateTime.now().toUtc(),
                              hasMedia: true
                          );
                          var r = await ConversionsRepository.get().sendMessage(profile, message, true);
                          if(r.id != -1) {
                            setState(() {
                              widget.conversion.messages.insert(0, message);
                              widget.conversion.lastMessage = message;
                            });
                          }
                        }
                      }
                      ),
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
                          .onClick(() async {
                        if(_messageController.text == null || _messageController.text.isEmpty)
                          return;
                        var message = Message(
                            -1,
                            widget.conversion.id,
                            profile.id,
                            _messageController.text,
                            DateTime.now().toUtc()
                        );
                        var r = await ConversionsRepository.get().sendMessage(profile, message, false);
                        if(r.id != -1) {
                          setState(() {
                            widget.conversion.messages.insert(0, message);
                            widget.conversion.lastMessage = message;
                            _messageController.text = "";
                            conversions.updateConversion(widget.conversion);
                          });
                        }
                      })
                    ],
                  ).paddingAll(Global.blockY) :
                  Text(profile.profileType == 0 ?
                  "Для отправки сообщений Вы должны быть записаны к мастеру" :
                  "Для отправки сообщений пользователь должен быть записан к Вам", style: titleSmallStyle).marginAll(Global.blockY)
                  )
            )
          ],
        )
    ).safe();
  }

  Widget buildWidget(List<Message> messages, int i) {
    var isShowTime = false;
    if(messages.length > 1) {
      if(i == 0) {
        var currDate = messages[i].createdAt;
        var nextDate = messages[i + 1].createdAt;
        isShowTime = currDate.isDateEquals(nextDate);
      } else if(i < messages.length) {
        var currDate = messages[i].createdAt;
        var prevDate = messages[i - 1].createdAt;
        isShowTime = !currDate.isTimeEquals(prevDate);
      } else isShowTime = true;
    } else isShowTime = true;
    return MessageItem(messages[i], isShowTime);
  }
}

class MessageItem extends StatelessWidget {
  final Message _message;
  final bool isShowTime;
  MessageItem(this._message, this.isShowTime);
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
                  color: _message.hasMedia ? Colors.transparent : (
                      _message.senderId != user.id  ? defaultItemColor : Colors.blueAccent
                  ),
                  borderRadius: BorderRadius.circular(10.0)
              ),
              child: _message.hasMedia ?
              Container(
                  height: Global.blockX * 35,
                  width: Global.blockX * 35,
                  child: Photo(_message.text, PhotoSource.NETWORK).getWidget()
              ).onClick(() {
              }) :
              Text("${_message.text}", style: messageItemStyle).paddingW(left: 10, top: 5, right: 10, bottom: 5),
            ),
            Visibility(
                visible: isShowTime,
                child: Text(_message.createdAt.getTime(), style: hintSmallStyle)
            )
          ],
        ).marginW(left: Global.blockX * 3, top: isShowTime ? 0 : Global.blockX, right: Global.blockX * 3)
      ],
    );
  }
}
