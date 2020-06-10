

import 'package:flutter/material.dart';



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
        title: Text('家长操作'),
      ),
      body: Column(
        children: <Widget>[
      
          _correcting(),
          _exam(),
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

  Widget _exam() {
    return buildListMenuItem(context, Icons.assignment, '布置作业', () {
      Routers.navigateTo(context, Routers.taskAssignPage);
    });
  }

   Widget _settings() {
    return buildListMenuItem(context, Icons.settings, '系统设置', () {
      Routers.router
          .navigateTo(context, Routers.settingsPage, replace: false);
    });
  }


}
