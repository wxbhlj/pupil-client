import 'dart:io';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

ReceivePort _port = ReceivePort();

class AppInfo {
  AppInfo();

  String version;

  AppInfo.fromJson(Map<String, dynamic> json) : version = json['version'];
}

class CheckUpdate {
  static String _downloadPath = '';
  static String _filename = 'pupil.apk';
  static String _taskId = '';

  check(context) async {
    bool hasNewVersion = await _checkVersion();
    if (!hasNewVersion) {
      return;
    }
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
              title: new Text("发现新版本"), content: _buildDialogContent());
        });
    // 判断系统，ios跳转app store，安卓下载新的apk
  }

  Widget _buildDialogContent() {
    bool download = false;
    double process = 0.0;

    return new StatefulBuilder(builder: (context, StateSetter setState) {
      return Container(
        height: ScreenUtil().setHeight(260),
        child: Column(
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(100),
              child: Center(
              child: !download
                  ? Text('是否要立即更新？', style: TextStyle(fontSize: 16),)
                  : new CircularProgressIndicator(
                      //0~1的浮点数，用来表示进度多少;如果 value 为 null 或空，则显示一个动画，否则显示一个定值
                      value: process,
                      //背景颜色
                      backgroundColor: Colors.yellow,
                      //进度颜色
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.red)),
            ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  child: Text("取消"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                RaisedButton(
                  child: Text("升级", style: TextStyle(color: Colors.white),),
                  color: Theme.of(context).accentColor,
                  onPressed: () async {
                    if (Platform.isIOS) {
                      print('nav to app store for upgrade');
                      Navigator.of(context).pop();
                      // 跳转app store
                    } else if (Platform.isAndroid) {
                      await _prepareDownload();
                      if (_downloadPath.isNotEmpty) {
                        setState((){
                          download = true;
                        });
                        await _download((dynamic data) async {
                          String id = data[0];
                          DownloadTaskStatus status = data[1];
                          int progress = data[2];
                          if (status == DownloadTaskStatus.complete) {
                            // 更新弹窗提示，确认后进行安装
                            OpenFile.open('$_downloadPath/$_filename');

                            print(
                                '==============_installApkz: $_taskId  $_downloadPath /$_filename');
                                Navigator.of(context).pop();
                          }
                          setState((){

                            process = progress/100;
                          });
                          print('....downloading ' + progress.toString());
                        });
                      }
                    }
                  },
                )
              ],
            )
          ],
        ),
      );
    });
  }

  // 下载前的准备
  static Future<void> _prepareDownload() async {
    _downloadPath = (await _findLocalPath()) + '/Download';
    final savedDir = Directory(_downloadPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  // 获取下载地址
  static Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // 检查版本
  Future<bool> _checkVersion() async {
    // 使用请求库dio读取文件服务器存有版本号的json文件
    var res = await Dio()
        .get('http://www.shellsports.cn/version.json')
        .catchError((e) {
      print('获取版本号失败----------' + e);
      return false;
    });
    if (res.statusCode == 200) {
      // 解析json字符串
      AppInfo appInfo = AppInfo.fromJson(res.data);
      // 获取 PackageInfo class
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // 比较版本号
      List<String> oldVersion = packageInfo.version.split('.');
      List<String> newVersion = appInfo.version.split('.');
      if (oldVersion.length != newVersion.length) {
        return true;
      }
      for(var i = 0; i < oldVersion.length; i++) {

        if(int.parse(oldVersion[i]) < int.parse(newVersion[i])) {
          return true;
        } else if(int.parse(oldVersion[i]) > int.parse(newVersion[i])) {
          return false;
        }
      }
    }
    return false;
  }

  // 检查权限
  static Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  // 下载完成之后的回调
  static downloadCallback(id, status, progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  // 下载apk
  static Future<void> _download(Function onData) async {
    final bool _permissionReady = await _checkPermission();
    if (_permissionReady) {
      // final taskId = await downloadApk();
      IsolateNameServer.registerPortWithName(
          _port.sendPort, 'downloader_send_port');
      _port.listen(onData);
      FlutterDownloader.registerCallback(downloadCallback);
      _taskId = await FlutterDownloader.enqueue(
          url: 'http://www.shellsports.cn/pupil.apk',
          savedDir: _downloadPath,
          fileName: _filename,
          showNotification: true,
          openFileFromNotification: true);
    } else {
      print('-----------------未授权');
    }
  }

  // 安装apk
  static Future<void> installApk() async {
    await OpenFile.open('$_downloadPath/$_filename');
  }
}
