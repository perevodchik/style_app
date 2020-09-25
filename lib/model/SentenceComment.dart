class SentenceComment {
  int id;
  int sentenceId;
  int userId;
  String userName;
  String userSurname;
  String userAvatar;
  String text;
  DateTime commentDate;

  SentenceComment(this.id, this.sentenceId, this.userId, this.userName,
      this.userSurname, this.userAvatar, this.text, this.commentDate);

  factory SentenceComment.fromJson(Map<String, dynamic> json) => SentenceComment(
    json["id"],
    json["sentenceId"],
    json["userId"],
    json["userName"],
    json["userSurname"],
    json["userAvatar"],
    json["message"],
    DateTime.parse(json["createAt"]) ?? DateTime.now(),
  );

  @override
  String toString() {
    return 'SentenceComment{id: $id, sentenceId: $sentenceId, userId: $userId, userName: $userName, userSurname: $userSurname, userAvatar: $userAvatar, text: $text, commentDate: $commentDate}';
  }
}