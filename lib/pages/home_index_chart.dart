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
  List<FlSpot> scoreList = List();
  List<FlSpot> timeList = List();
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
      children: <Widget>[_buildLineChart(), _buildBarChart()],
    );
  }

  _getLineData() {
    String str = Global.prefs.getString("_chart_data");
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
      "api/v1/ums/task/lineChart?status=CHECKED&userId=" +
          Global.profile.user.userId.toString(),
    )
        .then((resp) {
      if (resp['code'] == '10000') {
        resp['date'] = DateTime.now().millisecondsSinceEpoch;
        Global.prefs.setString("_chart_data", jsonEncode(resp));
        _parseResp(resp);
      }
    });
  }

  _parseResp(var resp) {
    print(resp);
    double idx = 0;
    for (var item in resp['data']['list']) {
      scoreList.add(FlSpot(resp['data']['list'].length - idx - 1,
          item['score'] / item['count'] / 20));
      timeList.add(FlSpot(resp['data']['list'].length - idx - 1,
          (item['spendTime'] / 60 / 60 * 100).toInt() / 100));

      xList.insert(0, item['key']);
      idx++;
    }
    course['yuwen'] =
        (resp['data']['yuwen'] / resp['data']['yuwen_count'] / 20 * 100)
                .toInt() /
            100;
    course['shuxue'] =
        (resp['data']['shuxue'] / resp['data']['shuxue_count'] / 20 * 100)
                .toInt() /
            100;
    course['yingyu'] =
        (resp['data']['yingyu'] / resp['data']['yingyu_count'] / 20 * 100)
                .toInt() /
            100;
    setState(() {});
  }

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
                Theme.of(context).accentColor,
                Theme.of(context).accentColor.withOpacity(0.1),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: course.length < 3
              ? Center(
                  child: Text('加载数据...'),
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
                              color: Utils.fanse(Theme.of(context).accentColor),
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
                              return '语文';
                            case 1:
                              return '数学';
                            case 2:
                              return '英语';

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
                            color: Utils.fanse(Theme.of(context).accentColor),
                            width: 30,
                            borderRadius: BorderRadius.circular(6))
                      ], showingTooltipIndicators: [
                        0
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            y: course['shuxue'],
                            color: Utils.fanse(Theme.of(context).accentColor),
                            width: 30,
                            borderRadius: BorderRadius.circular(6))
                      ], showingTooltipIndicators: [
                        0
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            y: course['yingyu'],
                            color: Utils.fanse(Theme.of(context).accentColor),
                            width: 30,
                            borderRadius: BorderRadius.circular(6))
                      ], showingTooltipIndicators: [
                        0
                      ]),
                    ],
                  ),
                ),
        ));
  }

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
              Theme.of(context).accentColor,
              Theme.of(context).accentColor.withOpacity(0.2),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                child: scoreList.length == 0
                    ? Center(child: Text('没有数据'))
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
      ),
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: false,
      ),
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
              return xList[value.toInt()];
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
                return '1星';

              case 3:
                return '3星';

              case 5:
                return '5星';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
        rightTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '1小时';

              case 3:
                return '3小时';

              case 5:
                return '5小时';
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
            color: Colors.transparent,
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
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: scoreList,
      isCurved: true,
      colors: [
        Utils.fanse(Theme.of(context).accentColor),
      ],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    final LineChartBarData lineChartBarData2 = LineChartBarData(
      spots: timeList,
      isCurved: true,
      colors: [
        Colors.grey,
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
    return [
      lineChartBarData1,
      lineChartBarData2,
    ];
  }
}
