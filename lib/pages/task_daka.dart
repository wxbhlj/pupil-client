
import 'dart:io';

import 'dart:ui';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';

import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/course.dart';
import 'package:pupil/widgets/input.dart';

import 'package:pupil/widgets/loading_dlg.dart';


class TaskDakaPage extends StatefulWidget {
  @override
  _TaskDakaPageState createState() => _TaskDakaPageState();
}

class _TaskDakaPageState extends State<TaskDakaPage> {
  List<SelectFile> files = List();

  String _course = '其它';
  String _type = '';
  int score = 0;

  List _types = ['养成好习惯', '参与做家务', '日常体育锻炼', '兴趣爱好', '其它'];

  TextEditingController _titleController =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  //TextEditingController _timeController =
  //    TextEditingController.fromValue(TextEditingValue(text: '0'));

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
        title: Text('补记作业'),
      ),
      body: _buildBody(),
      resizeToAvoidBottomPadding: false,
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  _buildBody() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // 触摸收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20, top: 0, right: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: ScreenUtil().setHeight(20),
              ),
              _buildSubTypeSelectWidget( _type, Theme.of(context).accentColor, (val) {
                setState(() {
                  _type = val;
                  _titleController.value =
                      TextEditingValue(text: _course + _type);
                });
              }),
              buildInput3(
                  _titleController, '打卡内容', false, null, TextInputType.text),
              /* Stack(
                children: <Widget>[
                  buildInput3(_timeController, '作业耗时', false, null,
                      TextInputType.number),
                  Positioned(
                    right: 0,
                    top: 15,
                    child: Text('分钟'),
                  )
                ],
              ), */
           
             
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSubTypeSelectWidget(String val, Color selectColor, OnClick click) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                '选择类型',
                style: TextStyle(fontWeight: FontWeight.w400),
              )
            ],
          ),
          Container(
            width: ScreenUtil().setWidth(750),
            margin: EdgeInsets.only(top: 0),
            child: Wrap(
              spacing: 0,
              alignment: WrapAlignment.start,
              children: _subTypeWidgets(val, selectColor, click),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget>  _subTypeWidgets(String val, Color selectColor, OnClick click)  {

    List<Widget> list = List();
   
    
      for (String chip in _types) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            click(chip);
          },
          selectedColor: selectColor,
          selected: val == chip,
        ),
      ));
    }
    
    return list;
  }


  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
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
          '完成打卡',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _submit();
        },
      ),
    );
  }

  _submit() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: "正在保存...",
          );
        });

    FormData formData = new FormData.fromMap({
      "classification": '',
      "course": _course,
      "outTime": 0,
      "score": score.toInt(),
      "spendTime": 0, //int.parse(_timeController.text) * 60,
      "status": "CHECKED",
      "title": _titleController.text,
      "userId": Global.profile.user.userId
    });
    String url = "/api/v1/ums/task";


    print(formData);
    HttpUtil.getInstance().post(url, formData: formData).then((val) {
      Navigator.pop(context);
      print(val);
      if (val['code'] == '10000') {
        Routers.router
            .navigateTo(context, Routers.taskSubmittedPage, replace: true);
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  }
}
