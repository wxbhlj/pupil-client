import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';
import 'package:pupil/widgets/input.dart';

class MoonCreatePage extends StatefulWidget {
  @override
  _MoonCreatePageState createState() => _MoonCreatePageState();
}

class _MoonCreatePageState extends State<MoonCreatePage> {
  List<String> _moonChips = <String>['很难过', '难过', '一般', '开心', '很开心'];
  String _myMoon = '一般', _dadMoon = '一般', _mumMoon = '一般';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('今日心情'),
      ),
      body: Column(
        children: <Widget>[
          _buildMeWidget(),
          _buildDadWidget(),
          _buildMumWidget()
        ],
      ),
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: ScreenUtil().setWidth(750),
      //height: ScreenUtil().setHeight(230),
      child: _buildSubmitButton(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: ScreenUtil().setWidth(750),
      child: RaisedButton(
        child: Text(
          '保存',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _submit();
        },
      ),
    );
  }

  Widget _buildMeWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                ' 我的心情',
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
              children: _myMoonWidgets.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> get _myMoonWidgets sync* {
    for (String chip in _moonChips) {
      yield Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            setState(() {
              _myMoon = val ? chip : _myMoon;
            });
          },
          selectedColor: Theme.of(context).accentColor,
          selected: _myMoon == chip,
        ),
      );
    }
  }

  Widget _buildDadWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                ' 爸爸心情',
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
              children: _dadMoonWidgets.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> get _dadMoonWidgets sync* {
    for (String chip in _moonChips) {
      yield Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            setState(() {
              _dadMoon = val ? chip : _dadMoon;
            });
          },
          selectedColor: Theme.of(context).accentColor,
          selected: _dadMoon == chip,
        ),
      );
    }
  }

  Widget _buildMumWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                ' 妈妈心情',
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
              children: _mumMoonWidgets.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> get _mumMoonWidgets sync* {
    for (String chip in _moonChips) {
      yield Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            setState(() {
              _mumMoon = val ? chip : _mumMoon;
            });
          },
          selectedColor: Theme.of(context).accentColor,
          selected: _mumMoon == chip,
        ),
      );
    }
  }

  _submit() {
    var formData = {
      "dad": _moonChips.indexOf(_dadMoon) *20 + 20,
      "me": _moonChips.indexOf(_myMoon) *20 + 20,
      "mum": _moonChips.indexOf(_mumMoon) *20 + 20,
      "userId": Global.profile.user.userId
    };
    String url = "/api/v1/ums/moon";

    print(formData);
    HttpUtil.getInstance().post(url, formData: formData).then((val) {

      print(val);
      if (val['code'] == '10000') {
        if(val['message'] == 'update') {
          Fluttertoast.showToast(msg: '操作成功', gravity: ToastGravity.CENTER);
          Navigator.pop(context);
        } else {
           Routers.router.navigateTo(context, Routers.taskSubmittedPage, replace: true);
        }
        
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  }
}
