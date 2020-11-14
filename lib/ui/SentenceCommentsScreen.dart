import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/SentenceComment.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/SentencesRepository.dart';
import 'package:style_app/ui/ProfileScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class SentenceCommentsPage extends StatefulWidget {
  final int _status;
  final int _sentenceId;

  SentenceCommentsPage(this._status, this._sentenceId);

  @override
  State<StatefulWidget> createState() => SentenceCommentsState();
}

class SentenceCommentsState extends State<SentenceCommentsPage> {
  TextEditingController _commentController;
  final AsyncMemoizer memoizer = AsyncMemoizer();
  List<SentenceComment> comments;

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

    memoizer.runOnce(() async {
      var list = await SentencesRepository.get().sentenceCommentsBySentenceId(profile, widget._sentenceId);
      setState(() {
        comments = list;
      });
    });

    return Scaffold(
        appBar: null,
        backgroundColor: Colors.white,
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                Navigator.pop(context);
              }).marginW(left: Global.blockX * 5),
              Text(FlutterI18n.translate(context, "comments_for_sentence"), style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  var list = await SentencesRepository.get().sentenceCommentsBySentenceId(profile, widget._sentenceId);
                  if(list.isNotEmpty)
                    setState(() {
                      comments = list;
                    });
                },
                child: comments == null ?
                CircularProgressIndicator().center() :
                ListView(
                    shrinkWrap: true,
                    children: comments.map((c) => SentenceCommentItem(c)).toList()
                )
              )
          ),
          Visibility(
              // visible: true,
           visible: widget._status == 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextField(
                      minLines: 1,
                      maxLines: 3,
                      controller: _commentController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Введите текст комментария",
                          hintStyle: hintSmallStyle),
                    ).sizeW(Global.blockX * 80, Global.blockY * 10),
                    Icon(Icons.send, color: primaryColor).onClick(() async {
                      if(_commentController.text.isEmpty)
                        return;
                      var result = await SentencesRepository.get().sendSentenceComment(profile, widget._sentenceId, _commentController.text);
                      if(result != null) {
                        setState(() => comments.insert(0, result));
                        _commentController.text = "";
                      }
                    })
                  ]).marginW(
                  left: margin5,
                  right: margin5))
        ])).safe();
  }
}

class SentenceCommentItem extends StatelessWidget {
  final SentenceComment _comment;

  SentenceCommentItem(this._comment);

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
            padding: EdgeInsets.all(Global.blockY),
            decoration: BoxDecoration(
                color: profile.id == _comment.userId ? primaryColor.withOpacity(0.1) : accentColor,
                borderRadius: defaultItemBorderRadius
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text( "${_comment.userName} ${_comment.userSurname}", style: titleSmallBlueStyle)
                  .onClick(() => Navigator.push(
                      context,
                      MaterialWithModalsPageRoute(
                          builder: (c) => UserProfile(_comment.userId)
                      )
                  )
                  ),
                  Text( "${_comment.commentDate.getFullDate()}", style: hintExtraSmallStyle),
                ]
              ),
              Text(_comment.text)
            ]))
        .marginW(
            left: margin5, right: margin5, bottom: Global.blockY);
  }
}