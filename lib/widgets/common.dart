import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

Widget buildImageWithDel(_image, Function fun) {
  return Stack(
    //fit: StackFit.expand,
    alignment: Alignment.topRight,
    children: <Widget>[
      Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setHeight(165),
        child: ClipRRect(
          child: Image.file(_image, fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      InkWell(
        child: Icon(
          Icons.cancel,
          color: Colors.black45,
        ),
        onTap: () {
          fun();
        },
      )
    ],
  );
}



class SoundWidget extends StatefulWidget {
  final Function function;
  final SelectFile file;
  SoundWidget(this.file, this.function,);
  @override
  _SoundWidgetState createState() => _SoundWidgetState();
}

class _SoundWidgetState extends State<SoundWidget> {
  bool _playing = false;
  AudioPlayer audioPlayer = AudioPlayer();
  StreamSubscription _playerCompleteSubscription;

  @override
  void initState() {
    if (Platform.isIOS) {
        // (Optional) listen for notification updates in the background
        audioPlayer.startHeadlessService();

    
      }
    _playerCompleteSubscription =
        audioPlayer.onPlayerCompletion.listen((event) {
      print('complete');
      setState(() {
        _playing = false;
      });
    });
    super.initState();
  }
  @override
  void dispose() {
    print('dispose ');
    audioPlayer.dispose();
    _playerCompleteSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
    //fit: StackFit.expand,
    alignment: Alignment.topRight,
    children: <Widget>[
      Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setHeight(165),
      
        decoration: new BoxDecoration(
        //背景
        color: Colors.blue,
        //设置四周圆角 角度
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //设置四周边框
        border: new Border.all(width: 1, color: Colors.blue),
        ),
      ),
      InkWell(
        child: Icon(
          Icons.cancel,
          color: Colors.black45,
        ),
        onTap: () {
          widget.function();
        },
      ),
      Positioned(
        left: ScreenUtil().setWidth(65),
        top: ScreenUtil().setHeight(60),
        child: InkWell(
          child: Icon(_playing?Icons.stop:Icons.play_arrow, color: Colors.white,size: 25,),
          onTap: () {
            if(_playing) {
              audioPlayer.stop();
            } else {
              audioPlayer.play(widget.file.file.path, isLocal:true);
              
            }
            setState(() {
              _playing = !_playing;
            });
          },
        ),
      ),
      Positioned(
        left: ScreenUtil().setWidth(50),
        top: ScreenUtil().setHeight(120),
        child: Text(widget.file.duration.substring(2,7), style: TextStyle(color: Colors.white),),
      )
    ],
  );
  }
}

class SelectFile {
  File file;
  String type;
  String duration;

  SelectFile({this.file, this.type, this.duration});
}

