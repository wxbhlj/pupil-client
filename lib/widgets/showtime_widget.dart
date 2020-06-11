import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:pupil/common/utils.dart';

import 'dialog.dart';

class ShowTimer extends StatefulWidget implements PreferredSizeWidget {
  ShowTimer(Key key) : super(key: key);
  @override
  ShowTimerState createState() => ShowTimerState();

  @override
  Size get preferredSize => new Size.fromHeight(ScreenUtil().setHeight(100));
}

class ShowTimerState extends State<ShowTimer> {
  int _seconds = 0;
  int _outTime = 0;

  @override
  Widget build(BuildContext context) {
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
              InkWell(
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  showConfirmDialog(context, '确定不做了吗', () {
                    Navigator.pop(context);
                  });
                },
              ),
              new Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(Utils.formatTime(_seconds),
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  )),
              Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Text(
                    _outTime > 0
                        ? '' +Utils.formatTime(_outTime)
                        : '',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ))
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
