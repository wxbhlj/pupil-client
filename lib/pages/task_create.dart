import 'dart:async';
import 'dart:io';

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';

import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/course.dart';
import 'package:pupil/widgets/input.dart';

import 'package:pupil/widgets/loading_dlg.dart';
import 'package:pupil/widgets/photo_view.dart';
import 'package:pupil/widgets/recorder.dart';

class TaskCreatePage extends StatefulWidget {
  @override
  _TaskCreatePageState createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  List<SelectFile> files = List();

  String _course = '';
  String _type = '';
  int score = 60;

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
        title: Text('记录作业'),
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
              buildInput3(
                  _titleController, '作业内容', false, null, TextInputType.text),
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
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: _type == '其它'
                    ? Text('')
                    : buildStarInput(3, (ret) {
                        print("on star changed " + ret.toString());
                        setState(() {
                          this.score = (ret * 20).toInt();
                          print(this.score.toString());
                        });
                      }),
              ),
              _buildContentWidget(),
              SizedBox(
                height: ScreenUtil().setHeight(200),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Container(
        width: ScreenUtil().setWidth(750),
        margin: EdgeInsets.only(top: 0),
        child: _buildImages(),
      ),
    );
  }

  Widget _buildImages() {
    List<Widget> imageList = new List();
    if (imageList.length == 0) {
      for (int i = 0; i < files.length; i++) {
        SelectFile file = files[i];
        if (file.type == 'image') {
          imageList.add(_buildImage(files[i]));
        } else {
          imageList.add(_buildSound(files[i]));
        }
      }
    }
    return Wrap(
      spacing: 0,
      alignment: WrapAlignment.start,
      children: imageList,
    );
  }

  Widget _buildImage(SelectFile file) {
    print('build image....');
    return InkWell(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (c, a, s) => PreviewImagesWidget(
                  file.file.path,
                )));
      },
      child: Container(
        child: buildImageWithDel(file.file, () {
          file.file.delete();
          files.remove(file);
          setState(() {});
        }),
      ),
    );
  }

  Widget _buildSound(SelectFile file) {
    print('build sound....');
    return InkWell(
      onTap: () {
        {}
      },
      child: SoundWidget(file, () {
        file.file.delete();
        files.remove(file);
        setState(() {});
      }),
    );
  }

  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(230),
      child: Column(
        children: <Widget>[_buildActionButtons(), _buildSubmitButton()],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: ScreenUtil().setWidth(750),
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InkWell(
            child: Container(
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(5)),
              width: ScreenUtil().setWidth(120),
              height: ScreenUtil().setHeight(82),
              child: Column(
                children: <Widget>[
                  Icon(Icons.photo_camera),
                  Text(
                    '拍照',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  )
                ],
              ),
            ),
            onTap: () {
              _selectImage();
            },
          ),
          InkWell(
            child: Container(
              margin: EdgeInsets.only(top: ScreenUtil().setHeight(5)),
              width: ScreenUtil().setWidth(120),
              height: ScreenUtil().setHeight(82),
              child: Column(
                children: <Widget>[
                  Icon(Icons.keyboard_voice),
                  Text(
                    '录音',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  )
                ],
              ),
            ),
            onTap: () {
              _record();
            },
          )
        ],
      ),
    );
  }

  _record() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Recorder((path, duration) {
            files.add(SelectFile(
                file: LocalFileSystem().file(path),
                type: 'sound',
                duration: duration));
            setState(() {});
          });
        });
  }

  Future _selectImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1440,
        imageQuality: 50);
    print(image.path);
    files.add(SelectFile(file: image, type: "image"));
    setState(() {});
  }

  Widget _buildSubmitButton() {
    return Container(
      width: ScreenUtil().setWidth(750),
      child: RaisedButton(
        child: Text(
          '保存作业',
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
    if(_type == '其它') {
      score = 0;
    }
    FormData formData = new FormData.fromMap({
      "classification": _type,
      "course": _course,
      "outTime": 0,
      "score": score.toInt(),
      "spendTime": 0, //int.parse(_timeController.text) * 60,
      "status": "CHECKED",
      "title": _titleController.text,
      "userId": Global.profile.user.userId
    });
    String url = "/api/v1/ums/task";
    if (files.length > 0) {
      for (SelectFile file in files) {
        if (file.type == 'image') {
          File compressedFile = await FlutterNativeImage.compressImage(
              file.file.path,
              quality: 60,
              percentage: 100);
          formData.files.add(MapEntry(
            "files",
            MultipartFile.fromFileSync(compressedFile.path,
                filename: file.type),
          ));
        } else {
          formData.files.add(MapEntry(
            "files",
            MultipartFile.fromFileSync(file.file.path, filename: file.type),
          ));
        }
      }
    }

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
