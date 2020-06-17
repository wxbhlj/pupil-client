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
    if(DateTime.now().millisecondsSinceEpoch - user.loginTime > 1000*60*60*24) {
       //重新获取数据
       _refreshUserDetail();
    }
  }



  _refreshUserDetail() {
    HttpUtil.getInstance()
        .get("api/v1/ums/user/getDetail/" + Global.profile.user.userId.toString(), ).then((resp){
          if(resp['code'] == '10000') {
            user = User.fromJson(resp['data']);
            print(user.avatar);
            Provider.of<UserModel>(context, listen: false).user = user;
            setState(() {
              
            });
          }
        });
  }

  _registerEvent() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("onEvent:" + event.eventType);
      if (event.eventType == EVENT_REFRESH_TODOLIST) {
     
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Scaffold(
   
      body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
       
          _buildTitle(),
          LineChartWidget(),
          //BarChartWidget(),

          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: _buildMenuItem("images/bujiao.png", "补拍作业"),
                onTap: () {
                  Routers.navigateTo(context, Routers.taskTodoListPage);
                },
              ),
              InkWell(
                child: _buildMenuItem("images/review.png", "首轮复习"),
                onTap: () {
                  Routers.navigateTo(context, Routers.taskReviewListPage+ "?status=CHECKED");
                },
              ),
              InkWell(
                child: _buildMenuItem("images/review2.png", "深化复习"),
                onTap: () {
                  Routers.navigateTo(context, Routers.taskReviewListPage + "?status=REVIEWED");
                },
              ),
              
               
            ],
          ),
          ),
 
          //(),
        ],
      ),
      ),
    ),
        )
    );
 
  }

  Widget _buildTitle() {
    User user = Global.profile.user;
    return Container(
      padding: EdgeInsets.only(top: 25, bottom: 0),
      child: ListTile(
        leading: user.avatar != null && user.avatar.length > 0
            ? Container(
                width: ScreenUtil().setWidth(100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: user.avatar,
                    fit: BoxFit.fill,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              )
            : Icon(
                Icons.account_box,
                size: ScreenUtil().setWidth(156),
              ),
        title: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                user.nick,
                style:
                    TextStyle(fontFamily: '微软雅黑', fontWeight: FontWeight.bold,fontSize: 18),
              ),
            ),
          ],
        ),
        subtitle: Padding(padding: EdgeInsets.only(top:5), child: RatingBar(
          initialRating: user.avgScore/20,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemSize: ScreenUtil().setWidth(48),
          itemCount: 5,
          ratingWidget: RatingWidget(
            full: Icon(Icons.star, color: Colors.orange),
            half: Icon(
              Icons.star_half,
              color: Colors.orange,
            ),
            empty: Icon(Icons.star_border, color: Colors.orange),
          ),
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        ),),
        trailing: _buildCoins(),
        onTap: () {
          _refreshUserDetail();
        },
      ),
    );
  }

  Widget _buildCoins() {
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
            child: Image.asset('images/coins.png', width: ScreenUtil().setWidth(72),),
     
          ), 
        ),
        Positioned(
          right: ScreenUtil().setWidth(10),
          top: ScreenUtil().setHeight(35),
          child: Container(
            width: ScreenUtil().setWidth(96),
            child: Center(child: Text(
            (user.coinsTotal - user.coinsUsed).toString(),
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),),
          ),
        )
      ],
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
            //设置四周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            //设置四周边框
            //border: new Border.all(width: 1, color: Theme.of(context).accentColor),
          ),
        ),
        Positioned(
          left: ScreenUtil().setWidth(40),
          top: ScreenUtil().setHeight(20),
          child: InkWell(
            child: Image.asset(image, width: ScreenUtil().setWidth(72), color: Theme.of(context).accentColor,),
     
          ),
        ),
        Positioned(
          left: ScreenUtil().setWidth(00),
          top: ScreenUtil().setHeight(100),
          child: Container(
            width: ScreenUtil().setWidth(156),
            child: Center(child: Text(title,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),),
          ),
        )
      ],
    );
  }


}
