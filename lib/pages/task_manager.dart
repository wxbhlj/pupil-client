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
          Image.asset(
              'images/' + Utils.translate(tasks[index]['course']) + '.png',
              width: 48),
        ],
      ),
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
                empty: Icon(Icons.star_border, color: Colors.white),
              ),
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            ),
          ),
          Utils.buildStatus(tasks[index]['status']),
        ],
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
        showConfirmDialog(context, '确定要删除吗', () {
          HttpUtil.instance
              .delete("/api/v1/ums/task/" + tasks[index]['id'].toString());
          setState(() {});
        });
      },
    );
  }

  
}
