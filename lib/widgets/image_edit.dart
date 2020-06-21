import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pupil/common/global.dart';
import 'package:pupil/common/http_util.dart';
import 'package:pupil/widgets/dialog.dart';
import 'package:path/path.dart' as path;

import 'common.dart';

class ImageEditPage extends StatefulWidget {
  ImageEditPage();
  @override
  _ImageEditPageState createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage>
    with TickerProviderStateMixin {
  //var futureNet = ImageLoader.loader.loadImageByProvider(
  //    NetworkImage('http://img.shellsports.cn/58-image-1591836367760.png'));

  final GlobalKey<_ScalableImageState> globalKey = GlobalKey();

  int id;
  int taskId;
  String url;
  bool _isDraw = false;

  @override
  void initState() {
    taskId = Global.prefs.getInt("_taskId");
    id = Global.prefs.getInt("_attachmentId");
    url = Global.prefs.getString("_attachmentUrl");
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          ScalableImage(
            key: globalKey,
            imageProvider: CachedNetworkImageProvider(url),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: InkWell(
              child: assertImage("images/back.png"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: IconButton(
              icon: Icon(
                Icons.gesture,
                color: _isDraw ? Colors.yellow : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isDraw = globalKey.currentState.setDrawModel();
                });
              },
            ),
          ),
          Positioned(
            left: 70,
            bottom: 20,
            child: IconButton(
              icon: Icon(
                Icons.zoom_out_map,
                color: !_isDraw ? Colors.yellow : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isDraw = globalKey.currentState.setMoveModel();
                });
              },
            ),
          ),
          Positioned(
            left: 120,
            bottom: 20,
            child: IconButton(
              icon: Icon(
                Icons.undo,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  globalKey.currentState.undo();
                });
              },
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              icon: Icon(
                Icons.save,
                color: Colors.lightGreen,
              ),
              onPressed: () {
                setState(() {
                  showConfirmDialog(context, '保存并覆盖现有图片吗', () async {
                    ui.Image renderedImage =
                        await globalKey.currentState.rendered; // 转成图片
                    var image = renderedImage;
                    Directory appDocDir =
                        await getApplicationDocumentsDirectory();
                    String appDocPath = appDocDir.path;
                    var pngBytes =
                        await image.toByteData(format: ui.ImageByteFormat.png);
                    final imageFile = File(path.join(appDocPath, 'dart.png'));
                    await imageFile
                        .writeAsBytesSync(pngBytes.buffer.asInt8List());

                    FormData formData = new FormData.fromMap({});

                    formData.files.add(MapEntry(
                      "files",
                      MultipartFile.fromFileSync(imageFile.path,
                          filename: 'image'),
                    ));

                    String url =
                        "/api/v1/ums/task/reviewed/" + taskId.toString();

                    print(formData);
                    HttpUtil.getInstance()
                        .put(url, formData: formData)
                        .then((val) {
                      Navigator.pop(context);
                      print(val);
                      if (val['code'] == '10000') {
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                            msg: val['message'], gravity: ToastGravity.CENTER);
                      }
                    });

                    //FormData formData =FormData.from({"image": UploadFileInfo(imageFile, 'image.jpg')});
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}

class ScalableImage extends StatefulWidget {
  const ScalableImage(
      {Key key,
      @required ImageProvider imageProvider,
      double maxScale,
      double dragSpeed,
      Size size,
      bool wrapInAspect,
      bool enableScaling})
      : assert(imageProvider != null),
        this._imageProvider = imageProvider,
        assert((maxScale ?? 4.0) > 1.0),
        this._maxScale = maxScale ?? 4.0,
        this._dragSpeed = dragSpeed ?? 8.0,
        this._size = size ?? const Size.square(double.infinity),
        super(key: key);

  final ImageProvider _imageProvider;
  final double _maxScale, _dragSpeed;
  final Size _size;

  @override
  _ScalableImageState createState() => new _ScalableImageState();
}

class _ScalableImageState extends State<ScalableImage> {
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  double _scale = 1.0;
  double _lastEndScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _lastFocalPoint;
  Size _imageSize;
  Offset _targetPointPixelSpace;
  Offset _targetPointDrawSpace;

  List<Offset> _points = <Offset>[];
  List<Offset> _undoPoints = <Offset>[];
  bool _isDraw = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(ScalableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._imageProvider != oldWidget._imageProvider) _getImage();
  }

  void _getImage() {
    final ImageStream oldImageStream = _imageStream;
    _imageStream =
        widget._imageProvider.resolve(createLocalImageConfiguration(context));
    if (_imageStream.key != oldImageStream?.key) {
      oldImageStream?.removeListener(ImageStreamListener(_updateImage));
      _imageStream.addListener(ImageStreamListener(_updateImage));
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
      _imageSize = _imageInfo == null
          ? null
          : new Size(_imageInfo.image.width.toDouble(),
              _imageInfo.image.height.toDouble());
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  //////////////////////////////////
  bool setDrawModel() {
    _isDraw = !_isDraw;
    setState(() {});
    return _isDraw;
  }

  bool setMoveModel() {
    _isDraw = false;
    setState(() {});
    return false;
  }

  undo() {
    if (_undoPoints.length != 0) {
      Offset of = _undoPoints.removeLast();
      for (int i = 0; i < 1000; i++) {
        Offset aa = _points.removeLast();
        if (aa == of) {
          return;
        }
      }
    }
  }

  Future<ui.Image> get rendered {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    _ScalableImagePainter painter = new _ScalableImagePainter(
          _imageInfo.image, _offset, _scale, _points, _imageSize, context);

    painter.paint(canvas, _imageSize);
    return recorder
        .endRecording()
        .toImage(_imageSize.width.floor(), _imageSize.height.floor());
  }
  //////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_imageInfo == null) {
      return new Container(
          alignment: Alignment.center,
          child: new FractionallySizedBox(
              widthFactor: 0.1,
              child: new AspectRatio(
                  aspectRatio: 1.0, child: new CircularProgressIndicator())));
    } else {
      Widget painter = new CustomPaint(
        size: widget._size,
        painter: new _ScalableImagePainter(
            _imageInfo.image, _offset, _scale, _points, _imageSize, context),
        willChange: true,
      );

      painter = Center(
        child: new AspectRatio(
            aspectRatio: _imageSize.width / _imageSize.height, child: painter),
      );

      //painter = new AspectRatio(
      //    aspectRatio: _imageSize.width / _imageSize.height, child: painter);

      return GestureDetector(
        child: painter,
        onDoubleTap: () {
          print('double press....');
          setState(() {
            _isDraw = !_isDraw;
          });
        },
        onScaleUpdate: _isDraw ? null : _handleScaleUpdate,
        onScaleEnd: _isDraw ? null : _handleScaleEnd,
        onScaleStart: _isDraw ? null : _handleScaleStart,
        onPanStart: !_isDraw
            ? null
            : (DragStartDetails details) {
                setState(() {
                  _points = new List.from(_points)
                    ..add((_toPaintOffset(details.globalPosition)));
                  _undoPoints.add(_toPaintOffset(details.globalPosition));
                });
              },
        onPanUpdate: !_isDraw
            ? null
            : (DragUpdateDetails details) {
                setState(() {
                  _points = new List.from(_points)
                    ..add((_toPaintOffset(details.globalPosition)));
                });
              },
        onPanEnd:
            !_isDraw ? null : (DragEndDetails details) => _points.add(null),
      );
    }
  }

  Offset _toPaintOffset(Offset globalPosition) {
    double height = context.size.width * _imageSize.height / _imageSize.width;

    Size contextSize = Size(context.size.width, height);

    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(globalPosition);

    var targetPointDrawSpace =
        (context.findRenderObject() as RenderBox).globalToLocal(localPosition);
    /*
                  print("MediaQuery.of(context).size = " + MediaQuery.of(context).size.toString());
                  print("context.size = " + context.size.toString());
                  print("contextSize = " + contextSize.toString());

                  print("_offset = " + _offset.toString());

                  print('details.globalPosition=' + details.globalPosition.toString() + ", ");
                  print("localPosition = " + localPosition.toString());
                  print("targetPointDrawSpace = " + targetPointDrawSpace.toString());
                  print("targetPointPixelSpace ="  + targetPointPixelSpace.toString());*/
    return drawSpaceToPixelSpace(
        targetPointDrawSpace -
            Offset(0, (MediaQuery.of(context).size.height - height) / 2),
        //context.size,
        contextSize,
        _offset,
        _imageSize,
        _scale);
  }

  void _handleScaleStart(ScaleStartDetails start) {
    _lastFocalPoint = start.focalPoint;
    _targetPointDrawSpace = (context.findRenderObject() as RenderBox)
        .globalToLocal(start.focalPoint);
    _targetPointPixelSpace = drawSpaceToPixelSpace(
        _targetPointDrawSpace, context.size, _offset, _imageSize, _scale);
  }

  void _handleScaleEnd(ScaleEndDetails end) {
    _lastEndScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails event) {
    //init old values
    double newScale = _scale;
    Offset newOffset = _offset;

    if (event.scale == 1.0) {
      //This is a movement
      //Calculate movement since last call
      Offset delta =
          (_lastFocalPoint - event.focalPoint) * widget._dragSpeed / _scale;
      //Store the new information
      _lastFocalPoint = event.focalPoint;

      //And move it
      newOffset += delta;
    } else {
      //Round the scale to three points after comma to prevent shaking
      double roundedScale = _roundAfter(event.scale, 3);
      //Calculate new scale but do not scale to far out or in
      newScale = min(widget._maxScale, max(1.0, roundedScale * _lastEndScale));
      //Move the offset so that the target point stays at the same position after scaling
      newOffset = _elementwiseDivision(
              _targetPointDrawSpace,
              -_linearTransformationFactor(
                  context.size, _imageSize, newScale)) +
          _targetPointPixelSpace;
    }
    //Don't move to far left
    newOffset = _elementwiseMax(newOffset, Offset.zero);
    //Nor to far right
    double borderScale = 1.0 - 1.0 / newScale;
    newOffset = _elementwiseMin(newOffset, _asOffset(_imageSize * borderScale));
    if (newScale != _scale || newOffset != _offset) {
      setState(() {
        _scale = newScale;
        _offset = newOffset;
      });
    }
  }
}

class _ScalableImagePainter extends CustomPainter {
  final ui.Image _image;
  //final Paint _paint;
  final Rect _rect;
  final double scale;
  final Offset _offset;
  Paint mainPaint;
  final List<Offset> points;
  final BuildContext context;

  final Size imageSize;

  _ScalableImagePainter(this._image, this._offset, this.scale, this.points,
      this.imageSize, this.context)
      : this._rect = new Rect.fromLTWH(_offset.dx, _offset.dy,
            _image.width.toDouble() / scale, _image.height.toDouble() / scale),
        mainPaint = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    double width, height;
    if (_image.width / _image.height > size.width / size.height) {
      width = size.width;
      height = size.width * _image.height / _image.width;
    } else {
      height = size.height;
      width = size.height * _image.width / _image.height;
    }
    print("size = " + size.toString());
    print("MediaQuery.of(context).size = " +
        (MediaQuery.of(context).size.toString()));

    canvas.drawImageRect(_image, _rect,
        new Rect.fromLTWH(0.0, 0.0, size.width, size.height), mainPaint);

    Paint paint = new Paint() //设置笔的属性
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.bevel;

    for (int i = 0; i < points.length - 1; i++) {
      //画线
      if (points[i] != null && points[i + 1] != null)
        canvas.drawLine(_pointToImage(points[i]), _pointToImage(points[i + 1]),
            paint); //drawLine(Offset p1, Offset p2, Paint paint) → void
    }
  }

  Offset _pointToImage(Offset offset) {
    return pixelSpaceToDrawSpace(
        offset,
        Size(ScreenUtil().setWidth(750),
            ScreenUtil().setHeight(750 * imageSize.height / imageSize.width)),
        _offset,
        imageSize,
        scale);
  }

  @override
  bool shouldRepaint(_ScalableImagePainter oldDelegate) {
    return _rect != oldDelegate._rect ||
        _image != oldDelegate._image ||
        oldDelegate.points != points;
  }
}

Offset _linearTransformationFactor(
    Size drawSpaceSize, Size imageSize, double scale) {
  return new Offset(drawSpaceSize.width / (imageSize.width / scale),
      drawSpaceSize.height / (imageSize.height / scale));
}

Offset pixelSpaceToDrawSpace(Offset pixelSpace, Size drawSpaceSize,
    Offset offset, Size imageSize, double scale) {
  return _elementwiseMultiplication(pixelSpace - offset,
      _linearTransformationFactor(drawSpaceSize, imageSize, scale));
}

Offset drawSpaceToPixelSpace(Offset drawSpace, Size drawSpaceSize,
    Offset offset, Size imageSize, double scale) {
  return _elementwiseDivision(drawSpace,
          _linearTransformationFactor(drawSpaceSize, imageSize, scale)) +
      offset;
}

double _roundAfter(double number, int position) {
  double shift = pow(10, position).toDouble();
  return (number * shift).roundToDouble() / shift;
}

Offset _elementwiseDivision(Offset dividend, Offset divisor) {
  return dividend.scale(1.0 / divisor.dx, 1.0 / divisor.dy);
}

Offset _elementwiseMultiplication(Offset a, Offset b) {
  return a.scale(b.dx, b.dy);
}

Offset _elementwiseMin(Offset a, Offset b) {
  return new Offset(min(a.dx, b.dx), min(a.dy, b.dy));
}

Offset _elementwiseMax(Offset a, Offset b) {
  return new Offset(max(a.dx, b.dx), max(a.dy, b.dy));
}

Offset _asOffset(Size s) {
  return new Offset(s.width, s.height);
}
