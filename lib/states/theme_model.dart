import 'package:flutter/material.dart';

import 'profile_model.dart';
import '../common/global.dart';

class ThemeModel extends ProfileChangeNotifier {
  // 获取当前主题，如果为设置主题，则默认使用蓝色主题
  ColorSwatch get theme => Global.themes
      .firstWhere((e) => e.value == Global.profile.theme, orElse: () => Colors.deepOrange);

  // 主题改变后，通知其依赖项，新主题会立即生效
  set theme(ColorSwatch color) {
    if (color != theme) {
      Global.profile.theme = color[500].value;
      notifyListeners();
    }
  }
}