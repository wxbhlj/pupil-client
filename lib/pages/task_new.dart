import 'dart:async';

import 'dart:ui';

import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/recorder.dart';
import 'package:wakelock/wakelock.dart';

class TaskNewPage extends StatefulWidget {
  @override
  _TaskNewPageState createState() => _TaskNewPageState();
}

class _TaskNewPageState extends State<TaskNewPage> with WidgetsBindingObserver {
  int _seconds = 0;
  Timer _countdownTimer;
  int _outTime = 0;
  DateTime pausedTime;
  List<SelectFile> files = List();

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

  GlobalKey<_ShowTimerState> _showTimerState = GlobalKey();

  @override
  void initState() {
    super.initState();

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
      _showTimerState.currentState.refresh(_seconds, _outTime);
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
      body: Column(
        children: <Widget>[
          _buildTimer(),
          _buildCourseWidget(),
          _buildTypeWidget(),
          Divider(),
          _buildContentWidget(),
        ],
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
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                ' 作业内容',
                style: TextStyle(fontWeight: FontWeight.w400),
              )
            ],
          ),
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
        {}
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
          return Recorder((path) {
            print("path = " + path);
            files.add(
                SelectFile(file: LocalFileSystem().file(path), type: 'sound'));
            setState(() {
              
            });
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
        onPressed: () {},
      ),
    );
  }

  Widget _buildCourseWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
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

  Widget _buildTypeWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                ' 作业类型',
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
              children: _typeWidgets.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> get _typeWidgets sync* {
    for (String chip in _typeChips) {
      yield Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            setState(() {
              _type = val ? chip : _type;
            });
          },
          selectedColor: Theme.of(context).accentColor,
          selected: _type == chip,
        ),
      );
    }
  }

  Widget _buildTimer() {
    return ShowTimer(_showTimerState);
  }
}

class ShowTimer extends StatefulWidget {
  ShowTimer(Key key) : super(key: key);
  @override
  _ShowTimerState createState() => _ShowTimerState();
}

class _ShowTimerState extends State<ShowTimer> {

  int _seconds = 0;
  int _outTime = 0;

  @override
  Widget build(BuildContext context) {
    String minutes = (_seconds ~/ 60).toString();
    String seconds = (_seconds % 60) < 10
        ? ("0" + (_seconds % 60).toString())
        : (_seconds % 60).toString();

    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQueryData.fromWindow(window).padding.top,
        ),
        child: Container(
          height: ScreenUtil().setHeight(100),
          width: ScreenUtil().setWidth(750),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    '用时 ' + minutes + ':' + seconds,
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  )),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(_outTime > 0
                    ? '离开 ' +
                        (_outTime ~/ 60).toString() +
                        ':' +
                        (_outTime % 60).toString()
                    : ''),
              )
            ],
          ),
        ),
      ),
    );
  }

  refresh(int seconds, int outTime) {
    setState(() {
      this._seconds = seconds;
      this._outTime = outTime;
    });

  }
}