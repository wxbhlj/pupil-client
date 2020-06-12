import 'dart:async';

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';

import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/input.dart';

import 'package:pupil/widgets/loading_dlg.dart';
import 'package:pupil/widgets/photo_view.dart';
import 'package:pupil/widgets/recorder.dart';
import 'package:pupil/widgets/showtime_widget.dart';
import 'package:wakelock/wakelock.dart';

class TaskCreatePage extends StatefulWidget {
  @override
  _TaskCreatePageState createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {

  List<SelectFile> files = List();

  List<String> _courseChips = <String>['语文', '数学', '英语', '其它'];
  String _course = '';
  double score = 60;
  

  TextEditingController _titleController =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  TextEditingController _timeController =
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
        title: Text('补记作业'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 20, top: 10, right: 20),
          child: Column(
          children: <Widget>[
            _buildCourseWidget(),
            buildInputWithTitle(_titleController, '作业内容', '标题', false, null,
                TextInputType.text),
            Stack(
              children: <Widget>[
                buildInputWithTitle(_timeController, '作业耗时', '', false, null,
                    TextInputType.number),
                Positioned(
                  right: 0,
                  top: 15,
                  child: Text('分钟'),
                )
              ],
            ),
            _buildSlider(),
            _buildContentWidget(),
            SizedBox(
              height: ScreenUtil().setHeight(200),
            )
          ],
        ),
        ),
      ),
      resizeToAvoidBottomInset:false,
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        source: ImageSource.camera, maxWidth: 480, maxHeight: 720);
    print(image.path);
    files.add(SelectFile(file: image, type: "image"));
    setState(() {});
  }

  Widget _buildSubmitButton() {
    return Container(
      width: ScreenUtil().setWidth(750),
      child: RaisedButton(
        child: Text(
          '完成作业',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _submit();
        },
      ),
    );
  }

  Widget _buildCourseWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                ' 选择课程',
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
              children: _courseWidgets.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> get _courseWidgets sync* {
    for (String chip in _courseChips) {
      yield Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            setState(() {
              _course = val ? chip : _course;
            });
          },
          selectedColor: Theme.of(context).accentColor,
          selected: _course == chip,
        ),
      );
    }
  }

  _buildSlider() {
    return Container(
        width: ScreenUtil().setWidth(750),
        margin: EdgeInsets.only(top: 20, left: 0),
        child: Card(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(120)),
                child: Slider(
                  label: '得分 ${score.toInt()}',
                  max: 100,
                  min: 0,
                  divisions: 100,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  value: score,
                  onChanged: (double v) {
                    setState(() {
                      this.score = v;
                    });
                  },
                ),
              ),
              Positioned(
                left: 10,
                top: 15,
                child: Text('得分:' + score.toInt().toString()),
              )
            ],
          ),
        ));
  }



  _submit() {
 
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
      "spendTime": int.parse(_timeController.text)*60,
      "status": "CHECKED",
      "title": _titleController.text,
      "userId": Global.profile.user.userId
    });
    String url = "/api/v1/ums/task";
    if (files.length > 0) {
      for (SelectFile file in files) {
        formData.files.add(MapEntry(
          "files",
          MultipartFile.fromFileSync(file.file.path, filename: file.type),
        ));
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
