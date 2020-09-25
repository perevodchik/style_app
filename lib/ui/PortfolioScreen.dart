import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/PortfolioItem.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/PortfolioRepository.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class PortfolioScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PortfolioScreenState();
}

class PortfolioScreenState extends State<PortfolioScreen> {
  var _items = <PortfolioItem> [];
  var _images = <String> [];
  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    print("build");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      floatingActionButton: Container(
        padding: EdgeInsets.all(Global.blockY),
        decoration: BoxDecoration(
            color: defaultColorAccent,
            borderRadius: BorderRadius.all(Radius.circular(Global.blockY * 5))
        ),
        child: Icon(Icons.add, color: Colors.white).onClick(() async {
          final picker = ImagePicker();
          final pickedFile = await picker.getImage(source: ImageSource.gallery);
          if(pickedFile == null)
            return;
          var r = await PortfolioRepository.get().createMasterPortfolioItem(profile, pickedFile);
          if(r != null)
            setState(() {
              _items.add(r);
            });
        })
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                Navigator.pop(context);
              }),
              Text("Ваше портфолио", style: titleStyle),
              // Text("добавить", style: titleSmallBlueStyle),
              Icon(Icons.arrow_upward, size: 20, color: Colors.white)
            ],
          ).marginW(left: margin5, right: margin5)
              .sizeW(Global.width, Global.blockY * 10),
          Expanded(
            child: FutureBuilder(
              future: PortfolioRepository.get().getMasterPortfolio(profile),
              builder: (c, s) {
                print("[${s.connectionState}] [${s.hasData}] [${s.hasError}] [${s.data}] [${s.error}]");
                if(s.connectionState == ConnectionState.done && s.hasData && !s.hasError) {
                    var data = s.data as List<PortfolioItem>;
                    var images = data.map<String>((i) => i.image).toList();
                    _items.clear();
                    _items.addAll(data);
                    _images.clear();
                    _images.addAll(images);
                    return Wrap(
                        children: buildWidgets()
                    );
                  }
                else if(s.hasError)
                  return Wrap(
                      children: buildWidgets()
                  );
                else return CircularProgressIndicator();
              }
            ).center().scroll()
          )
        ]
      )
    ).safe();
  }

  List<Widget> buildWidgets() {
    print("buildWidgets");
    return _items.map<Widget>((i) =>
        PortfolioImagePreview(i)
            .onClick(() => Navigator.push(
            context,
            MaterialWithModalsPageRoute(
                builder: (context) =>
                    ImagePage(_images)
            )
        )
        )
            .marginW(left: margin5 / 2, right: margin5 / 2, bottom: Global.blockY)
    ).toList();
  }
}

class PortfolioImagePreview extends StatelessWidget {
  final PortfolioItem portfolio;
  PortfolioImagePreview(this.portfolio);

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
      height: Global.blockX * 40,
      width: Global.blockX * 40,
      decoration: BoxDecoration(
        borderRadius: defaultItemBorderRadius,
        color: defaultColorAccent
      ),
      child: Stack(
        children: [
          Text(portfolio.image).center(),
          Positioned(
            top: 0, right: 0,
            child: Icon(Icons.close, color: Colors.white, size: 36).onClick(() async {
              PortfolioRepository.get().deletePortfolioItem(profile, portfolio);
              profile.tick();
            })
          )
        ]
      )
    );
  }
}