import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
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
  final AsyncMemoizer memoizer = AsyncMemoizer();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final OrderProvider orders = Provider.of<OrderProvider>(context);

    memoizer.runOnce(() async {
      OrdersService.get().loadUserOrders(profile).then((value) => orders.previews = value);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: profile.profileType == 0,
        child: RaisedButton(
            onPressed: () => Navigator.push(context, MaterialWithModalsPageRoute(
                builder: (context) => NewOrderScreen(null ,null)
            )),
            color: Colors.blueAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: defaultItemBorderRadius
            ),
            child: Text("Создать новую запись", style: smallWhiteStyle)
        )
      )
          .marginW(left: Global.blockY * 2, top: Global.blockX, right: Global.blockY * 2, bottom: Global.blockY),
      body: Column(
        children: <Widget>[
          Container(
            height: Global.blockY * 4,
            child: Text("Ваши записи", style: titleStyle),
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
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: Offset(0, 1))
                        ],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("${orders.previews[i].name}", style: titleMediumBlueStyle)
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Цена ${orders.previews[i].price}", style: serviceSubtitleStyle)
                              ]
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Ставок ${orders.previews[i].sentencesCount}", textAlign: TextAlign.start),
                              Text("${StatusUtils.getStatus(orders.previews[i].status)}", textAlign: TextAlign.start)
                            ],
                          )
                        ],
                      ).paddingAll(Global.blockY),
                    ).marginW(top: Global.blockX, left: Global.blockX * 5, right: Global.blockX * 5, bottom: Global.blockY)
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