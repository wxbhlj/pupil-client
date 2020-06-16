import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImageEditPage extends StatefulWidget {
  @override
  _ImageEditPageState createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage> {

  var futureNet= ImageLoader.loader.loadImageByProvider(NetworkImage('http://img.shellsports.cn/58-image-1591836367760.png'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图片编辑'),
      ),
      body: FutureBuilder<ui.Image>(
        future: futureNet,
        builder:(context,snapshot)=>CustomPaint(
          painter: ImagePainter(snapshot.data),
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  var _image;
  Paint mainPaint;
  ImagePainter(this._image) {
    mainPaint = Paint()..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_image != null) {
      canvas.drawImage(_image, Offset(0, 0), mainPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ImageLoader {
  ImageLoader._(); //私有化构造
  static final ImageLoader loader = ImageLoader._(); //单例模式

  //通过 文件读取Image
  Future<ui.Image> loadImageByFile(
    String path, {
    int width,
    int height,
  }) async {
    var list = await File(path).readAsBytes();
    return loadImageByUint8List(list, width: width, height: height);
  }

//通过[Uint8List]获取图片,默认宽高[width][height]
  Future<ui.Image> loadImageByUint8List(
    Uint8List list, {
    int width,
    int height,
  }) async {
    ui.Codec codec = await ui.instantiateImageCodec(list,
        targetWidth: width, targetHeight: height);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> loadImageByProvider(
    ImageProvider provider, {
    ImageConfiguration config = ImageConfiguration.empty,
  }) async {
    Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
    ImageStreamListener listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      //监听
      final ui.Image image = frame.image;
      completer.complete(image); //完成
      stream.removeListener(listener); //移除监听
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }
}
