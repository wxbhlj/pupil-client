import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import '../widgets/input.dart';
import '../common/utils.dart';
import '../common/http_util.dart';
import '../models/user.dart';
import '../states/user_model.dart';
import '../common/routers.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phonecontroller =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  final TextEditingController _pwdcontroller =
      TextEditingController.fromValue(TextEditingValue(text: ''));
  FocusNode _pwdFocusNode = FocusNode();

  Timer _countdownTimer;
  String _codeCountdownStr = '获取验证码';
  int _countdownNum = 59;
  String loginType = "L";

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334);
    return Scaffold(
        appBar: AppBar(
          title: Text(loginType == 'R' ? '注册' : '登录'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildLogo(),
              //_buildSelectWorkshop(context),
              _buildInputAccount(),
              _buildInputPassword(),

              _buildLoginButton(context),
              Center(
                child: Text(''),
              ),

              _buildLastRow()
            ],
          ),
        ));
  }

  Widget _buildLogo() {
    return Container(
      margin: EdgeInsets.only(top: 40, bottom: 20),
      height: ScreenUtil().setHeight(164),
      alignment: Alignment.center,

      child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('images/logo.png', )
            ),
      
    );
  }

  Widget _buildInputAccount() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Stack(
        alignment: Alignment(1, 1),
        children: <Widget>[
          buildInput(_phonecontroller, Icons.person_outline,
              loginType == 'L' ? '登录账号' : '手机号码', false),
          Container(
            margin: EdgeInsets.only(bottom: 0),
            child: loginType == 'L' ? Text('') : _sendCodeButton(),
          )
        ],
      ),
    );
  }

  Widget _sendCodeButton() {
    return FlatButton(
      child: Text(
        _codeCountdownStr,
        style: TextStyle(
            color: _countdownTimer != null ? Colors.black12 : Colors.blue),
      ),
      onPressed: () {
        var ptn = _phonecontroller.text;
        if (Utils.isPhoneNumber(ptn)) {
          if (_countdownTimer == null) {
            HttpUtil.getInstance()
                .get("api/v1/auth/sendVerifyCode/" + ptn + "/myfamily")
                .then((val) {
              if (val['code'] == '10000') {
                reGetCountdown();
                FocusScope.of(context).requestFocus(_pwdFocusNode);
              } else {
                Fluttertoast.showToast(
                    msg: val['message'], gravity: ToastGravity.CENTER);
              }
            });
          }
        } else {
          Fluttertoast.showToast(
              msg: '请输入正确的手机号码', gravity: ToastGravity.CENTER);
        }
      },
    );
  }

  void reGetCountdown() {
    setState(() {
      if (_countdownTimer != null) {
        return;
      }
      // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
      _codeCountdownStr = '${_countdownNum--}秒后重新获取';
      _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
        setState(() {
          if (_countdownNum > 0) {
            _codeCountdownStr = '${_countdownNum--}秒后重新获取';
          } else {
            _codeCountdownStr = '获取验证码';
            _countdownNum = 59;
            _countdownTimer.cancel();
            _countdownTimer = null;
          }
        });
      });
    });
  }

  Widget _buildInputPassword() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Stack(
        alignment: Alignment(1, 1),
        children: <Widget>[
          Row(
            children: <Widget>[
              buildIcon(Icons.lock_outline),
              Expanded(
                child: TextField(
                    keyboardType: TextInputType.text,
                    controller: _pwdcontroller,
                    focusNode: _pwdFocusNode,
                    decoration: InputDecoration(
                        hintText: loginType == 'L' ? '密码' : '验证码'),
                    obscureText: loginType == 'L' ? true : false),
              ),
            ],
          ),
          //buildClearButton(_pwdcontroller),
        ],
      ),
    );
  }

  Widget _buildLoginButton(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(100),
      child: RaisedButton(
        child: Text(
          loginType == 'R' ? '注册' : '登录',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _login();
        },
      ),
    );
  }

  Widget _buildLastRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FlatButton(
          child: Text(
            loginType == 'L' ? '短信登录' : '',
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            setState(() {
              loginType = 'F';
            });
          },
        ),
        FlatButton(
          child: Text(
            loginType == 'L' ? '注册账号' : '返回登录',
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            setState(() {
              loginType == 'L' ? loginType = 'R' : loginType = 'L';
            });
          },
        )
      ],
    );
  }

  _login() {
    var code = _pwdcontroller.text;
    /*if(loginType != 'L' && code.length != 4) {
      Fluttertoast.showToast(msg: '请输入4位验证码', gravity: ToastGravity.CENTER);
      return;
    } else*/
     if(loginType == 'L' && code.length < 1) {
      Fluttertoast.showToast(msg: '请输入密码', gravity: ToastGravity.CENTER);
      return;
    }

    var formData = {"code": code, "mobile": _phonecontroller.text};
    print(formData);
    HttpUtil.getInstance()
        .post("api/v1/auth/login", formData: formData)
        .then((val) {
      print(val);
      if (val['code'] == '10000') {

        User user = User.fromJson(val['data']);
        Provider.of<UserModel>(context, listen: false).user = user;
        Routers.router.navigateTo(context, Routers.homePage, replace: true);
    
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }
}
