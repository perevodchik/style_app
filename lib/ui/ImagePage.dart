import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class ImagePage extends StatelessWidget {
  final List<Photo> images;
  ImagePage(this.images);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                Navigator.pop(context);
              }).marginW(left: Global.blockX * 5),
              Text("Просмотр фотографий", style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                enableInfiniteScroll: false
              ),
              items: images.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: i.getWidget().center()
                    );
                  },
                );
              }).toList(),
            ).center().marginW(top: Global.blockX, bottom: Global.blockX)
          )
        ],
      ),
    ).safe();
  }
}

class ImageFilePage extends StatelessWidget {
  final List<Photo> images;
  ImageFilePage(this.images);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                Navigator.pop(context);
              }).marginW(left: Global.blockX * 5),
              Text("Просмотр фотографий", style: titleStyle),
              Icon(Icons.file_upload, size: 20, color: Colors.white)
            ],
          ).sizeW(Global.width, Global.blockY * 10),
          Container(
            height: Global.blockY * 75,
                child:
                CarouselSlider(
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    height: Global.blockY * 75,
                  ),
                  items: images.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: i.getWidget().center()
                        );
                      },
                    );
                  }).toList(),
                ).center().marginW(top: Global.blockX, bottom: Global.blockX)
          )
        ],
      ),
    ).safe();
  }
}