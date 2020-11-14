import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/holders/OrdersHolder.dart';
import 'package:style_app/model/Record.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/RecordProvider.dart';
import 'package:style_app/service/OrdersService.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/ui/OrderPageScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class FindOrdersScreen extends StatefulWidget {
  const FindOrdersScreen();
  @override
  State<StatefulWidget> createState() => FindOrdersState();
}

class FindOrdersState extends State<FindOrdersScreen> {
  String filter = "";

  void loadListAsync(ProfileProvider profile) async {
    OrdersHolder.isLoading = true;
    OrdersService.get().loadAvailableOrders(profile, OrdersHolder.page, OrdersHolder.itemsPerPage).then((list) {
      setState(() {
        OrdersHolder.isLoading = false;
        OrdersHolder.isFirstLoad = true;
        OrdersHolder.page++;
        OrdersHolder.availables.clear();
        OrdersHolder.availables.addAll(list);
        if(list.length < OrdersHolder.itemsPerPage)
          OrdersHolder.hasMore = false;
      });
    });
  }

  Future<List<OrderAvailablePreview>> loadList(ProfileProvider profile, int page, int perPage, {String filter = ""}) async {
    OrdersHolder.isLoading = true;
    var list = await OrdersService.get().loadAvailableOrders(profile, page, perPage, filter: filter);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final OrdersProvider orders = Provider.of<OrdersProvider>(context);

    OrdersHolder.memoizer.runOnce(() => loadListAsync(profile));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("123", style: TextStyle(color: Colors.white)),
            Container(
              child: Text(FlutterI18n.translate(context, "find_orders"), style: titleStyle),
            ).center(),
            Icon(Icons.filter_list, color: primaryColor).onClick(() async {
              var r = await showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (c) => FindOrdersFilterModal()
              );
              if(r != null) {
                var newOrders = await loadList(profile, 0, OrdersHolder.itemsPerPage, filter: r["filter"] ?? "");
                setState(() {
                  OrdersHolder.page = 1;
                  OrdersHolder.hasMore = newOrders.length >= OrdersHolder.itemsPerPage;
                  OrdersHolder.availables.clear();
                  OrdersHolder.availables.addAll(newOrders);
                  filter = r["filter"] ?? "";
                });
              }
            })
          ],
        ).marginW(
            left: Global.blockX * 5,
            top: Global.blockY * 2,
            right: Global.blockX * 5,
            bottom: Global.blockY),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if(!OrdersHolder.isLoading) {
                var list = await loadList(profile, 0, OrdersHolder.itemsPerPage, filter: filter);
                setState(() {
                  OrdersHolder.availables.clear();
                  OrdersHolder.availables.addAll(list);
                  OrdersHolder.hasMore = list.length == OrdersHolder.itemsPerPage;
                  OrdersHolder.page = 1;
                  OrdersHolder.isLoading = false;
                });
              }
            },
            child: ListView.builder(
                itemCount: orders.availableOrders.length,
                itemBuilder: (c, i) {
                  if(OrdersHolder.hasMore && i >= orders.availableOrders.length - 1 && !OrdersHolder.isLoading) {
                    loadList(profile, OrdersHolder.page++, OrdersHolder.itemsPerPage, filter: "services=666").then((value) {
                      setState(() {
                        OrdersHolder.isLoading = false;
                        orders.availableOrders.addAll(value);
                        OrdersHolder.hasMore = value.length == OrdersHolder.itemsPerPage;
                      });
                    });
                    return CircularProgressIndicator().center();
                  }
                  return AvailableOrderPreview(orders.availableOrders[i])
                      .marginW(left: margin5,
                      top: Global.blockY,
                      right: margin5,
                      bottom: Global.blockY);
                }
            )
          )
        )
      ]
    );
  }
}

class AvailableOrderPreview extends StatelessWidget {
  final OrderAvailablePreview _order;
  AvailableOrderPreview(this._order);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Global.blockY),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          generateShadow()
        ],
        borderRadius: defaultItemBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_order.name ?? "Заказ ${_order.id}", style: titleMediumBlueStyle),
          Visibility(
            visible: _order.description.length > 0,
            child: Text(_order.description.length < 200 ?
            _order.description :
            "${_order.description.substring(0, 200)}..."),
          ),
          Visibility(
            visible: _order.price != null,
            child: Text(_order.price == null ?
            "" :
            "Стоимость ${_order.price} грн.", style: hintSmallPlusStyle).marginW(top: Global.blockX)
          ),
          Text("${FlutterI18n.translate(context, "release_at")} ${_order.created.getFullDate()}", style: hintSmallPlusStyle).marginW(top: Global.blockX)
        ],
      ),
    ).onClick(() => Navigator.push(
        context,
        MaterialWithModalsPageRoute(builder: (c) => OrderPage(_order.id))
      )
    );
  }
}