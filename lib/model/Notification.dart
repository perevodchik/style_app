class Notification {
  int id;
  int reason;
  int masterId;
  int clientId;
  int recordId;
  String firstDate;
  String secondDate;

  Notification(this.id, this.reason, this.masterId, this.clientId, this.firstDate, {this.secondDate});
}

class Notifications {
  static List<Notification> notifications = [
    Notification(1, 1, 113, 0, "10:00 22.12.2012"),
    Notification(2, 1, 113, 0,  "10:00 22.12.2012"),
    Notification(3, 2, 113, 1,  "10:00 22.12.2012"),
    Notification(4, 3, 113, 2,  "10:00 22.12.2012", secondDate: "14:00 22.12.2012"),
    Notification(5, 0, 113, 1,  "10:00 22.12.2012"),
    Notification(6, 0, 113, 2,  "10:00 22.12.2012"),
  ];
}