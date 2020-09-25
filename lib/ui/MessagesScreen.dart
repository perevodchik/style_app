import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Conversion.dart';
import 'package:style_app/model/Notification.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/MastersProvider.dart';
import 'package:style_app/providers/MessagesProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/MastersRepository.dart';
import 'package:style_app/ui/CorrespondenceScreen.dart';
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
        Container(
          child: _isFirst ? screens[0] : screens[1],
        ).sizeW(Global.width, Global.blockY * 73)
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
    if (conversions.conversions
        .where((conversion) {
          print("$conversion => isNotEmpty? ${conversion.messages.length}");
          return conversion.messages.isNotEmpty;
        }).toList(growable: false).isEmpty) {
      return Container(
        child: Text(
          "У Вас пока еще нету сообщений",
          style: titleSmallStyle,
        ).center(),
      );
    } else
      return ListView(
        children: conversions.conversions
            .where((conversion) => conversion.messages.isNotEmpty)
            .map((conversion) => ConversionPreview(conversion)
            .onClick(() async {
              var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Correspondence(conversion)));
              if (result == "refresh") setState(() {});
              }).marginW(top: Global.blockY)
            )
            .toList()
      );
  }
}

class ConversionPreview extends StatelessWidget {
  final Conversion _conversion;

  ConversionPreview(this._conversion);

  @override
  Widget build(BuildContext context) {
    final ConversionProvider conversion = Provider.of<ConversionProvider>(context);
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);

    print("build for conversion [$_conversion]");

    return Container(
      margin: EdgeInsets.only(
          bottom: Global.blockY * 1.5,
          left: Global.blockX * 5,
          right: Global.blockX * 5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
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
            child: Text(
                    "SV",
                    style: titleBigBlueStyle)
                .center()),
        title: Text("Valerij Meladze",
            style: previewNameStyle),
        subtitle: Text(
            conversion.getLastMessageFromConversion(_conversion.id).hasMedia ? "Фото" :
            "${conversion.getLastMessageFromConversion(_conversion.id).text}",
            style: previewRateStyle),
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
  Widget build(BuildContext context) {
    if (Notifications.notifications.isEmpty) {
      return Container(
        child: Text(
          "У Вас пока еще нету уведомлений",
          style: titleSmallStyle,
        ).center(),
      );
    } else
      return ListView.builder(
          itemCount: Notifications.notifications.length,
          itemBuilder: (c, i) {
            return NotificationPreview(Notifications.notifications[i])
                .onClick(() {})
                .marginW(top: Global.blockY * (i == 0 ? 2 : 0));
          });
  }
}

class NotificationPreview extends StatelessWidget {
  final notify.Notification _notification;

  NotificationPreview(this._notification);

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: EdgeInsets.all(Global.blockX),
            decoration: BoxDecoration(
                color: defaultItemColor,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: RichText(
                textDirection: TextDirection.ltr,
                text: TextSpan(
                    style: TextStyle(fontSize: 20), children: getText())))
        .marginW(
            left: Global.blockX * 5,
            top: Global.blockX,
            right: Global.blockX * 5,
            bottom: Global.blockY);
  }

  List<TextSpan> getText() {
    List<TextSpan> widgets = [];
    var masterData = MastersRepository().findById(_notification.masterId);
    if (masterData == null) {
      return widgets;
    }
    if (_notification.reason == 0) {
      widgets.add(TextSpan(text: "Вы записаны у ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${masterData.name} ${masterData.surname}",
          style: previewRateStyle));
      widgets.add(TextSpan(text: " на ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${_notification.firstDate}", style: titleSmallBlueStyle));
    } else if (_notification.reason == 1) {
      widgets
          .add(TextSpan(text: "Ваша запись у мастера ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${masterData.name} ${masterData.surname}",
          style: previewRateStyle));
      widgets.add(TextSpan(text: " завершена в ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${_notification.firstDate}", style: titleSmallBlueStyle));
    } else if (_notification.reason == 2) {
      widgets
          .add(TextSpan(text: "Ваша запись у мастера ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${masterData.name} ${masterData.surname}",
          style: previewRateStyle));
      widgets.add(TextSpan(text: " на ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${_notification.firstDate}", style: titleSmallBlueStyle));
      widgets.add(TextSpan(text: " отменена", style: hintSmallStyle));
    } else if (_notification.reason == 3) {
      widgets
          .add(TextSpan(text: "Ваша запись у мастера ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${masterData.name} ${masterData.surname}",
          style: previewRateStyle));
      widgets.add(TextSpan(text: " перенесена с ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${_notification.firstDate}", style: titleSmallBlueStyle));
      widgets.add(TextSpan(text: " на ", style: hintSmallStyle));
      widgets.add(TextSpan(
          text: "${_notification.secondDate}", style: titleSmallBlueStyle));
    }
    return widgets;
  }
}
