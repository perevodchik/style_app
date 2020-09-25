import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:style_app/utils/Style.dart';

import '../utils/Global.dart';

class CitySelectionPage extends StatefulWidget {
  const CitySelectionPage();

  @override
  State<StatefulWidget> createState() => CitySelectionState();

}

class CitySelectionState extends State<CitySelectionPage> {
  TextEditingController _cityController;

  @override
  void initState() {
    _cityController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Global.build(MediaQuery.of(context));

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: Global.blockX * 5, top: Global.blockY, right: Global.blockX * 5, bottom: Global.blockY),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: Offset(0, 10)
                    )
                  ],
                  borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                width: Global.blockX * 70,
                child:
                ListTile(
                  dense: true,
                  leading:
                  Container(
                      width: Global.blockX * 70,
                      child:
                      TextField(controller: _cityController,
                        decoration: InputDecoration(
                          hintText: "Город",
                            hintStyle: hintStyle,
                            border: InputBorder.none
                        )
                      )
                  ),
                  trailing: Icon(Icons.search, color: Colors.black)
                ),
              )
            ),
            Container(
              margin: EdgeInsets.only(left: Global.blockX * 5, top: Global.blockY, right: Global.blockX * 5, bottom: Global.blockY),
              child: Text("Выберите город", style: titleStyle),
            ),
            Container(
              height: Global.blockY * 75,
                margin: EdgeInsets.only(left: Global.blockX * 5, top: Global.blockY, right: Global.blockX * 5, bottom: Global.blockY),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: Offset(0, 10)
                      )
                    ],
                    borderRadius: BorderRadius.circular(10.0),
                ),
              child: ListView.builder(
                shrinkWrap: true,
                controller: ScrollController(),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: 32,
                itemBuilder: (context, position) {
                  return Container(
                    height: Global.blockY * 5,
                    width: Global.blockX * 60,
                    child: GestureDetector(
                      onTap: () {
                        print("$position");
                      },
                      child: ListTile(
                        dense: true,
                        leading: Text("Город $position"),
                      )
                    )
                  );
                })
            )
          ],
        ),
      ),
    );
  }

}