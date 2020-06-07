
class Utils {

  static bool isPhoneNumber(String str) {
    return new RegExp(
            '^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$')
        .hasMatch(str);
  }

  static String formatDate(int time) {
    if (time == null) {
      return "";
    } else {
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(time);
      return "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
  }

  static String formatDate2(int time) {
    if (time == null) {
      return "";
    } else {
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(time);
      return "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

  static String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
  }


  static String formatDate3(int time) {
    if (time == null) {
      return "";
    } else {
      DateTime today = DateTime.now();
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(time);
      if(today.year == date.year && today.month == date.month && today.day == date.day ) {
     
          return "今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
   
      } else {
        return "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      }
      
    }
  }
}
