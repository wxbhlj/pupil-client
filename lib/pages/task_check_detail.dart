import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/dialog.dart';
import 'package:pupil/widgets/input.dart';
import 'package:pupil/widgets/loading_dlg.dart';
import 'package:pupil/widgets/photo_view.dart';

class TaskCheckDetailPage extends StatefulWidget {
  @override
  _TaskCheckDetailPageState createState() => _TaskCheckDetailPageState();
}

class _TaskCheckDetailPageState extends State<TaskCheckDetailPage> {
  int taskId = 0;

  TextEditingController _titleController =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  TextEditingController _timeController =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  double score = 60;
  var data;
  @override
  void initState() {
    taskId = Global.prefs.getInt("_taskId");
    _getData().then((resp) {
      print("##################");
      print(resp);
      setState(() {
        data = resp['data'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('作业详情'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              showConfirmDialog(context, '确定要删除吗', (){
                HttpUtil.instance.delete("/api/v1/ums/task/" + taskId.toString());
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
      resizeToAvoidBottomInset: false,
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: ScreenUtil().setWidth(750),
      //height: ScreenUtil().setHeight(230),
      child: _buildSubmitButton(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: ScreenUtil().setWidth(750),
      child: RaisedButton(
        child: Text(
          '批改完成',
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
    _titleController.value = TextEditingValue(text: task['title']);
    if (_timeController.text.length == 0) {
      _timeController.value =
          TextEditingValue(text: (task['spendTime'] ~/ 60).toString());
    }

    return Container(
      margin: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,),
      child: Column(
        children: <Widget>[
          _buildAttachment(attachments),
          _buildTimeInfo(task),
          Divider(
            height: ScreenUtil().setHeight(20),
          ),
          buildInput3(
              _titleController, '标题', false, null, TextInputType.text),

          Stack(
            children: <Widget>[
              buildInput3(_timeController, '作业耗时', false, null,
                  TextInputType.number),
              Positioned(
                right: 0,
                top: 15,
                child: Text('耗时(分钟)'),
              )
            ],
          ),
          //buildInput(_commonsController, null, '作业评语', false),
          //_buildSlider(),
          Padding(
            padding: EdgeInsets.only(top:30),
            child: buildStarInput((ret){
            setState(() { 
              this.score = ret * 20;
            });
          }),
          )
        ],
      ),
    );
  }

  _buildTimeInfo(task) {
    if (task['outTime'] < 60) {
      return Text('');
    }
    return Container(
      width: ScreenUtil().setWidth(710),
      margin: EdgeInsets.only(
          top: ScreenUtil().setHeight(20), bottom: ScreenUtil().setHeight(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '异常时间' + (task['outTime'] ~/ 60).toString() + "分钟",
            style: TextStyle(color: Colors.red),
          ),
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
          .navigateTo(context, Routers.imageEditPage , replace: false);
      },
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setHeight(165),
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

    var formData = {
      "comments": "",
      "id": data['task']['id'],
      "score": score,
      "title": _titleController.text,
      "spendTime": int.parse(_timeController.text) * 60
    };
    String url = "/api/v1/ums/task/checked";

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
