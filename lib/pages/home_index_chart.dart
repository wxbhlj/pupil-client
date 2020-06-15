import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';

class LineChartWidget extends StatefulWidget {
  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {

  List<FlSpot> scoreList = List();
  List<FlSpot> timeList = List();
  List<String> xList = List();

  @override
  void initState() {
    _getLineData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return _buildLineChart();
  }

   _getLineData() {
    HttpUtil.getInstance()
        .get("api/v1/ums/task/lineChart?status=CHECKED&userId=" + Global.profile.user.userId.toString(), ).then((resp) {
          print(resp);
          double idx = 0;
          for(var item in resp['data']) {
            scoreList.insert(0,FlSpot(idx, item['score']/item['count']));
            timeList.insert(0,FlSpot(idx, item['spendTime']/60/60*20));
            //print(item['spendTime']/item['count']/60/60*20);
            xList.insert(0,item['key']);
            idx ++;
            setState(() {
              
            });
          }
        });
  }

  Widget _buildLineChart() {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        margin: EdgeInsets.only(
            left: 10,
            right: 10,
            top: MediaQueryData.fromWindow(window).padding.top),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).accentColor,
              Colors.white38,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('评分', style: TextStyle(fontSize: 16, color: Color(0xff4af699), ),),
                Text('用时', style: TextStyle(fontSize: 16, color: Color(0xffaa4cfc), ),)
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                child: scoreList.length == 0?Center(child: Text('没有数据')):LineChart(
                  sampleData1(),
                  swapAnimationDuration: const Duration(milliseconds: 250),
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
      
            if(value < xList.length) {
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
              case 0:
                return '0';
              case 20:
                return '20';
              case 40:
                return '40';
              case 60:
                return '60';
              case 80:
                return '80';
              case 100:
                return '100';
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
              case 0:
                return '0小时';
              case 20:
                return '1小时';
              case 40:
                return '2小时';
              case 60:
                return '3小时';
              case 80:
                return '4小时';
              case 100:
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
     
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: scoreList,
      isCurved: true,
      colors: [
        const Color(0xff4af699),
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
        const Color(0xffaa4cfc),
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