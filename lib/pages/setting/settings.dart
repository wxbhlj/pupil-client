import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/global_event.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/models/user.dart';

import '../../widgets/list_memu_item.dart';
import '../../widgets/dialog.dart';
import '../../states/user_model.dart';
import '../../common/routers.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _image;
  var _eventSubscription;
  @override
  void initState() {
    _registerEvent();
    super.initState();
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    super.dispose();
  }

  _registerEvent() {
    _eventSubscription =
        GlobalEventBus().event.on<CommonEventWithType>().listen((event) {
      print("onEvent:" + event.eventType);
      if (event.eventType == EVENT_NICK_CHANGED) {
        setState(() {
          
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: Column(
        children: <Widget>[
          _buildAvatar2(),
          _nickSetting(),
          _pwdSetting(),
          SizedBox(
            height: ScreenUtil().setHeight(40),
          ),
          _themeColor(),
          _logout(),
        ],
      ),
    );
  }

  Widget _themeColor() {
    return buildListMenuItem(context, Icons.color_lens, '主题颜色', () {
      Routers.router
          .navigateTo(context, Routers.themeSettingPage, replace: false);
    });
  }

  Widget _nickSetting() {
    return buildListMenuItem(context, Icons.person, '修改昵称', () {
      Routers.router
          .navigateTo(context, Routers.nicknameSettingPage, replace: false);
    }, title2: Global.profile.user.nick);
  }

  Widget _pwdSetting() {
    return buildListMenuItem(
      context,
      Icons.lock,
      '登录密码',
      () {
        Routers.router
            .navigateTo(context, Routers.passwordSettingPage, replace: false);
      },
    );
  }

  Widget _logout() {
    return buildListMenuItem(context, Icons.exit_to_app, '退出登录', () {
      showConfirmDialog(
        context,
        '确定要退出吗',
        () {
          Provider.of<UserModel>(context, listen: false).user = null;
          exit(0);
        },
      );
    }, title2: '');
  }

  Widget _buildAvatar2() {
    return Container(

      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
      padding: EdgeInsets.only(top: 20, bottom: 20),
      child: ListTile(
        leading: _buildImage(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(''),
            ),
            Text(
              '修改头像',
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          _selectImage();
        },
      ),
    );
  }

  Widget _buildImage() {
    User user = Global.profile.user;
    print("avatar = " + user.avatar);
    if (_image != null) {
      return ClipRRect(
        child: Image.file(_image),
        borderRadius: BorderRadius.circular(6),
      );
    } else {
      return user.avatar != null && user.avatar.length > 0
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: user.avatar,
                fit: BoxFit.fill,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            )
          : Icon(
              Icons.account_box,
              size: ScreenUtil().setWidth(156),
            );
    }
  }

  Future _selectImage() async {
    var imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 480, maxHeight: 720);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                //CropAspectRatioPreset.ratio3x2,
                //CropAspectRatioPreset.original,
                //CropAspectRatioPreset.ratio4x3,
                //CropAspectRatioPreset.ratio16x9
              ]
            : [
                //CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                /*CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9*/
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '剪切头像',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
            title: '剪切头像',
            minimumAspectRatio: 1.0,
            rectX: 0.0,
            rectY: 0.0,
            rectWidth: 320.0,
            rectHeight: 320.0,
            cancelButtonTitle: '取消',
            doneButtonTitle: '确定'));
    if (croppedFile != null) {
      setState(() {
        _image = croppedFile;
        _updateAvatar();
      });
    }
  }

  _updateAvatar() {
    FormData formData = new FormData.fromMap({});
    String url = "/api/v1/ums/user/updateAvatar/";

    formData.files.add(MapEntry(
      "file",
      MultipartFile.fromFileSync(_image.path, filename: "aa.png"),
    ));

    print(formData);
    HttpUtil.getInstance().post(url, formData: formData).then((val) {
      print(val);
      if (val['code'] == '10000') {
        User user = Provider.of<UserModel>(context, listen: false).user;
        user.avatar = val['data']['avatar'];
        Provider.of<UserModel>(context, listen: false).user = user;
        Fluttertoast.showToast(msg: '上传成功', gravity: ToastGravity.CENTER);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: val['message'], gravity: ToastGravity.CENTER);
      }
    });
  }
}
