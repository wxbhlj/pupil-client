import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
// 提供五套可选主题色
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
  Colors.pink,
  Colors.orange
];

class Global {
  static SharedPreferences prefs;

  static Profile profile = Profile();
  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  //初始化全局信息，会在APP启动时执行
  static Future init() async {

    prefs = await SharedPreferences.getInstance();

    var _profile = prefs.getString("_profile");

    if (_profile != null) {
 
      try {
        profile = Profile.fromJson(jsonDecode(_profile));
        print(profile.user == null?"user  null":'user not null');
        //FlutterDownloader 目前只用于android，没有配置IOS相关运行环境
        if (Platform.isAndroid) {
          WidgetsFlutterBinding.ensureInitialized();
          await FlutterDownloader.initialize();
        }
        
      } catch (e) {

        print(e);
      }
    } 
  }


  static saveProfile() =>
      prefs.setString("_profile", jsonEncode(profile.toJson()));
}