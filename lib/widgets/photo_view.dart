import 'dart:io';

import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PreviewImagesWidget extends StatefulWidget {
  ///图片Lst
  final String file;

  ///初始展示页数。默认0
  final int initialPage;

  ///选中的页的点的颜色
  final Color checkedColor = Colors.white;

  ///未选中的页的点的颜色
  final Color uncheckedColor = Colors.grey;

  PreviewImagesWidget(
    this.file, {
    this.initialPage = 0,
  });

  @override
  _PreviewImagesWidgetState createState() =>
      _PreviewImagesWidgetState(initialPage: initialPage);
}

class _PreviewImagesWidgetState extends State<PreviewImagesWidget> {
  PageController pageController;
  int nowPosition;
  int initialPage;
  List<Widget> dotWidgets;

  _PreviewImagesWidgetState({this.initialPage = 0});

  @override
  void initState() {
    super.initState();
    nowPosition = initialPage;
    pageController = PageController(initialPage: initialPage);
  
  }

 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pictures'),
        centerTitle: true,
      ),
      body: Container(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PhotoViewGallery.builder(
              onPageChanged: (index) {
                setState(() {
                  nowPosition = index;

                });
              },
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: 
                  widget.file.startsWith('http')?
                  Image.network(widget.file).image
                  :
                  Image.file(LocalFileSystem().file(widget.file)).image,
                );
              },
              itemCount: 1,
              pageController: pageController,
            ),
    
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
