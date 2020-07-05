
import 'package:flutter/material.dart';

class Utils {

  static bool isPhoneNumber(String str) {
    return new RegExp(
            '^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$')
        .hasMatch(str);
  }

  //yyyy-MM-dd HH:mm
  static String formatDate(int time) {
    if (time == null) {
      return "";
    } else {
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(time);
      return "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
  }
  //HH:mm
  static String formatDate4(int time) {
    if (time == null) {
      return "";
    } else {
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(time);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
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
  
  static Color fanse(Color color) {
    return Color.fromRGBO(255 - color.red, 255 - color.green, 255 - color.blue, 1);
  }
  static Color courseColor(double val) {
    if(val >= 4.5) {
      return Colors.lightGreen;
    } if(val >= 4) {
      return Colors.green;
    } if(val >= 3) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static String twoDigits2(int n) {
      if (n >= 10) return "$n";
      return "0$n";
  }
  static String formatTime(int seconds) {
    return twoDigits2(seconds~/60) + ":" + twoDigits2(seconds%60);
  }

  static String translate(String course) {
    if(course == '语文') {
      return 'chinese';
    } else if(course == '数学') {
      return 'math';
    } if(course == '英语') {
      return 'english';
    } else {
      return 'logo';
    }
  }

  static Widget buildStatus(String status) {
    Widget text;
    if (status == 'CHECKED') {
      text = Text('已批改', style: TextStyle(color: Colors.green, fontSize: 10));
    } else if (status == 'ASSIGNED') {
      text = Text('未完成', style: TextStyle(color: Colors.red, fontSize: 10));
    } else if (status == 'UPLOAD') {
      text = Text('待批改', style: TextStyle(color: Colors.black, fontSize: 10));
    } else if(status == 'REVIEWED'){
      text =
          Text('复习一遍', style: TextStyle(color: Colors.lightGreen, fontSize: 10));
    } else {
      text =
          Text('复习两遍', style: TextStyle(color: Colors.greenAccent, fontSize: 10));
    }
    return text;
  }


  static String formatDate3(int time) {
    if (time == null) {
      return "";
    } else {
      DateTime today = DateTime.now();
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(time);
      Duration du = today.difference(date);
      if(today.year == date.year && today.month == date.month && today.day == date.day ) {
     
          return "今天";
   
      } else if(du.inDays == 0) {
     
          return "昨天";
   
      } else if(du.inDays < 5) {
     
          return "${du.inDays +1}天前";
   
      } else {
        return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
      
    }
  }
}
