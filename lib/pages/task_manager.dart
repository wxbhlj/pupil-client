import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/common/utils.dart';
import 'package:pupil/widgets/dialog.dart';

class TaskManagerPage extends StatefulWidget {
  @override
  _TaskManagerPageState createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  var _eventSubscription;
  @override
  void initState() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("onEvent:" + event.eventType);
      if (event.eventType == EVENT_REFRESH_CHECKLIST) {
        setState(() {});
      }
    });
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
      ),
      body: FutureBuilder(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: Text('加载中...'),
                );

              default: //如果_calculation执行完毕
                if (snapshot.hasError) {
                  //若_calculation执行出现异常
                  return new Text('Error: ${snapshot.error}');
                } else {
                  return _createListView(context, snapshot);
                }
            }
          }),
    );
  }

  Future _getData() async {
    return HttpUtil.getInstance().get(
      "api/v1/ums/task/list?status=&userId=" +
          Global.profile.user.userId.toString(),
    );
  }

  Widget _createListView(BuildContext context, AsyncSnapshot snapshot) {
    print(snapshot.data['data']);
    var items = snapshot.data['data'];
    return ListView.builder(
      itemBuilder: (context, index) => _itemBuilder(context, index, items),
      itemCount: items.length * 2,
    );
  }

  Widget _itemBuilder(BuildContext context, int index, tasks) {
    if (index.isOdd) {
      return Divider();
    }
    index = index ~/ 2;
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
      leading: Stack(
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
              border: new Border.all(width: 1, color: Colors.black),
            ),
          ),
          Positioned(
            left: 0,
            top: 8,
            child: Container(
              width: ScreenUtil().setWidth(96),
              child: Center(
                child: Text(
                  tasks[index]['course'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          _buildStatus(tasks[index]['status']),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 5),
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
            empty: Icon(Icons.star_border, color: Colors.orange),
          ),
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        ),
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        String status = tasks[index]['status'];
        if (status == 'UPLOAD') {
          Global.prefs.setInt("_taskId", tasks[index]['id']);
          Routers.navigateTo(context, Routers.taskCheckDetailPage);
        } else if (status == 'ASSIGNED') {
          Global.prefs.setInt("_taskId", tasks[index]['id']);
          Global.prefs.setString("_taskTitle", tasks[index]['title']);
          Routers.navigateTo(context, Routers.taskDoitPage);
        } else {
          Routers.navigateTo(
              context,
              Routers.taskReviewDetailPage +
                  "?taskId=" +
                  tasks[index]['id'].toString());
        }
      },
      onLongPress: () {
        showConfirmDialog(context, '确定要删除吗', (){
          HttpUtil.instance.delete("/api/v1/ums/task/" + tasks[index]['id'].toString());
          setState(() {
            
          });
        });
      },
    );
  }

  Widget _buildStatus(String status) {
    Widget text;
    if (status == 'CHECKED') {
      text = Text('已批改', style: TextStyle(color: Colors.green, fontSize: 10));
    } else if (status == 'ASSIGNED') {
      text = Text('需补拍', style: TextStyle(color: Colors.red, fontSize: 10));
    } else if (status == 'UPLOAD') {
      text = Text('未批改', style: TextStyle(color: Colors.black, fontSize: 10));
    } else {
      text =
          Text('已复习', style: TextStyle(color: Colors.lightGreen, fontSize: 10));
    }
    return Positioned(
      left: 0,
      bottom: 5,
      child: Container(
        width: ScreenUtil().setHeight(96),
        child: Center(
          child: text,
        ),
      ),
    );
  }
}
