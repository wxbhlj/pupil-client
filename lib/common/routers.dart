import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:pupil/pages/task_new.dart';
import 'package:pupil/pages/task_submitted.dart';


import '../pages/login.dart';
import '../pages/home.dart';
import '../pages/setting/theme_setting.dart';

class Routers {
  static Router router;

  static String root = '/';
  static String loginPage = '/login';
  static String homePage = '/homePage';
  static String themeSettingPage = '/themeSettingPage';
  static String languageSettingPage = '/languageSettingPage';
  static String taskNewPage = '/taskNewPage';
  static String taskSubmittedPage = '/taskSubmittedPage';

  static void configRoutes(Router router) {
    Routers.router = router;
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return Text('not found');
    });
    router.define(loginPage, handler: _buildHandler(LoginPage()));
    router.define(homePage, handler: _buildHandler(HomePage()));

    router.define(themeSettingPage, handler: _buildHandler(ThemeSettingPage()));
    router.define(taskNewPage, handler:_buildHandler(TaskNewPage()));
    router.define(taskSubmittedPage, handler:_buildHandler(TaskSubmittedPage()));
    
  }

  static Handler _buildHandler(Widget widget) {
    return Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return widget;
    });
  }
  static Future navigateTo(context, String path) {
    return router.navigateTo(context, path);
  }
}
