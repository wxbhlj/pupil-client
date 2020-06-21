

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pupil/common/global.dart';



import '../widgets/list_memu_item.dart';

import '../common/routers.dart';

class HomeParentsPage extends StatefulWidget {
  @override
  _HomeParentsPageState createState() => _HomeParentsPageState();
}

class _HomeParentsPageState extends State<HomeParentsPage> {

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
        title: Text('家长中心'),
      ),
      body: Column(
        children: <Widget>[
      
          _correcting(),
          _arrangeWork(),
          _recordWork(),
          _managerWork(),
          SizedBox(
            height: ScreenUtil().setHeight(40),
          ),
          _test(),
          _settings(),


        ],
      ),

    );
  }


 

  Widget _correcting() {
    return buildListMenuItem(context, Icons.check, '检查作业', () {
      Routers.router
          .navigateTo(context, Routers.taskCheckListPage, replace: false);
    });
  }

  Widget _arrangeWork() {
    return buildListMenuItem(context, Icons.assignment, '布置作业', () {
      Routers.navigateTo(context, Routers.taskAssignPage);
    });
  }

  Widget _recordWork() {
    return buildListMenuItem(context, Icons.create, '补记作业', () {
      Routers.navigateTo(context, Routers.taskCreatePage);
    });
  }

  Widget _managerWork() {
    return buildListMenuItem(context, Icons.list, '作业列表', () {
      Routers.navigateTo(context, Routers.taskManagerPage);
    });
  }

Widget _test() {
    return buildListMenuItem(context, Icons.settings, '测试页面', () {

      Global.prefs.setInt("_attachmentId", 1);
      Global.prefs.setString("_attachmentUrl", "http://img.shellsports.cn/58-HEADER-1592472113957.png");
      Routers.router
          .navigateTo(context, Routers.imageEditPage , replace: false);
    });
  }

   Widget _settings() {
    return buildListMenuItem(context, Icons.settings, '系统设置', () {
      Routers.router
          .navigateTo(context, Routers.settingsPage, replace: false);
    });
  }


}
