
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';

typedef OnClick = void Function(String val);

List<String> _courses = <String>['语文', '数学', '英语', '其它'];
List<List<String>> _subTypes = <List<String>>[
  ['默写', '背诵', '练习', '试卷', '其它'],
  ['练习','试卷','其它'],
  ['默写', '背诵', '练习', '试卷', '其它'],
  ['家务', '体育', '美术', '音乐', '其它'],
];

Widget buildCourseSelectWidget(String val, Color selectColor, OnClick click) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                '选择课程',
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
              children: _courseWidgets(val, selectColor, click),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget>  _courseWidgets(String val, Color selectColor, OnClick click)  {

    List<Widget> list = List();
    for (String chip in _courses) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            print('click ' + val.toString());
            click(chip);
          },
          selectedColor: selectColor,
          selected: val == chip,
        ),
      ));
    }
    return list;
  }

Widget buildSubTypeSelectWidget(String course, String val, Color selectColor, OnClick click) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                '选择类型',
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
              children: _subTypeWidgets(course, val, selectColor, click),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget>  _subTypeWidgets(String course, String val, Color selectColor, OnClick click)  {

    List<Widget> list = List();
   
    int idx = _courses.indexOf(course);
    if(idx >=0) {
      List<String> types = _subTypes[idx];
      for (String chip in types) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 0, right: 10),
        child: ChoiceChip(
          backgroundColor: Colors.black12,
          label: Text(chip),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.only(left: 10, right: 10),
          onSelected: (val) {
            click(chip);
          },
          selectedColor: selectColor,
          selected: val == chip,
        ),
      ));
    }
    }
    
    return list;
  }