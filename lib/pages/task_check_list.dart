

import 'package:flutter/material.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/common/utils.dart';

class TaskCheckListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('检查作业'),),
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
    
    return HttpUtil.getInstance()
        .get("api/v1/ums/task/list?status=UPLOAD&userId=" + Global.profile.user.userId.toString(), );
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
      title: Text(tasks[index]['title']  ),
      subtitle: Text(Utils.formatDate(tasks[index]['created']) + ' 完成, 耗时 ' + Utils.twoDigits2(tasks[index]['spendTime']~/60)  +'分钟'),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        Global.prefs.setInt("_taskId", tasks[index]['id']);
        Routers.navigateTo(context, Routers.taskCheckDetailPage);
      },
    );
  }

}