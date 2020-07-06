import 'dart:ui';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/widgets/course.dart';
import 'package:pupil/widgets/input.dart';

import 'package:pupil/widgets/loading_dlg.dart';

class TaskAssignPage extends StatefulWidget {
  @override
  _TaskAssignPageState createState() => _TaskAssignPageState();
}

class _TaskAssignPageState extends State<TaskAssignPage> {
  List<String> _courseChips = <String>['语文', '数学', '英语', '其它'];
  String _course = '';

  List<String> _typeChips = <String>[
    '默写',
    '抄写',
    '复习',
    '预习',
    '订正',
    '做试卷',
    '练习册',
    '背诵',
    '其它'
  ];
  String _type = '';

  TextEditingController _titleController =
      TextEditingController.fromValue(TextEditingValue(text: ''));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('布置作业'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: <Widget>[
       
              buildCourseSelectWidget(_course, Theme.of(context).accentColor,
                  (val) {
                setState(() {
                  _course = val;
                  _type = '';
                  _titleController.value =
                      TextEditingValue(text: _course + _type);
                });
              }),
              buildSubTypeSelectWidget(
                  _course, _type, Theme.of(context).accentColor, (val) {
                setState(() {
                  _type = val;
                  _titleController.value =
                      TextEditingValue(text: _course + _type);
                });
              }),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: buildInput(_titleController, null, '作业内容', false),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomPadding: false,
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
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
          '布置作业',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _submit();
        },
      ),
    );
  }

  _submit() {
    if (_course == '' || _type == '') {
      Fluttertoast.showToast(msg: '请选择课程和作业类型', gravity: ToastGravity.CENTER);
      return;
    }
    if (_titleController.text.length < 2) {
      Fluttertoast.showToast(msg: '请输入作业内容', gravity: ToastGravity.CENTER);
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: "正在保存...",
          );
        });

    FormData formData = new FormData.fromMap({
      "classification": _type,
      "course": _course,
      "outTime": 0,
      "score": 0,
      "spendTime": 0,
      "status": "ASSIGNED",
      "title": _titleController.text,
      "userId": Global.profile.user.userId
    });
    String url = "/api/v1/ums/task";

    print(formData);
    HttpUtil.getInstance().post(url, formData: formData).then((val) {
      Navigator.pop(context);
      print(val);
      if (val['code'] == '10000') {
        Fluttertoast.showToast(msg: '操作成功', gravity: ToastGravity.CENTER);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  }
}
