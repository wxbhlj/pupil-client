
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pupil/common/routers.dart';

class TaskSubmittedPage extends StatefulWidget {
  @override
  _TaskSubmittedPageState createState() => _TaskSubmittedPageState();
}

class _TaskSubmittedPageState extends State<TaskSubmittedPage> {

  List prizes = List();
  Timer _countdownTimer;
  int _select = -1;
  List cycle = [0, 1, 2, 4, 7, 6, 5, 3];
  int times = 0;

  @override
  void initState() {
    prizes.add({"coins":1, "title":'1个金币', "ratio":800});
    prizes.add({"coins":1, "title":'乌龟一只', "ratio":800});
    prizes.add({"coins":1, "title":'5个金币', "ratio":800});
    prizes.add({"coins":1, "title":'金鱼一条', "ratio":800});
    prizes.add({"coins":1, "title":'10个金币', "ratio":800});
    prizes.add({"coins":1, "title":'娱乐10分钟', "ratio":20});
    prizes.add({"coins":1, "title":'20个金币', "ratio":800});
    prizes.add({"coins":1, "title":'两手空空', "ratio":20});
    super.initState();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: Center(
        child: Wrap(
          children: _buildPrizes(),
        ),),
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  List<Widget> _buildPrizes() {
    List<Widget> list = List();
    int idx = 0;
    for(var item in prizes) {
      var widget = Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setHeight(165),
      
        decoration: new BoxDecoration(
        //背景
        color: idx == _select?Colors.red:Colors.blue,
        //设置四周圆角 角度
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //设置四周边框
        border: Border.all(width: 1, color: Colors.blue),
        ),
        child: Center(
          child: Text(item['title'],  style: TextStyle(color: Colors.white60),),
        ),
      );
      list.add(widget);
      idx ++;
    }
    list.insert(4, _buildStartButton());
    return list;
  }

  Widget _buildStartButton() {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setHeight(165),
      
        decoration: new BoxDecoration(
        //背景
        color: Colors.orange[300],
        //设置四周圆角 角度
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //设置四周边框
        border: new Border.all(width: 1, color: Colors.blue),
        ),
        child: Center(
          child: Text('点击抽奖', style: TextStyle(color: Colors.white),),
        ),
      ),
      onTap: () {
        _start();
      },
    );
  }

  _start () {
    times = 0;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _countdownTimer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
      times ++;
      _select = cycle[times %8];
      if(times > 50) {
        _countdownTimer?.cancel();
    _countdownTimer = null;
      }
      setState(() {
        
      });
      
    });
  
  }



  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(230),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          
          OutlineButton(
            child: Text('休息一下'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          RaisedButton(
            color: Theme.of(context).accentColor,
            child: Text('继续作业'),
            onPressed: () {
              Routers.router.navigateTo(context, Routers.taskNewPage, replace: true);
            },
          )
        ],
      ),
    );
  }
}
