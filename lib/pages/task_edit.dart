import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/course.dart';
import 'package:pupil/widgets/dialog.dart';
import 'package:pupil/widgets/input.dart';
import 'package:pupil/widgets/loading_dlg.dart';


class TaskEditPage extends StatefulWidget {
  @override
  _TaskEditPageState createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  int taskId = 0;
  String _course;
  String _type;

  List<SelectFile> files = List();

  TextEditingController _titleController =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  //TextEditingController _timeController =
  //    TextEditingController.fromValue(TextEditingValue(text: ''));
  int score = 0;
  var _eventSubscription;
  var data;
  @override
  void initState() {
    taskId = Global.prefs.getInt("_taskId");
    _refreshData();
    _registerEvent();
    super.initState();
  }

  _refreshData() {
    _getData().then((resp) {
      print("##################");
      print(resp);
      setState(() {
        data = resp['data'];
        var task = data['task'];
        _course = task['course'];
        _type = task['classification'];
      });
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }

  _registerEvent() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("onEvent:" + event.eventType);
      if (event.eventType == EVENT_REFRESH_TASK) {
        _refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showConfirmDialog(context, '确定要删除吗', () {
                HttpUtil.instance
                    .delete("/api/v1/ums/task/" + taskId.toString());
                GlobalEventBus.fireRefreshCheckList();
                Navigator.pop(context);
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _buildBody(data),
        ),
      ),
      resizeToAvoidBottomPadding: false,
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          ScreenUtil().setWidth(20), 0, ScreenUtil().setWidth(20), 0),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(100),
      child: Column(
        children: <Widget>[_buildSubmitButton()],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: ScreenUtil().setWidth(750),
      child: RaisedButton(
        child: Text(
          '保存',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _submit();
        },
      ),
    );
  }

  Future _getData() async {
    return HttpUtil.getInstance().get(
      "api/v1/ums/task/" + taskId.toString(),
    );
  }

  Widget _buildBody(data) {
    if (data == null) {
      return Center(
        child: Text('正在加载...'),
      );
    }
    var task = data['task'];
    var attachments = data['attachments'];
    if(score == 0) {
      score = task['score'];
    }
    

    _titleController.value = TextEditingValue(text: task['title']);
    /*
    if (_timeController.text.length == 0) {
      _timeController.value =
          TextEditingValue(text: (task['spendTime'] ~/ 60).toString());
    }*/

    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        children: <Widget>[
          buildCourseSelectWidget(_course, Theme.of(context).accentColor,
              (val) {
            setState(() {
              _course = val;
              _type = '';
            });
          }),
          buildSubTypeSelectWidget(
              _course, _type, Theme.of(context).accentColor, (val) {
            setState(() {
              _type = val;
            });
          }),
          Divider(
            height: ScreenUtil().setHeight(20),
          ),

          _buildAttachment(attachments),
          buildInput3(_titleController, '标题', false, null, TextInputType.text),
          /*
          Stack(
            children: <Widget>[
              buildInput3(
                  _timeController, '作业耗时', false, null, TextInputType.number),
              Positioned(
                right: 0,
                top: 15,
                child: Text('耗时(分钟)'),
              )
            ],
          ),*/
          //buildInput(_commonsController, null, '作业评语', false),
          //_buildSlider(),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: task['classification'] == '其它'
                ? Text('')
                : buildStarInput(task['score'] / 20, (ret) {
                    print("on star changed " + ret.toString());
                    setState(() {
                      this.score = (ret * 20).toInt();
                      print(this.score.toString());
                    });
                  }),
          )
        ],
      ),
    );
  }

  Widget _buildAttachment(attachments) {
    List<Widget> imageList = new List();

    for (var attach in attachments) {
      if (attach['type'] == 'image') {
        imageList.add(_buildImage(attach));
      } else {
        imageList.add(_buildSound(attach));
      }
    }

    return Container(
      width: ScreenUtil().setWidth(750),
      margin: EdgeInsets.only(left: 0, right: 0),
      child: Wrap(
        spacing: 0,
        alignment: WrapAlignment.start,
        children: imageList,
      ),
    );
  }

  Widget _buildImage(attach) {
    print('build image....');
    return InkWell(
      onTap: () {
        Global.prefs.setInt("_attachmentId", attach['id']);
        Global.prefs.setString("_attachmentUrl", attach['url']);
        Routers.router
            .navigateTo(context, Routers.imageEditPage, replace: false);
      },
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setWidth(165),
        child: ClipRRect(
          child: CachedNetworkImage(
            imageUrl: attach['url'],
            fit: BoxFit.fill,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSound(attach) {
    print('build sound....');
    return InkWell(
      onTap: () {
        {}
      },
      child: SoundWidget2(attach['url']),
    );
  }

  _submit() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: "正在提交...",
          );
        });
    print("score = " + this.score.toString() + ", " + _titleController.text);
    var formData = {
      "comments": "",
      "id": data['task']['id'],
      "score": this.score,
      "title": _titleController.text,
      "course": _course,
      "classification": _type,
      "spendTime": 0,//int.parse(_timeController.text) * 60
    };
    print("score = " + this.score.toString() + ", " + _titleController.text);
  

    String url = "/api/v1/ums/task";

    print(formData);
    HttpUtil.getInstance().put(url, formData: formData).then((val) {
      Navigator.pop(context);
      print(val);
      if (val['code'] == '10000') {
        GlobalEventBus.fireRefreshCheckList();
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  }
}
