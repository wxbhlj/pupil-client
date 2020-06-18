import 'dart:async';

import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/common/utils.dart';
import 'package:pupil/pages/task_new.dart';
import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/dialog.dart';
import 'package:pupil/widgets/input.dart';
import 'package:pupil/widgets/loading_dlg.dart';
import 'package:pupil/widgets/photo_view.dart';
import 'package:pupil/widgets/recorder.dart';
import 'package:pupil/widgets/showtime_widget.dart';
import 'package:wakelock/wakelock.dart';

class TaskDoitPage extends StatefulWidget {
  @override
  _TaskDoitPageState createState() => _TaskDoitPageState();
}

class _TaskDoitPageState extends State<TaskDoitPage> with WidgetsBindingObserver {
  int _seconds = 0;
  Timer _countdownTimer;
  int _outTime = 0;
  DateTime pausedTime;
  List<SelectFile> files = List();
  int _taskId;
  String _taskTitle;

 

  GlobalKey<ShowTimerState> _showTimerState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _taskId = Global.prefs.getInt('_taskId');
    _taskTitle = Global.prefs.getString('_taskTitle');
    WidgetsBinding.instance.addObserver(this);
    _setTimer();
  }

  @override
  void dispose() {
    _cancelTimer();
    Wakelock.disable();
    super.dispose();
  }

  _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  _setTimer() {
    _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      _seconds++;
      try{
        _showTimerState.currentState.refresh(_seconds, _outTime);
      } catch (e) {}
      
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--" + state.toString());
    switch (state) {
      //case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
      //  print('Inactive....');
      //  break;

      case AppLifecycleState.resumed: // 应用程序可见，前台
        if (_countdownTimer == null) {
          _setTimer();
        }
        print(pausedTime);
        if (pausedTime != null) {
          _outTime += DateTime.now().difference(pausedTime).inSeconds;
          pausedTime = null;
        }
        Wakelock.enable();
        print('前台可见');
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        if (_countdownTimer != null) {
          _cancelTimer();
        }
        pausedTime = DateTime.now();
        Wakelock.disable();
        break;
      //case AppLifecycleState.detached: // 申请将暂时暂停
      //  print('detached......');
      // break;
      default: // 申请将暂时暂停
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShowTimer(_showTimerState),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(750),
              margin: EdgeInsets.all(20),
              child: Text(_taskTitle, style: TextStyle(fontSize: 28),),
            ),
            Divider(),
            _buildContentWidget(),
            SizedBox(
              height: ScreenUtil().setHeight(200),
            )
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContentWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        children: <Widget>[
     
          Container(
            width: ScreenUtil().setWidth(750),
            margin: EdgeInsets.only(top: 0),
            child: _buildImages(),
          ),
        ],
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
        source: ImageSource.camera, maxWidth: 1080, maxHeight: 1440, imageQuality: 50);
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
      "id":_taskId,
      "outTime": _outTime,
      "spendTime": _seconds + _outTime,
      "status": "UPLOAD",
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

        Routers.router.navigateTo(context, Routers.taskSubmittedPage, replace: true);
        GlobalEventBus.fireRefreshTodoList();
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  }
}

