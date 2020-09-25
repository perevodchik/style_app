class Time {
  String hour;
  String minute;

  Time(this.hour, this.minute);

  int getHour() {
    return int.parse(hour);
  }

  int getMinute() {
    return int.parse(minute);
  }

  @override
  String toString() {
    return "$hour:$minute";
  }
}