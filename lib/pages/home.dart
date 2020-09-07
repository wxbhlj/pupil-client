import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/pages/setting/settings.dart';
import 'package:pupil/widgets/upgrade.dart';

import '../common/global_event.dart';
import '../pages/login.dart';


import 'home_index.dart';
import 'home_parents.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> list = List();


  var _eventSubscription;

  @override
  void initState() {
    list..add(HomeIndexPage())..add(HomeParentsPage());
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("C onEvent:" + event.eventType);
      if (event.eventType == EVENT_TOKEN_ERROR) {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new LoginPage()),
            (route) => route == null);
      }
    });
    super.initState(); //无名无参需要调用
    CheckUpdate().check(context);
  }

  @override
  void dispose() {
    super.dispose();
    _eventSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
      body: list[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Routers.navigateTo(context, Routers.taskCreatePage);
        },
        child: Icon(Icons.create),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: _tabs(),
      ),
    );
  }

  Row _tabs() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _tabItem(0, Icons.home, '学生'),
        _tabItem(1, Icons.people, '家长'),
    
      ],
    );
  }

  Color _tabColors(idx) {
    if (idx == _currentIndex) {
      return Theme.of(context).accentColor;
    } else {
      return Colors.black45;
    }
  }

  Widget _tabItem(int idx, IconData icon, String label) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
        width: ScreenUtil().setWidth(120),
        height: ScreenUtil().setHeight(100),
        child: Column(
          children: <Widget>[
            Icon(icon, color: _tabColors(idx)),
            Text(
              label,
              style: TextStyle(color: _tabColors(idx), fontSize: 12),
            )
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _currentIndex = idx;
        });
      },
    );
  }
}
