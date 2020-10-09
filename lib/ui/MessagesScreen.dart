import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:style_app/holders/ConversionsHolder.dart';
import 'package:style_app/holders/NotificationsHolder.dart';
import 'package:style_app/model/Conversion.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/ConversionsRepository.dart';
import 'package:style_app/service/NotificationRepository.dart';
import 'package:style_app/ui/CorrespondenceScreen.dart';
import 'package:style_app/ui/ProfileScreen.dart';
import 'package:style_app/ui/OrderPageScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';
import 'package:style_app/model/Notification.dart' as notify;

class Messages extends StatefulWidget {
  const Messages();

  @override
  State<StatefulWidget> createState() => MessagesState();
}

class MessagesState extends State<Messages> {
  bool _isFirst = true;
  List<Widget> screens = [const Inbox(), const NotificationsScreen()];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Container(
                child: Text("Сообщения", style: titleStyle),
              ).marginW(top: Global.blockY * 2, bottom: Global.blockY * 2),
              Row(
                children: <Widget>[
                  Container(
                    width: Global.blockX * 45,
                    child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            if (!_isFirst) _isFirst = true;
                          });
                        },
                        child: Text("Диалоги"),
                        textColor: _isFirst ? Colors.white : Colors.black,
                        color: _isFirst ? Colors.blueAccent : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50),
                                bottomLeft: Radius.circular(50)))),
                  ),
                  Container(
                    width: Global.blockX * 45,
                    child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            if (_isFirst) _isFirst = false;
                          });
                        },
                        child: Text("Уведомления"),
                        textColor: !_isFirst ? Colors.white : Colors.black,
                        color: !_isFirst ? Colors.blueAccent : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(50),
                                bottomRight: Radius.circular(50)))),
                  )
                ],
              ).marginW(left: Global.blockX * 5, right: Global.blockX * 5)
            ],
          ),
        ),
        Expanded(
          child: Container(
            child: _isFirst ? screens[0] : screens[1],
          )
        )
      ],
    ).background(Colors.white);
  }
}

class Inbox extends StatefulWidget {
  const Inbox();

  @override
  State<StatefulWidget> createState() => InboxState();
}

class InboxState extends State<Inbox> {
  @override
  Widget build(BuildContext context) {
    final ConversionProvider conversions = Provider.of<ConversionProvider>(context);
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    ConversionsHolder.memoizer.runOnce(() async {
      var list = await ConversionsRepository.get().getConversions(profile);
      conversions.conversions = list;
    });
    if (conversions.conversions.isEmpty) {
      return Container(
        child: Text(
          "У Вас пока еще нету сообщений",
          style: titleSmallStyle,
        ).center(),
      );
    } else
      return Column(
        children: [
          Expanded(
              child: RefreshIndicator(
                  onRefresh: () async {
                    var list = await ConversionsRepository.get().getConversions(profile);
                    conversions.conversions = list;
                  },
                  child: ListView(
                      children: conversions.conversions
                          .map((conversion) => conversion.lastMessage.id == -1 ? Container() : ConversionPreview(conversion)
                          .onClick(() async {
                        if(conversion.messages.length > 0) {
                          if (conversion.lastReadMessageId != conversion
                              .messages[0].id) {
                            setState(() {
                              conversion.lastReadMessageId =
                                  conversion.messages[0].id;
                              conversion.isRead = true;
                              conversions.updateConversion(conversion);
                              ConversionsRepository.get()
                                  .read(
                                  profile,
                                  conversion.id,
                                  conversion.messages[0].id);
                            });
                          }
                        } else {
                          if(conversion.lastMessage.id > 0) {
                            setState(() {
                              conversion.lastReadMessageId =
                                  conversion.lastMessage.id;
                              conversion.isRead = true;
                              conversions.updateConversion(conversion);
                              ConversionsRepository.get()
                                  .read(
                                  profile,
                                  conversion.id,
                                  conversion.lastMessage.id);
                            });
                          }
                        }
                        print("open conversion ${conversion.toString()}");
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Correspondence(conversion)));
                        if (result == "refresh") setState(() {});
                      }).marginW(top: Global.blockY)
                      ).toList()
                  )
              )
          )
        ]
      );
  }
}

class ConversionPreview extends StatelessWidget {
  final Conversion conversion;

  ConversionPreview(this.conversion);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom: Global.blockY * 1.5,
          left: Global.blockX * 5,
          right: Global.blockX * 5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: conversion.isRead ? Colors.grey.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 1))
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Container(
            width: Global.blockX * 15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Global.blockX * 50),
            ),
            child: (conversion.userShort.avatar == null ? Text(
                "${conversion.userShort.name[0]} ${conversion.userShort.surname[0]}",
                style: titleBigBlueStyle) : conversion.userShort.avatar.getWidget())
                .center()),
        trailing: Text(conversion.getLastMessageTime()),
        title: Text("${conversion.userShort.name} ${conversion.userShort.surname}",
            style: titleMediumBlueStyle),
        subtitle: Text(
            conversion.lastMessage.hasMedia ? "Фото" :
            "${conversion.lastMessage.text}",
            style: hintSmallStyle),
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen();

  @override
  State<StatefulWidget> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return FutureBuilder(
      future: NotificationRepository.get().getNotifications(profile),
      builder: (c, s) {
       print("${s.connectionState} ${s.hasData} ${s.hasError} ${s.data} ${s.error}");
       if(s.connectionState == ConnectionState.done && s.hasData && !s.hasError) {
         NotificationsHolder.notifications.clear();
         NotificationsHolder.notifications.addAll(s.data);
         if(NotificationsHolder.notifications.isEmpty) {
           return Text("У Вас пока еще нету уведомлений",
               style: titleSmallStyle).center();
         } else
         return ListView.builder(
           shrinkWrap: true,
           itemCount: NotificationsHolder.notifications.length,
           itemBuilder: (c, i) {
             return buildWidget(NotificationsHolder.notifications, i);
           }
         );
       } else return CircularProgressIndicator().center();
      }
    );
  }

  Widget buildWidget(List<notify.Notification> notifications, int i) {
    var isShowDate = false;
    if(notifications.length > 1) {
      if(i == 0) {
        var currDate = notifications[i].createdAt;
        var nextDate = notifications[i + 1].createdAt;
        isShowDate = currDate.isDateEquals(nextDate);
      } else if(i < notifications.length) {
        var currDate = notifications[i].createdAt;
        var prevDate = notifications[i - 1].createdAt;
        isShowDate = !currDate.isDateEquals(prevDate);
      } else isShowDate = true;
    } else isShowDate = true;

    return NotificationPreview(notifications[i], isShowDate);
  }
}

class NotificationPreview extends StatelessWidget {
final notify.Notification _notification;
final bool isShowDate;

NotificationPreview(this._notification, this.isShowDate);

@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      (isShowDate ? Container(
        margin: EdgeInsets.only(top: Global.blockY * 2),
        child: Text("${_notification.createdAt.getDate()}", style: hintSmallStyle)
      ) : Container()),
      Container(
          padding: EdgeInsets.all(Global.blockX),
          decoration: BoxDecoration(
              color: !_notification.isDirty ?
              defaultColorAccent.withOpacity(0.02) :
              defaultItemColor,
              borderRadius: defaultItemBorderRadius),
          child: RichText(
              textDirection: TextDirection.ltr,
              text: TextSpan(
                  children: getText(context),
                  style: TextStyle(fontSize: 10)))
      ),
      // Text("${_notification.createdAt.getDate()}", style: errorStyle)
    ]
  ).marginW(
      left: Global.blockX * 5,
      top: Global.blockX,
      right: Global.blockX * 5,
      bottom: Global.blockY);
}

List<TextSpan> getText(context) {
  List<TextSpan> widgets = [];
  switch(_notification.notificationType) {
    case 0:
      widgets.add(TextSpan(text: "Пользователь ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.secondUser.name} ${_notification.secondUser.surname}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => UserProfile(_notification.secondUser.id)
              )
          )));
      widgets.add(TextSpan(text: " добавил о Вас отзыв. ", style: hintSmallStyle));
      break;
    case 1:
      widgets.add(TextSpan(text: "Пользователь ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.secondUser.name} ${_notification.secondUser.surname}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => UserProfile(_notification.secondUser.id)
              )
          )));
      widgets.add(TextSpan(text: " предложил Вам стать исполнителем в заказе ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.order.name}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => OrderPage(_notification.order.id)
              )
          )));
      widgets.add(TextSpan(text: ".", style: hintSmallStyle));
      break;
    case 2:
      widgets.add(TextSpan(text: "Заказ ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.order.name}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => OrderPage(_notification.order.id)
              )
          )));
      widgets.add(TextSpan(text: " был отменен клиентом. ", style: hintSmallStyle));
      break;
    case 3:
      widgets.add(TextSpan(text: "Заказ ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.order.name}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => OrderPage(_notification.order.id)
              )
          )));
      widgets.add(TextSpan(text: " был отменен мастером. ", style: hintSmallStyle));
      break;
    case 4:
      widgets.add(TextSpan(text: "Пользователь ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.secondUser.name} ${_notification.secondUser.surname}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => UserProfile(_notification.secondUser.id)
              )
          )));
      widgets.add(TextSpan(text: " завершил заказ ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.order.name}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => OrderPage(_notification.order.id)
              )
          )));
      widgets.add(TextSpan(text: ". ", style: hintSmallStyle));
      break;
    case 6:
      widgets.add(TextSpan(text: "Мастер ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.secondUser.name} ${_notification.secondUser.surname}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => UserProfile(_notification.secondUser.id)
              )
          )));
      widgets.add(TextSpan(text: " принял заказ ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.order.name}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => OrderPage(_notification.order.id)
              )
          )));
      widgets.add(TextSpan(text: ". ", style: hintSmallStyle));
      break;
    case 7:
      widgets.add(TextSpan(text: "В заказе ", style: hintSmallStyle));
      widgets.add(TextSpan(text: "${_notification.order.name}",
          style: titleSmallBlueStyle,
          recognizer: new TapGestureRecognizer()..onTap = () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => OrderPage(_notification.order.id)
              )
          )
      ));
      widgets.add(TextSpan(text: " новое предложение.", style: hintSmallStyle));
      break;
    default:
      widgets.add(TextSpan(text: _notification.toString(), style: hintSmallStyle));
      break;
  }
  return widgets;
}
}