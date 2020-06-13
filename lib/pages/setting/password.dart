import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/models/user.dart';
import 'package:pupil/states/user_model.dart';
import 'package:pupil/widgets/input.dart';

class PasswordSettingPage extends StatelessWidget {
  final TextEditingController _pwd1Controller =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  final TextEditingController _pwd2Controller =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('设置密码'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () {
              if(_pwd1Controller.text.length < 4) {
                Fluttertoast.showToast(
                      msg: '密码长度最少4位', gravity: ToastGravity.CENTER);
                return;
              }
              if(_pwd1Controller.text != _pwd2Controller.text) {
                Fluttertoast.showToast(
                      msg: '两次密码不一直', gravity: ToastGravity.CENTER);
                return;
              }
              HttpUtil.getInstance()
                  .put(
                "/api/v1/ums/user/updatePwd?pwd=" + _pwd1Controller.text,
              )
                  .then((val) {
                print(val);
                if (val['code'] == '10000') {
                  User user =
                      Provider.of<UserModel>(context, listen: false).user;
                  user.nick = _pwd1Controller.text;
                  Provider.of<UserModel>(context, listen: false).user = user;
                  print(Provider.of<UserModel>(context, listen: false).user);
                  Fluttertoast.showToast(
                      msg: '修改成功', gravity: ToastGravity.CENTER);
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                      msg: val['message'], gravity: ToastGravity.CENTER);
                }
              });
            },
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            buildInput(_pwd1Controller, null, '密码', true),
            buildInput(_pwd2Controller, null, '重复密码', true),
          ],
        ),
      ),
    );
  }
}
