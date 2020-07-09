import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';

class TaskSubmittedPage extends StatefulWidget {
  @override
  _TaskSubmittedPageState createState() => _TaskSubmittedPageState();
}

class _TaskSubmittedPageState extends State<TaskSubmittedPage> {
  List prizes = List();
  Timer _countdownTimer;
  int _select = -1;
  int prize = 0;
  List cycle = [0, 1, 2, 4, 7, 6, 5, 3];
  int times = 0;

  @override
  void initState() {
    prizes.add({"coins": 1, "title": '1个金币', "ratio": 40});
    prizes.add({"coins": 0, "title": '两手空空', "ratio": 10});
    prizes.add({"coins": 2, "title": '2个金币', "ratio": 15});
    prizes.add({"coins": 0, "title": '继续加油', "ratio": 10});

    prizes.add({"coins": 0, "title": '继续加油', "ratio": 10});
    prizes.add({"coins": 5, "title": '5个金币', "ratio": 4});

    prizes.add({"coins": 0, "title": '两手空空', "ratio": 10});
    prizes.add({"coins": 10, "title": '10个金币', "ratio": 1});
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
      body: Stack(
        children: <Widget>[
          Center(
            child: Wrap(
              children: _buildPrizes(),
            ),
          ),
          Positioned(
            width: ScreenUtil().setWidth(750),
            top: ScreenUtil().setHeight(150),
            child: Center(
              child: Text(
                '恭喜你完成作业',
                style: TextStyle(fontSize: 32),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  List<Widget> _buildPrizes() {
    List<Widget> list = List();
    int idx = 0;
    for (var item in prizes) {
      var widget = Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setWidth(165),
        decoration: new BoxDecoration(
          //背景
          color: idx == _select ? Colors.red : Colors.blue,
          //设置四周圆角 角度
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          //设置四周边框
          border: Border.all(width: 1, color: Colors.white),
        ),
        child: Center(
          child: Text(
            item['title'],
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
      list.add(widget);
      idx++;
    }
    list.insert(4, _buildStartButton());
    return list;
  }

  Widget _buildStartButton() {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setWidth(165),
        decoration: new BoxDecoration(
          //背景
          color: times == 0 ? Colors.orange[300] : Colors.grey,
          //设置四周圆角 角度
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          //设置四周边框
          border: new Border.all(width: 1, color: Colors.white),
        ),
        child: Center(
          child: Text(
            '点击抽奖',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      onTap: () {
        if (times == 0) {
          _start();
        } else {
          Fluttertoast.showToast(
              msg: '每完成一次作业可抽奖一次', gravity: ToastGravity.CENTER);
        }
      },
    );
  }

  _start() {
    int random = Random().nextInt(100);
    int start = 0;
    int idx = 0;
    for (var item in prizes) {
      int ratio = item['ratio'];
      if (random >= start && random < (start + ratio)) {
        prize = idx;
        break;
      }
      start += ratio;
      idx++;
    }
    print("random = " + random.toString());
    print("result  = " + prize.toString());

    _countdownTimer =
        new Timer.periodic(new Duration(milliseconds: 100), (timer) {
      times++;
      _select = cycle[times % 8];
      if (times > 30 && _select == prize) {
        _countdownTimer?.cancel();
        _countdownTimer = null;

        int coins = prizes[prize]['coins']; 
        if (coins > 0) {
          _award(coins);
        }
      }
      setState(() {});
    });
  }

  //TODO 万一上传失败不没有重试
  _award(coins) {
    var formData = {
      "changeType": 1,
      "coins": coins,
      "reason": "作业奖励",
      "userId": Global.profile.user.userId
    };
    HttpUtil.getInstance()
        .post('/api/v1/ums/coinsChange/award', formData: formData)
        .then((val) {
      print(val);
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
          OutlineButton(
            color: Theme.of(context).accentColor,
            child: Text('继续作业'),
            onPressed: () {
              Routers.router
                  .navigateTo(context, Routers.taskNewPage, replace: true);
            },
          )
        ],
      ),
    );
  }
}
