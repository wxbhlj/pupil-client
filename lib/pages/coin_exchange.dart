import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';


import 'package:shared_preferences/shared_preferences.dart';

class CoinExchangePage extends StatefulWidget {


  @override
  _CoinExchangePageState createState() => _CoinExchangePageState();
}

class _CoinExchangePageState extends State<CoinExchangePage> {

  final TextEditingController _titleController =
      TextEditingController.fromValue(TextEditingValue(text: ''));

  final TextEditingController _coinsController =
      TextEditingController.fromValue(TextEditingValue(text: ''));


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text('金币兑换'),
      ),
      body: Column(
        children: <Widget>[
          _buildInputTitle(),
          _buildInputCoins(context),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }


  Widget _buildInputTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.redeem, color: Theme.of(context).accentColor),
              Text(
                ' 兑换内容',
                style: TextStyle(fontWeight: FontWeight.w800),
              )
            ],
          ),
          TextField(
            keyboardType: TextInputType.text,
            controller: _titleController,
            decoration: InputDecoration(hintText: '例如：兑换的物品名称'),
            maxLines: 1,
          )
        ],
      ),
    );
  }

  Widget _buildInputCoins(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.monetization_on, color: Theme.of(context).accentColor),
              Text(
                ' 金币数量',
                style: TextStyle(fontWeight: FontWeight.w800),
              )
            ],
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: _coinsController,
            decoration: InputDecoration(hintText: '需要扣除的金币数量'),
            maxLines: 1,
          )
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(80),
      child: RaisedButton(
        child: Text(
          '完成兑换',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {

  
          String title = _titleController.text;
          if(title.length < 2) {
            Fluttertoast.showToast(
                  msg:'请输入兑换内容', gravity: ToastGravity.CENTER);
            return ;
          }

          String coins = _coinsController.text;
          if(coins.length < 1 || int.parse(coins) < 1) {
            Fluttertoast.showToast(
                  msg:'请输入需要花费的金币', gravity: ToastGravity.CENTER);
            return ;
          }

          var formData = {
            "changeType": 0,
            "coins": "-" + coins,
            "reason": title,
            "userId": Global.profile.user.userId
          };
          HttpUtil.getInstance()
              .post("api/v1/ums/coinsChange/exchange", formData: formData)
              .then((val) {
            print(val);
            if (val['code'] == '10000') {
              GlobalEventBus.fireMemberChanged();
              Navigator.of(context).pop();
            } else {
              Fluttertoast.showToast(
                  msg: val['message'], gravity: ToastGravity.CENTER);
            }
          });
        },
      ),
    );
  }
}
