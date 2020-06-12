import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';

import 'home_index_chart.dart';

class HomeIndexPage extends StatefulWidget {
  @override
  _HomeIndexPageState createState() => _HomeIndexPageState();
}

class _HomeIndexPageState extends State<HomeIndexPage>
    with SingleTickerProviderStateMixin {
  
  var tasks;
  var _eventSubscription;

  @override
  void initState() {
    super.initState();
    _registerEvent();
    _refreshTodoList();
  }
  _refreshTodoList() {
    _getData().then((resp) {
      setState(() {
        tasks = resp['data'];
        print(tasks);
      });
    });
  }

  _registerEvent() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("onEvent:" + event.eventType);
      if (event.eventType == EVENT_REFRESH_TODOLIST) {
        _refreshTodoList();
      }
    });
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
        title: Text(Global.profile.user.nick),
      ),
      body: Column(
        children: <Widget>[
          LineChartWidget(),
          Container(
            margin: EdgeInsets.only(left: 15, top: 20),
            alignment: Alignment.topLeft,
            child: Text(
              '今日作业',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2),
            ),
          ),
          Expanded(
            child: _buildTaskList(),
          )
          //(),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if(tasks == null) {
      return Text('');
    }
    return Container(
      width: ScreenUtil().setWidth(750),
      child: ListView.separated(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          var item = tasks[index];
          return ListTile(
            title: Text(
              item['title'],
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(item['course']),
            onTap: () {
              Global.prefs.setInt("_taskId", item['id']);
              Global.prefs.setString("_taskTitle", item['title']);
              Routers.navigateTo(context, Routers.taskDoitPage);
            },
            trailing: Icon(Icons.keyboard_arrow_right),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return new Divider(
            height: 0,
            color: Colors.grey[300],
          );
        },
      ),
    );
  }

   Future _getData() async {
    
    return HttpUtil.getInstance()
        .get("api/v1/ums/task/list?status=ASSIGNED&userId=" + Global.profile.user.userId.toString(), );
  }

 

  
}
