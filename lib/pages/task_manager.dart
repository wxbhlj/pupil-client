import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/common/utils.dart';
import 'package:pupil/pages/task_manager_tabview.dart';
import 'package:pupil/widgets/dialog.dart';

class TaskManagerPage extends StatefulWidget {
  @override
  _TaskManagerPageState createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage>  with SingleTickerProviderStateMixin{
  var _eventSubscription;

  TabController _tabController;

  @override
  void initState() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("onEvent:" + event.eventType);
      if (event.eventType == EVENT_REFRESH_CHECKLIST) {
        setState(() {});
      }
    });
    _tabController = new TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('作业管理'),
        bottom: TabBar(
          onTap: (int index){
                print('Selected......$index');
              },
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: '语文'),
            Tab(text: '数学'),
            Tab(text: '英语'),
            Tab(text: '其它'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          TaskManagerTabviewPage('语文'),
          TaskManagerTabviewPage('数学'),
          TaskManagerTabviewPage('英语'),
          TaskManagerTabviewPage('其它'),
        ],
      ),
    );
  }


 
  
}
