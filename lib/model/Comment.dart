class Comment {
  int id;
  int commentatorId;
  int targetId;
  String message;
  double rate;
  DateTime date;

  Comment(this.id, this.commentatorId, this.targetId, this.message,
      this.rate, {this.date});

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    json["id"] as int,
    json["commentatorId"] as int,
    json["targetId"] as int,
    json["message"],
    json["rate"] as double,
    date: DateTime.parse(json["created_at"])
  );

  @override
  String toString() {
    return 'Comment{id: $id, commentatorId: $commentatorId, targetId: $targetId, message: $message, rate: $rate}';
  }
}

class CommentFull {
  int id;
  int commentatorId;
  int targetId;
  String commentatorName;
  String commentatorSurname;
  String commentatorAvatar;
  String message;
  double rate;
  DateTime date;

  CommentFull(
      this.id,
      this.commentatorId,
      this.targetId,
      this.commentatorName,
      this.commentatorSurname,
      this.commentatorAvatar,
      this.message,
      this.rate,
      this.date);

  @override
  String toString() {
    return 'CommentFull{id: $id, commentatorId: $commentatorId, targetId: $targetId, commentatorName: $commentatorName, commentatorSurname: $commentatorSurname, commentatorAvatar: $commentatorAvatar, message: $message, rate: $rate, date: $date}';
  }
}