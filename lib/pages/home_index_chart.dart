import 'dart:convert';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/utils.dart';

class LineChartWidget extends StatefulWidget {
  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<FlSpot> scoreList1 = List();
  List<FlSpot> scoreList2 = List();
  List<FlSpot> scoreList3 = List();

  List<String> xList = List();
  Map course = Map();

  @override
  void initState() {
    _getLineData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_buildLineChart()],
    );
  }

  _getLineData() {
    String str = Global.prefs
        .getString("_chart_data_" + Global.profile.user.userId.toString());
    if (str != null && str.length > 0) {
      var resp = jsonDecode(str);
      int dfTime = DateTime.now().millisecondsSinceEpoch -
          int.parse(resp['date'].toString());
      print("dfTime = " + (dfTime / 1000 / 60).toString());
      if (dfTime < 1000 * 60 * 60 * 12 && resp['code'] == '10000') {
        print('#########################return');
        _parseResp(resp);
        return;
      }
    }
    HttpUtil.getInstance()
        .get(
      "api/v1/ums/task/chart/home?userId=" +
          Global.profile.user.userId.toString(),
    )
        .then((resp) {
      if (resp['code'] == '10000') {
        resp['date'] = DateTime.now().millisecondsSinceEpoch;
        Global.prefs.setString(
            "_chart_data_" + Global.profile.user.userId.toString(),
            jsonEncode(resp));
        _parseResp(resp);
      }
    });
  }

  _parseResp(var resp) {
    print(resp['data']['yuwendata']);
    print(resp['data']['date']);
    double idx = 0;

    for (var item in resp['data']['date']) {
      xList.insert(0, item);
      idx++;
    }
    idx = 0;
    for (var item in resp['data']['yuwendata']) {
      scoreList1.add(FlSpot(xList.indexOf(item['key']).toDouble(),
          item['score'] / item['count'] / 20));
      idx++;
    }
    idx = 0;
    for (var item in resp['data']['shuxuedata']) {
      scoreList2.add(FlSpot(xList.indexOf(item['key']).toDouble(),
          item['score'] / item['count'] / 20));
      idx++;
    }
    idx = 0;
    for (var item in resp['data']['yingyudata']) {
      scoreList3.add(FlSpot(xList.indexOf(item['key']).toDouble(),
          item['score'] / item['count'] / 20));
      idx++;
    }
    idx = 0;
    xList.clear();
    for (var item in resp['data']['date']) {
      xList.insert(0, item);
      idx++;
    }
    print("#################" +
        scoreList1.length.toString() +
        "," +
        scoreList2.length.toString() +
        "," +
        scoreList3.length.toString() +
        "," +
        xList.length.toString());

    course['yuwen'] =
        _calScore(resp['data']['yuwen'], resp['data']['yuwen_count']);
    course['shuxue'] =
        _calScore(resp['data']['shuxue'], resp['data']['shuxue_count']);
    course['yingyu'] =
        _calScore(resp['data']['yingyu'], resp['data']['yingyu_count']);
    setState(() {});
  }

  double _calScore(int total, int item) {
    if (item == 0) {
      return 0;
    } else
      return (total / item / 20 * 100).toInt() / 100;
  }
  /*
  Widget _buildBarChart() {
    return AspectRatio(
        aspectRatio: 2,
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 15),
          padding: EdgeInsets.only(top: 25),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(18)),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).accentColor.withOpacity(0.3),
                Theme.of(context).accentColor.withOpacity(0.0),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: course.length < 3
              ? Center(
                  child: Text('????????????'),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 5,
                    barTouchData: BarTouchData(
                      enabled: false,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        tooltipPadding: const EdgeInsets.all(0),
                        tooltipBottomMargin: 0,
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          return BarTooltipItem(
                            rod.y.toString(),
                            TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        textStyle: TextStyle(
                            color: const Color(0xff7589a2), fontSize: 14),
                        margin: 10,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return '??????';
                            case 1:
                              return '??????';
                            case 2:
                              return '??????';

                            default:
                              return '';
                          }
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                            y: course['yuwen'],
                            color: Utils.courseColor(course['yuwen']),
                            width: 30,
                            borderRadius: BorderRadius.circular(6))
                      ], showingTooltipIndicators: [
                        0
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            y: course['shuxue'],
                            color: Utils.courseColor(course['yuwen']),
                            width: 30,
                            borderRadius: BorderRadius.circular(6))
                      ], showingTooltipIndicators: [
                        0
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            y: course['yingyu'],
                            color: Utils.courseColor(course['yuwen']),
                            width: 30,
                            borderRadius: BorderRadius.circular(6))
                      ], showingTooltipIndicators: [
                        0
                      ]),
                    ],
                  ),
                ),
        ));
  }*/

  Widget _buildLineChart() {
    return AspectRatio(
      aspectRatio: 2,
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 15),
        padding: EdgeInsets.only(top: 25),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).accentColor.withOpacity(0.3),
              Theme.of(context).accentColor.withOpacity(0.0),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                    child: scoreList1.length == 0
                        ? Center(child: Text('????????????'))
                        : LineChart(
                            sampleData1(),
                            swapAnimationDuration:
                                const Duration(milliseconds: 250),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            Positioned(
              bottom: ScreenUtil().setHeight(90),
              right: 10,
              child: Container(
                width: ScreenUtil().setWidth(500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('????????? ',
                        style: TextStyle(color: Colors.black38, fontSize: 11)),
                    Text(' ??????:' + course['yuwen'].toString(),
                        style: TextStyle(color: Colors.red, fontSize: 11)),
                    Text(' ??????:' + course['shuxue'].toString(),
                        style: TextStyle(color: Colors.orange, fontSize: 11)),
                    Text(' ??????:' + course['yingyu'].toString(),
                        style: TextStyle(color: Colors.blue, fontSize: 11))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.5),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
        fullHeightTouchLine: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
          y: 4,
          color: Colors.green.withOpacity(0.1),
          strokeWidth: 1,
          dashArray: [2, 2],
        ),
      ]),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: const TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          margin: 10,
          getTitles: (value) {
            if (value < xList.length) {
              //print(value.toString() + "  - " + xList.length.toString());
              return ((value % 3 == 0 || value == xList.length - 1) &&
                      value != xList.length - 2)
                  ? xList[value.toInt()]
                  : '';
              //return xList[value.toInt()];
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1';
              case 2:
                return '2';
              case 3:
                return '3';
              case 4:
                return '4';
              case 5:
                return '5';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          left: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      maxY: 5,
      minY: 0,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    List<LineChartBarData> list = List();
    if (scoreList1.length > 0) {
      final LineChartBarData lineChartBarData1 = LineChartBarData(
        spots: scoreList1,
        isCurved: true,
        colors: [Colors.red],
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      );
      list.add(lineChartBarData1);
    }
    if (scoreList2.length > 0) {
      final LineChartBarData lineChartBarData2 = LineChartBarData(
        spots: scoreList2,
        isCurved: true,
        colors: [
          Colors.orange,
        ],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(show: false, colors: [
          const Color(0x00aa4cfc),
        ]),
      );
      list.add(lineChartBarData2);
    }

    if (scoreList3.length > 0) {
      final LineChartBarData lineChartBarData3 = LineChartBarData(
        spots: scoreList3,
        isCurved: true,
        colors: [
          Colors.blue,
        ],
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(show: false, colors: [
          const Color(0x00aa4cfc),
        ]),
      );
      list.add(lineChartBarData3);
    }
    print(list.length.toString() + " = list.size");
    return list;
  }
}
