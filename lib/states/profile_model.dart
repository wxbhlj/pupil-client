import 'dart:convert';

import 'package:flutter/material.dart';
import '../common/global.dart';
import '../models/profile.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    print("save profile");
    print(jsonEncode(_profile.toJson()));
    Global.saveProfile(); //保存Profile变更
    super.notifyListeners(); //通知依赖的Widget更新
  }
}