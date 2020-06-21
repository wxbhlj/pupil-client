import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file/local.dart';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pupil/common/global.dart';

import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/common/routers.dart';

import 'package:pupil/widgets/common.dart';
import 'package:pupil/widgets/dialog.dart';

import 'package:pupil/widgets/loading_dlg.dart';
import 'package:pupil/widgets/photo_view.dart';
import 'package:pupil/widgets/recorder.dart';

class TaskReviewDetailPage extends StatefulWidget {
  final String taskId;
  TaskReviewDetailPage(this.taskId);
  @override
  _TaskReviewDetailPageState createState() => _TaskReviewDetailPageState();
}

class _TaskReviewDetailPageState extends State<TaskReviewDetailPage> {
  List<SelectFile> files = List();

  var data;
  @override
  void initState() {
    _getData().then((resp) {
      print("##################");
      print(resp);
      setState(() {
        data = resp['data'];
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: data == null ? Text('') : Text(data['task']['title']),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _buildBody(data),
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: _buildFloatingActionButtion(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFloatingActionButtion(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(230),
      child: Column(
        children: <Widget>[
          buildCameraAndRecordButtons(_selectImage, _record),
          _buildSubmitButton()
        ],
      ),
    );
  }

  _record() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Recorder((path, duration) {
            files.add(SelectFile(
                file: LocalFileSystem().file(path),
                type: 'sound',
                duration: duration));
            setState(() {});
          });
        });
  }

  Future _selectImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1440,
        imageQuality: 50);
    print(image.path);
    files.add(SelectFile(file: image, type: "image"));
    setState(() {});
  }

  Widget _buildSubmitButton() {
    return Container(
      width: ScreenUtil().setWidth(750),
      child: RaisedButton(
        child: Text(
          '完成复习',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          _submit();
        },
      ),
    );
  }

  Future _getData() async {
    return HttpUtil.getInstance().get(
      "api/v1/ums/task/" + widget.taskId.toString(),
    );
  }

  Widget _buildBody(data) {
    if (data == null) {
      return Center(
        child: Text('正在加载...'),
      );
    }
    var task = data['task'];
    var attachments = data['attachments'];

    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Column(
        children: <Widget>[
          _buildAttachment(attachments),
          _buildTimeInfo(task),
          Divider(
            height: ScreenUtil().setHeight(20),
          ),
          _buildContentWidget(),
        ],
      ),
    );
  }

  _buildTimeInfo(task) {
    if (task['outTime'] < 60) {
      return Text('');
    }
    return Container(
      width: ScreenUtil().setWidth(710),
      margin: EdgeInsets.only(
          top: ScreenUtil().setHeight(20), bottom: ScreenUtil().setHeight(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '异常时间' + (task['outTime'] ~/ 60).toString() + "分钟",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachment(attachments) {
    List<Widget> imageList = new List();

    for (var attach in attachments) {
      if (attach['type'] == 'image') {
        imageList.add(_buildImage(attach));
      } else {
        imageList.add(_buildSound(attach));
      }
    }

    return Container(
      width: ScreenUtil().setWidth(750),
      margin: EdgeInsets.only(left: 0, right: 0),
      child: Wrap(
        spacing: 0,
        alignment: WrapAlignment.start,
        children: imageList,
      ),
    );
  }

  Widget _buildImage(attach) {
    print('build image....');
    return InkWell(
      onTap: () {
        Global.prefs.setInt("_attachmentId", attach['id']);
        Global.prefs.setString("_attachmentUrl", attach['url']);
        Routers.router
            .navigateTo(context, Routers.imageEditPage, replace: false);
      },
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 15, top: 10, bottom: 10),
        width: ScreenUtil().setWidth(165),
        height: ScreenUtil().setHeight(165),
        child: ClipRRect(
          child: CachedNetworkImage(
            imageUrl: attach['url'],
            fit: BoxFit.fill,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSound(attach) {
    print('build sound....');
    return InkWell(
      onTap: () {
        {}
      },
      child: SoundWidget2(attach['url']),
    );
  }

  ///////////////////////
  ///
  Widget _buildContentWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              //Icon(Icons.timer, color: Theme.of(context).accentColor),
              Text(
                ' 补充内容',
                style: TextStyle(fontWeight: FontWeight.w400),
              )
            ],
          ),
          Container(
            width: ScreenUtil().setWidth(750),
            margin: EdgeInsets.only(top: 0),
            child: _buildImages2(),
          ),
        ],
      ),
    );
  }

  Widget _buildImages2() {
    List<Widget> imageList = new List();
    if (imageList.length == 0) {
      for (int i = 0; i < files.length; i++) {
        SelectFile file = files[i];
        if (file.type == 'image') {
          imageList.add(_buildImage2(files[i]));
        } else {
          imageList.add(_buildSound2(files[i]));
        }
      }
    }
    return Wrap(
      spacing: 0,
      alignment: WrapAlignment.start,
      children: imageList,
    );
  }

  Widget _buildImage2(SelectFile file) {
    print('build image....');
    return InkWell(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (c, a, s) => PreviewImagesWidget(
                  file.file.path,
                )));
      },
      child: Container(
        child: buildImageWithDel(file.file, () {
          file.file.delete();
          files.remove(file);
          setState(() {});
        }),
      ),
    );
  }

  Widget _buildSound2(SelectFile file) {
    print('build sound....');
    return InkWell(
      onTap: () {
        {}
      },
      child: SoundWidget(file, () {
        file.file.delete();
        files.remove(file);
        setState(() {});
      }),
    );
  }

  ///

  _submit() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: "正在提交...",
          );
        });

    FormData formData = new FormData.fromMap({});

    if (files.length > 0) {
      for (SelectFile file in files) {
        formData.files.add(MapEntry(
          "files",
          MultipartFile.fromFileSync(file.file.path, filename: file.type),
        ));
      }
    }
    String url = "/api/v1/ums/task/reviewed/" + widget.taskId;

    print(formData);
    HttpUtil.getInstance().put(url, formData: formData).then((val) {
      Navigator.pop(context);
      print(val);
      if (val['code'] == '10000') {
        GlobalEventBus.fireRefreshCheckList();
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  }
}
