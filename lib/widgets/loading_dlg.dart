

import 'package:flutter/material.dart';

class LoadingDialog extends Dialog {
  final String text;

  LoadingDialog({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Center(
        child: new SizedBox(
          width: 120.0,
          height: 120.0,
          child: new Container(
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
                new Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: new Text(text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class ConfirmDialog extends Dialog {
   ConfirmDialog(
       {Key key,
       this.title,
       // 取消事件回调
       this.cancelCallBack,
       // 确定事件回调
       this.okCallback})
       : super(key: key);
   final String title;
   final cancelCallBack;
   final okCallback;
 
   @override
   Widget build(BuildContext context) {
     return WillPopScope(
       //  屏蔽安卓的手机返回键
       onWillPop: () async {
         return Future.value(false);
       },
       child: AlertDialog(
         title: Text(title ),
         actions: <Widget>[
           FlatButton(
             child: Text('Cancel'),
             onPressed: () {
               Navigator.pop(context, false);
               if (cancelCallBack != null) {
                 cancelCallBack();
               }
             },
           ),
           FlatButton(
             child: Text('OK'),
             onPressed: () {
               Navigator.pop(context, true);
               if (okCallback != null) {
                 okCallback();
               }
             },
           ),
         ],
       ),
     );
   }
 }
