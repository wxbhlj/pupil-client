import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:pupil/pages/coin_change_list.dart';
import 'package:pupil/pages/coin_exchange.dart';
import 'package:pupil/pages/moon_create.dart';
import 'package:pupil/pages/setting/nickname.dart';
import 'package:pupil/pages/setting/password.dart';
import 'package:pupil/pages/setting/settings.dart';
import 'package:pupil/pages/task_assign.dart';
import 'package:pupil/pages/task_check_detail.dart';
import 'package:pupil/pages/task_check_list.dart';
import 'package:pupil/pages/task_create.dart';
import 'package:pupil/pages/task_daka.dart';
import 'package:pupil/pages/task_doit.dart';
import 'package:pupil/pages/task_edit.dart';
import 'package:pupil/pages/task_manager.dart';
import 'package:pupil/pages/task_new.dart';
import 'package:pupil/pages/task_review_detail.dart';
import 'package:pupil/pages/task_review_list.dart';
import 'package:pupil/pages/task_submitted.dart';
import 'package:pupil/pages/task_todo_list.dart';
import 'package:pupil/widgets/image_edit.dart';

import '../pages/login.dart';
import '../pages/home.dart';
import '../pages/setting/settings_theme.dart';

class Routers {
  static Router router;

  static String root = '/';
  static String loginPage = '/login';
  static String homePage = '/homePage';
  static String themeSettingPage = '/themeSettingPage';
  static String settingsPage = '/settingsPage';
  static String languageSettingPage = '/languageSettingPage';
  static String taskNewPage = '/taskNewPage';
  static String taskSubmittedPage = '/taskSubmittedPage';
  static String taskCheckListPage = '/taskCheckListPage';
  static String taskCheckDetailPage = '/taskCheckDetailPage';
  static String taskAssignPage = '/taskAssignPage';
  static String taskDoitPage = '/taskDoitPage';
  static String taskCreatePage = '/taskCreatePage';
  static String nicknameSettingPage = '/nicknameSettingPage';
  static String passwordSettingPage = '/passwordSettingPage';
  static String taskManagerPage = '/taskManagerPage';
  static String imageEditPage = '/imageEditPage';
  static String taskTodoListPage = '/taskTodoListPage';
  static String taskReviewListPage = '/taskReviewListPage';
  static String taskReviewDetailPage = '/taskReviewDetailPage';
  static String moonCreatePage = '/moonCreatePage';
  static String coinExchangePage = '/coinExchangePage';
  static String coinChangeListPage = '/coinChangeListPage';
  static String taskEditPage = '/taskEditPage';
  static String taskDakaPage = '/taskDakaPage';

  static void configRoutes(Router router) {
    Routers.router = router;
    router.notFoundHandler = new Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return Text('not found');
    });
    router.define(loginPage, handler: _buildHandler(LoginPage()));
    router.define(homePage, handler: _buildHandler(HomePage()));

    router.define(themeSettingPage, handler: _buildHandler(ThemeSettingPage()));
    router.define(taskNewPage, handler: _buildHandler(TaskNewPage()));
    router.define(taskSubmittedPage,
        handler: _buildHandler(TaskSubmittedPage()));
    router.define(settingsPage, handler: _buildHandler(SettingsPage()));

    router.define(taskCheckListPage,
        handler: _buildHandler(TaskCheckListPage()));
    router.define(taskCheckDetailPage,
        handler: _buildHandler(TaskCheckDetailPage()));
    router.define(taskAssignPage, handler: _buildHandler(TaskAssignPage()));
    router.define(taskDoitPage, handler: _buildHandler(TaskDoitPage()));
    router.define(taskCreatePage, handler: _buildHandler(TaskCreatePage()));
    router.define(nicknameSettingPage,
        handler: _buildHandler(NicknameSettingPage()));
    router.define(passwordSettingPage,
        handler: _buildHandler(PasswordSettingPage()));
    router.define(taskManagerPage, handler: _buildHandler(TaskManagerPage()));

    router.define(taskTodoListPage, handler: _buildHandler(TaskTodoListPage()));
    router.define(imageEditPage, handler: _buildHandler(ImageEditPage()));
    router.define(moonCreatePage, handler: _buildHandler(MoonCreatePage()));
    router.define(coinExchangePage, handler:_buildHandler(CoinExchangePage()));
    router.define(coinChangeListPage, handler:_buildHandler(CoinChangeListPage()));
    router.define(taskEditPage, handler:_buildHandler(TaskEditPage()));
    router.define(taskDakaPage, handler:_buildHandler(TaskDakaPage()));
    

    router.define(taskReviewDetailPage, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return TaskReviewDetailPage(params['taskId'].first);
    }));
    router.define(taskReviewListPage, handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return TaskReviewListPage(params['status'].first);
    }));
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
