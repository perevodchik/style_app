import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:style_app/model/Comment.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class Comments extends StatelessWidget {
  final UserData _masterData;
  const Comments(this._masterData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20)
              .onClick(() => Navigator.pop(context)),
              Text("Отзывы о мастере", style: titleStyle),
              Icon(Icons.arrow_back_ios, color: Colors.transparent)
            ],
          ).sizeW(Global.width, Global.blockY * 10).marginW(left: Global.blockX * 5, right: Global.blockX * 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("${_masterData.getAverageRate().toStringAsFixed(1)}/5 ", style: titleSmallStyle),
                  RatingBar(
                    itemSize: Global.blockY * 2,
                    ignoreGestures: true,
                    initialRating: _masterData.getAverageRate(),
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
              Text("Всего ${_masterData.commentsCount} отзыва", style: titleSmallBlueStyle)
            ],
          ).marginW(left: Global.blockX * 5, right: Global.blockX * 5),
          Expanded(
            child: ListView.builder(
                itemCount: _masterData.comments.length,
                itemBuilder: (context, i) => CommentPreview(_masterData.comments[i]))
          )
        ],
      ),
    ).safe();
  }
}

class CommentPreview extends StatelessWidget {
  final CommentFull comment;
  CommentPreview(this.comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 15))
          ]
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: defaultCircleBorderRadius
                      ),
                      child: Text("${comment.commentatorName[0].toUpperCase()}${comment.commentatorSurname[0].toUpperCase()}", style: titleMediumBlueStyle).center(),
                    ).sizeW(Global.blockY * 5, Global.blockY * 5).marginW(right: Global.blockY * 2),
                    Text("${comment.commentatorName} ${comment.commentatorSurname}", style: titleSmallStyle)
                  ]
                ),
                Text(comment.date.getFullDate(), style: hintExtraSmallStyle)
              ],
            ).marginW(top: Global.blockY),
            Row(
              children: <Widget>[
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
              ],
            ).marginW(top: Global.blockY, bottom: Global.blockY),
            Text(comment.message).marginW(bottom: Global.blockY)
          ],
        ).marginW(left: Global.blockY * 2, right: Global.blockY * 2)
    ).marginW(left: Global.blockX * 5, top: Global.blockY * 2, right: Global.blockX * 5);
  }
}