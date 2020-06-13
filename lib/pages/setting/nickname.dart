import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/models/user.dart';
import 'package:pupil/states/user_model.dart';
import 'package:pupil/widgets/input.dart';

class NicknameSettingPage extends StatelessWidget {
  final TextEditingController _nickController =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  @override
  Widget build(BuildContext context) {
    _nickController.value = TextEditingValue(text: Global.profile.user.nick);
    return Scaffold(
      appBar: AppBar(
        title: Text('修改昵称'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () {
              print(_nickController.text);
              HttpUtil.getInstance()
                  .put(
                "/api/v1/ums/user/updateNick?nick=" + _nickController.text,
              )
                  .then((val) {
                print(val);
                if (val['code'] == '10000') {
                  User user =
                      Provider.of<UserModel>(context, listen: false).user;
                  user.nick = _nickController.text;
                  Provider.of<UserModel>(context, listen: false).user = user;
                  print(Provider.of<UserModel>(context, listen: false).user);
                  Fluttertoast.showToast(
                      msg: '修改成功', gravity: ToastGravity.CENTER);
                      GlobalEventBus.fireNickChanged();
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
        child: buildInput(_nickController, null, '昵称', false),
      ),
    );
  }
}
