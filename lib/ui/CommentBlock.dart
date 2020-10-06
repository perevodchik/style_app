import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:style_app/model/Comment.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/ui/CommentsScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class CommentBlock extends StatelessWidget{
  final UserData data;
  CommentBlock(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              alignment: Alignment.bottomLeft,
              child: Text(
                  "Отзывы(${data.commentsCount})",
                  style: titleMediumStyle),
            ),
            Row(
              children: <Widget>[
                Text("Читать", style: titleSmallBlueStyle),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                ).marginW(left: Global.blockX * 2)
              ],
            ).onClick(() {
              Navigator.push(
                  context,
                  MaterialWithModalsPageRoute(
                      builder: (context) =>
                          Comments(data)));
            }).visibility(data.comments.length > 0)
          ],
        ).paddingAll(Global.blockX * 3),
        data.comments == null || data.comments.isEmpty
            ? Container(
            decoration: BoxDecoration(
              color: defaultItemColor,
              borderRadius: defaultItemBorderRadius,
            ),
            child: Text(
                "У пользователя еще нет отзывов",
                style: profileDescriptionStyle)
                .center()
                .marginW(
                top: Global.blockY * 5,
                bottom: Global.blockY * 5))
            .paddingAll(Global.blockX * 3)
            : Column(
            children: data.comments
                .sublist(0, data.comments.length > 2 ? 2 : data.comments.length)
                .map((comment) => CommentPreview(comment).marginW(bottom: Global.blockY * 2))
                .toList())
            .marginW(
            left: Global.blockX * 2.5,
            right: Global.blockX * 2.5)
      ]
    );
  }
}

class CommentPreview extends StatelessWidget {
  final CommentFull comment;
  CommentPreview(this.comment);
  @override
  Widget build(BuildContext context) {
    print(comment.toString());
    return Container(
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
                        color: Colors.white,
                        borderRadius:
                        defaultCircleBorderRadius),
                    child: (comment.commentatorAvatar == null || comment.commentatorAvatar.isEmpty ?
                    Text("${comment.commentatorName[0].toUpperCase()}${comment.commentatorSurname[0].toUpperCase()}", style: titleMediumBlueStyle) :
                    Photo(comment.commentatorAvatar, PhotoSource.NETWORK).getWidget()).center(),
                  ).sizeW(Global.blockY * 5, Global.blockY * 5).marginW(
                      top: Global.blockY,
                      right: Global.blockX * 2,
                      bottom: Global.blockY),
                  Text(
                      "${comment.commentatorName} ${comment.commentatorSurname}",
                      style: titleSmallStyle)
                ]),
                Text(comment.date.getFullDate(), style: hintExtraSmallStyle)
              ],
            ),
            Row(children: <Widget>[
              RatingBar(
                itemSize: Global.blockY * 2,
                ignoreGestures: true,
                initialRating: comment.rate,
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
            ]).marginW(bottom: Global.blockY),
            Text(comment.message, style: commentTextStyle).marginW(bottom: Global.blockY * 2)
          ],
        ).marginW(left: Global.blockY * 2, right: Global.blockY * 2));
  }
}