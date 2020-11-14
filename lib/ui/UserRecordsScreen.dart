import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/holders/UserOrdersHolder.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/OrderProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/OrdersService.dart';
import 'package:style_app/ui/CreateOrderScreen.dart';
import 'package:style_app/ui/OrderPageScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/StatusUtils.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class Records extends StatefulWidget {
  const Records();

  @override
  State<StatefulWidget> createState() => RecordsState();
}

class RecordsState extends State<Records>{
  bool isLoadOrders = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final OrderProvider orders = Provider.of<OrderProvider>(context);
    final CitiesProvider cities = Provider.of<CitiesProvider>(context);

    UserOrdersHolder.memoizer.runOnce(() async {
      OrdersService.get().loadUserOrders(profile).then((value) => orders.previews = value);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: profile.profileType == 0,
        child: RaisedButton(
            onPressed: () => Navigator.push(context, MaterialWithModalsPageRoute(
                builder: (context) => NewOrderScreen(null ,null, cities.byId(profile.city))
            )),
            color: primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: defaultItemBorderRadius
            ),
            child: Text(FlutterI18n.translate(context, "create_new_order"), style: smallWhiteStyle)
        )
      )
          .marginW(left: Global.blockY * 2, top: Global.blockX, right: Global.blockY * 2, bottom: Global.blockY),
      body: Column(
        children: <Widget>[
          Container(
            height: Global.blockY * 4,
            child: Text(FlutterI18n.translate(context, "your_orders"), style: titleStyle),
          ).center().marginW(
              left: Global.blockX * 5,
              top: Global.blockY * 2,
              right: Global.blockX * 5,
              bottom: Global.blockY),
        Expanded(
          child: Container(
            color: Colors.white,
              child: RefreshIndicator(
                onRefresh: () async {
                  var list = await OrdersService.get().loadUserOrders(profile);
                  orders.previews = list;
                },
                child: ListView.builder(
                  itemCount: orders.previews.length,
                  itemBuilder: (c, i) {
                    return UserOrderPreview(orders.previews[i])
                        .marginW(top: Global.blockX, left: Global.blockX * 5, right: Global.blockX * 5, bottom: Global.blockY)
                        .onClick(() {
                      Navigator.push(context,
                          MaterialWithModalsPageRoute(builder: (context) => OrderPage(orders.previews[i].id))
                      );
                    });
                  }
                )
              )
            )
          )
        ]
      )
    );
  }
}

class UserOrderPreview extends StatelessWidget {
  final OrderPreview preview;

  UserOrderPreview(this.preview);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          generateShadow()
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text( "${preview.name}", style: titleMediumBlueStyle)
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(preview.price == null || preview.price < 1 ? FlutterI18n.translate(context, "price_not_present") : "${FlutterI18n.translate(context, "price")} ${preview.price}", style: serviceSubtitleStyle)
              ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text( "${FlutterI18n.translate(context, "sentences")} ${preview.sentencesCount}", textAlign: TextAlign.start),
              Text( "${StatusUtils.getStatus(context, preview.status)}", textAlign: TextAlign.start)
            ],
          )
        ],
      ).paddingAll(Global.blockY),
    );
  }
}