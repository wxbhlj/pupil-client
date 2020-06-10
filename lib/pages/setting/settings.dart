import 'dart:io';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:pupil/common/global.dart';

import '../../widgets/list_memu_item.dart';
import '../../widgets/dialog.dart';
import '../../states/user_model.dart';
import '../../common/routers.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () async {
              showConfirmDialog(context, '确定要退出吗', () {
                Provider.of<UserModel>(context, listen: false).user = null;
                exit(0);
              });
            },
            //backgroundColor: Colors.green,
            label: Text(''),
            icon: Icon(
              Icons.exit_to_app,
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
      
          _themeColor(),

          _nickSetting(),
        ],
      ),

    );
  }


 

  Widget _themeColor() {
    return buildListMenuItem(context, Icons.color_lens, '主题颜色', () {
      Routers.router
          .navigateTo(context, Routers.themeSettingPage, replace: false);
    });
  }


  Widget _nickSetting() {
    return buildListMenuItem(context, Icons.person, Global.profile.user.nick, () {
      //Routers.router
      //    .navigateTo(context, Routers.languageSettingPage, replace: false);
    });
  }

}
