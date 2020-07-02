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
    print(user);
    if (DateTime.now().millisecondsSinceEpoch - user.loginTime >
        1000 * 60 * 60 * 24) {
      //重新获取数据
      _refreshUserDetail();
    }
  }

  _refreshUserDetail() {
    HttpUtil.getInstance()
        .get(
      "api/v1/ums/user/getDetail/" + Global.profile.user.userId.toString(),
    )
        .then((resp) {
      if (resp['code'] == '10000') {
        Global.prefs.remove("_chart_data_" + Global.profile.user.userId.toString());
        user = User.fromJson(resp['data']);

        Provider.of<UserModel>(context, listen: false).user = user;
        setState(() {});
      }
    });
  }

  _registerEvent() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("onEvent:" + event.eventType);
      if (event.eventType == EVENT_REFRESH_TODOLIST) {}
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
      appBar:PreferredSize(
        child: Header(),
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(240))),
        resizeToAvoidBottomInset: false,
        body: Scaffold(
          body: _buildBody(),
        ));
  }

  Future<Null> _refresh() async {
    _refreshUserDetail();
    return;
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
    
            LineChartWidget(),

            Padding(
              padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    child: _buildMenuItem("images/bujiao.png", "补记作业"),
                    onTap: () {
                      Routers.navigateTo(context, Routers.taskTodoListPage);
                    },
                  ),
                  InkWell(
                    child: _buildMenuItem("images/review.png", "复习作业"),
                    onTap: () {
                      Routers.navigateTo(context,
                          Routers.taskReviewListPage + "?status=CHECKED");
                    },
                  ),
                  InkWell(
                    child: _buildMenuItem("images/emotion.png", "今日心情"),
                    onTap: () {
                      Routers.navigateTo(context, Routers.moonCreatePage);
                    },
                  ),
/*
              InkWell(
                child: _buildMenuItem("images/houhui.png", "后悔药"),
                onTap: () {
                  //Routers.navigateTo(context, Routers.taskReviewListPage+ "?status=CHECKED");
                },
              ),*/
                ],
              ),
            ),
            SizedBox(
              height: 200,
            )

            //(),
          ],
        ),
      ),
    );
  }


  

  Widget _buildMenuItem(String image, String title) {
    return Stack(
      //fit: StackFit.expand,
      alignment: Alignment.topRight,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          width: ScreenUtil().setWidth(156),
          height: ScreenUtil().setHeight(156),
          decoration: new BoxDecoration(
            //color: Colors.white,
            //设置���周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            //设置四周边框
            //border: new Border.all(width: 1, color: Theme.of(context).accentColor),
          ),
        ),
        Positioned(
          left: ScreenUtil().setWidth(40),
          top: ScreenUtil().setHeight(20),
          child: InkWell(
            child: Image.asset(
              image,
              width: ScreenUtil().setWidth(72),
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
        Positioned(
          left: ScreenUtil().setWidth(00),
          top: ScreenUtil().setHeight(100),
          child: Container(
            width: ScreenUtil().setWidth(156),
            child: Center(
              child: Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
        )
      ],
    );
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
    
    if(Theme.of(context).accentColor.value == Colors.orange.value || Theme.of(context).accentColor.value == Colors.red.value) {
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
              Routers.router.navigateTo(context, Routers.homePage, replace: true);
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
            user.nick,
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
            itemSize: ScreenUtil().setWidth(64),
            itemCount: 5,
            ratingWidget: RatingWidget(
              full: Icon(Icons.star, color: starColor),
              half: Icon(
                Icons.star_half,
                color: starColor,
              ),
              empty: Icon(Icons.star_border, color: starColor),
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

