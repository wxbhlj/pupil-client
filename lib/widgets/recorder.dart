import 'dart:async';
import 'dart:io';

import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pupil/common/routers.dart';

typedef OnFinished = void Function(String path);

class Recorder extends StatefulWidget {
  final OnFinished _onFinished;
  Recorder(this._onFinished);

  @override
  _RecorderState createState() => _RecorderState(_onFinished);
}

class _RecorderState extends State<Recorder> {
  OnFinished onFinished;
  _RecorderState(this.onFinished);

  bool _isRecording = false;
  int _seconds = 0;
  Timer _countdownTimer;

  FlutterAudioRecorder _recorder;
 
  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(380),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isRecording) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_formatTime()),
          InkWell(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
              child: Image.asset(
                'images/stop.png',
                width: ScreenUtil().setWidth(128),
              ),
            ),
            onTap: () {
              _stop();
              _cancelTimer();
              setState(() {
                _isRecording = false;
              });
            },
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('点击开始录音, 最长5分钟'),
          InkWell(
            child: Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
              child: Image.asset(
                'images/record.png',
                width: ScreenUtil().setWidth(128),
              ),
            ),
            onTap: () {
              _start();
            },
          )
        ],
      );
    }
  }

  String _formatTime() {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    return (minutes < 10 ? "0" + minutes.toString() : minutes.toString()) +
        ":" +
        (seconds < 10 ? "0" + seconds.toString() : seconds.toString());
  }

  _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  _setTimer() {
    _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder = FlutterAudioRecorder(customPath,
            audioFormat: AudioFormat.AAC, sampleRate: 8000);

        await _recorder.initialized;
      } else {
        Scaffold.of(context)
            .showSnackBar(new SnackBar(content: new Text("需要授权")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      await _recorder.start();
      _setTimer();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = LocalFileSystem().file(result.path);
    print("File length: ${await file.length()}");
    Routers.router.pop(context);
    onFinished(result.path);

  }
}
