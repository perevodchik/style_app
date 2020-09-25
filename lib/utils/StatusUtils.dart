class StatusUtils {
  static String getStatus(int status) {
    if(status == 0)
      return "В ожидании";
    else if(status == 1)
      return "Завершен";
    else if(status == 2)
      return "В процессе";
    else if(status == 3)
      return "Ожидает подтверждения";
    else if(status == 4)
      return "Отменен";
    return "---";
  }
}