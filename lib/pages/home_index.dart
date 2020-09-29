import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/common/utils.dart';
import 'package:pupil/models/user.dart';
import 'package:pupil/states/user_model.dart';

import 'home_index_chart.dart';

class HomeIndexPage extends StatefulWidget {
  @override
  _HomeIndexPageState createState() => _HomeIndexPageState();
}

class _HomeIndexPageState extends State<HomeIndexPage>
    with SingleTickerProviderStateMixin {
  var tasks;
  var _eventSubscription;
  User user;

  @override
  void initState() {
    super.initState();
    _registerEvent();

    user = Global.profile.user;
 
    if (DateTime.now().millisecondsSinceEpoch - user.loginTime >
        1000 * 60 * 60 * 24) {
      //重新获取数据
      _refreshUserDetail();
    }
    _refreshTodoList();
  }

  _refreshUserDetail() {
    HttpUtil.getInstance()
        .get(
      "api/v1/ums/user/getDetail/" + Global.profile.user.userId.toString(),
    )
        .then((resp) {
      if (resp['code'] == '10000') {
        Global.prefs
            .remove("_chart_data_" + Global.profile.user.userId.toString());
        user = User.fromJson(resp['data']);

        Provider.of<UserModel>(context, listen: false).user = user;
        setState(() {});
      }
    });
  }

  _refreshTodoList() {
    _getTodoList().then((resp) {
      setState(() {
        tasks = resp['data'];
 
      });
    });
  }

  Future _getTodoList() async {
    return HttpUtil.getInstance().get(
      "api/v1/ums/task/todoList?userId=" +
          Global.profile.user.userId.toString(),
    );
  }

  _registerEvent() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
 
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
      appBar: PreferredSize(
          child: Header(),
          preferredSize: Size.fromHeight(ScreenUtil().setHeight(240))),
      resizeToAvoidBottomInset: false,
      body: _buildBody(),
      //floatingActionButton: _buildFloatingActionButtion(context),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<Null> _refresh() async {
    _refreshUserDetail();
    _refreshTodoList();
    return;
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Column(
        children: <Widget>[
          LineChartWidget(),
          Container(
            margin: EdgeInsets.only(left: 15, top: 20, bottom: 10),
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
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: _buildTaskList(),
            ),
          ),
          SizedBox(
            height: 00,
          )

          //(),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (tasks == null || tasks.length == 0) {
      return Container(
        width: ScreenUtil().setWidth(750),
        height: ScreenUtil().setHeight(300),
        child: Center(
          child: Text('按时完成作业是个好习惯', style: TextStyle(fontSize: 11),),
        ),
      );
    }
    return Container(
      width: ScreenUtil().setWidth(750),
      child: ListView.separated(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return _itemBuilder(context, index, tasks);
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

  Widget _itemBuilder(BuildContext context, int index, tasks) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              tasks[index]['title'],
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(Utils.formatDate3(tasks[index]['created']))
        ],
      ),
      leading: Image.asset(
          'images/' + Utils.translate(tasks[index]['course']) + '.png',
          width: 48),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            //padding: EdgeInsets.only(top: 5),
            child: RatingBar(
              initialRating: tasks[index]['score'] / 20,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemSize: ScreenUtil().setWidth(32),
              itemCount: 5,
              ratingWidget: RatingWidget(
                full: Icon(Icons.star, color: Colors.orange),
                half: Icon(
                  Icons.star_half,
                  color: Colors.orange,
                ),
                empty: Icon(Icons.star_border, color: Colors.white54),
              ),
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            ),
          ),
          _buildStatus(tasks[index]['status']),
        ],
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Global.prefs.setInt("_taskId", tasks[index]['id']);
        Global.prefs.setString("_taskTitle", tasks[index]['title']);
        if (tasks[index]['status'] == 'ASSIGNED') {
          Routers.navigateTo(context, Routers.taskDoitPage);
        } else {
          
          Routers.navigateTo(
              context,
              Routers.taskReviewDetailPage +
                  "?taskId=" +
                  tasks[index]['id'].toString());
        }
      },
    );
  }

  Widget _buildStatus(String status) {

    Widget text;
    if (status == 'ASSIGNED') {
      text = Text('快去提交', style: TextStyle(color: Colors.red, fontSize: 11));
    } else if (status == 'RETURN') {
      text = Text('快去订正', style: TextStyle(color: Colors.red, fontSize: 11));
    } else {
      text = Text('快去复习',
          style: TextStyle(color: Colors.lightGreen, fontSize: 11));
    }
    return text;
  }
}

class Header extends StatefulWidget implements PreferredSizeWidget {
  @override
  HeaderState createState() => HeaderState();

  @override
  Size get preferredSize => new Size.fromHeight(ScreenUtil().setHeight(100));
}

class HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    User user = Global.profile.user;
    Color starColor = Colors.orange;
    double avgStar = user.avgScore / 20;

    if (Theme.of(context).accentColor.value == Colors.orange.value ||
        Theme.of(context).accentColor.value == Colors.red.value) {
      starColor = Colors.white;
    }
    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).accentColor,
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(250),
        ),
        Positioned(
          top: ScreenUtil().setHeight(80),
          left: ScreenUtil().setWidth(30),
          child: InkWell(
            onTap: () {
              Global.profile.toNextUser();
              Global.saveProfile();
              Routers.router
                  .navigateTo(context, Routers.homePage, replace: true);
            },
            child: user.avatar != null && user.avatar.length > 0
                ? Container(
                    width: ScreenUtil().setWidth(128),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: user.avatar,
                        fit: BoxFit.fill,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  )
                : Icon(
                    Icons.account_box,
                    size: ScreenUtil().setWidth(156),
                  ),
          ),
        ),
        Positioned(
          top: ScreenUtil().setHeight(80),
          left: ScreenUtil().setWidth(180),
          child: Text(
            user.nick + " (" + avgStar.toString() + ")",
            style: TextStyle(
                fontFamily: '微软雅黑', fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Positioned(
          top: ScreenUtil().setHeight(140),
          left: ScreenUtil().setWidth(180),
          child: RatingBar(
            initialRating: user.avgScore / 20,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemSize: ScreenUtil().setWidth(48),
            itemCount: 5,
            ratingWidget: RatingWidget(
              full: Icon(Icons.star, color: starColor),
              half: Icon(
                Icons.star_half,
                color: starColor
                    .withOpacity(user.avgScore / 20 - (user.avgScore ~/ 20)),
              ),
              empty:
                  Icon(Icons.star_border, color: Theme.of(context).accentColor),
            ),
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            //onRatingUpdate: (val){},
          ),
        ),
        Positioned(
          top: ScreenUtil().setHeight(80),
          right: ScreenUtil().setWidth(30),
          child: _buildCoins(user),
        ),
      ],
    );
  }

  Widget _buildCoins(User user) {
    return Stack(
      //fit: StackFit.expand,
      alignment: Alignment.topRight,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          width: ScreenUtil().setWidth(96),
          height: ScreenUtil().setHeight(96),
          decoration: new BoxDecoration(
            //color: Colors.white,
            //设置四周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            //设置四周边框
            //border: new Border.all(width: 1, color: Colors.black12),
          ),
        ),
        Positioned(
          left: ScreenUtil().setWidth(0),
          top: ScreenUtil().setHeight(10),
          child: InkWell(
            child: Image.asset(
              'images/coins.png',
              width: ScreenUtil().setWidth(72),
            ),
            onTap: () {
              Routers.navigateTo(context, Routers.coinChangeListPage);
            },
          ),
        ),
        Positioned(
          right: ScreenUtil().setWidth(12),
          top: ScreenUtil().setHeight(32),
          child: Container(
            width: ScreenUtil().setWidth(96),
            child: Center(
              child: Text(
                (user.coinsTotal - user.coinsUsed).toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        )
      ],
    );
  }
}
