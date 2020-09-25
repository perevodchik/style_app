import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
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

class FindRecordsScreen extends StatefulWidget {
  const FindRecordsScreen();
  @override
  State<StatefulWidget> createState() => FindRecordsState();
}

class FindRecordsState extends State<FindRecordsScreen> {
  static int _page = 0;
  static final int _itemsPerPage = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  void loadListAsync(ProfileProvider profile, RecordProvider orders) async {
    _isLoading = true;
    print("load async list 0...");
    OrdersService.get().loadAvailableOrders(profile, _page, _itemsPerPage).then((list) {
      setState(() {
        _isLoading = false;
        _page++;
        orders.setAvailableOrders = list;
        print("load async list 1...");
        if(list.length < _itemsPerPage)
          _hasMore = false;
      });
    });
  }

  Future<List<OrderAvailablePreview>> loadList(ProfileProvider profile, int page, int perPage) async {
    _isLoading = true;
    print("load list 0...");
    var list = await OrdersService.get().loadAvailableOrders(profile, page, perPage);
    print("load list 1...");
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final RecordProvider orders = Provider.of<RecordProvider>(context);
    // if(!_isLoading && !_isFirstLoad)
    //   loadListAsync(profile, orders);

    return Column(
      children: [
        Container(
          child: Text("Поиск заказов", style: titleStyle),
        ).marginW(top: Global.blockY * 2, bottom: Global.blockY * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Фильтр", style: titleMediumBlueStyle),
            Icon(Icons.filter_list, color: defaultColorAccent)
          ]
        ).marginW(left: Global.blockX * 5, right: Global.blockX * 5, bottom: Global.blockY)
            .onClick(() => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (c) => FindRecordsFilterModal()
        )),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if(!_isLoading) {
                var r = await loadList(profile, 0, _itemsPerPage);
                setState(() {
                  orders.setAvailableOrders = r;
                  _hasMore = r.length == _itemsPerPage;
                  _page = 1;
                  _isLoading = false;
                });
              }
            },
            child: ListView.builder(
                itemCount: orders.availableOrders.length,
                itemBuilder: (c, i) {
                  print("build $i");
                  if(_hasMore && i >= orders.availableOrders.length - 1 && !_isLoading) {
                    loadList(profile, _page++, _itemsPerPage).then((value) {
                      setState(() {
                        _isLoading = false;
                        orders.availableOrders.addAll(value);
                        _hasMore = value.length == _itemsPerPage;
                      });
                    });
                    return CircularProgressIndicator().center();
                  }
                  return AvailableOrderPreview(orders.availableOrders[i]);
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
        children: [
          Text(_order.name ?? "Заказ ${_order.id}", style: titleMediumBlueStyle),
          Text(_order.description == null ? "" : _order.description.length < 200 ?
          _order.description :
          "${_order.description.substring(0, 200)}..."),
          Visibility(
            visible: _order.price != null,
            child: Text(_order.price == null ?
            "" :
            "Стоимость ${_order.price} грн.", style: hintSmallPlusStyle).marginW(top: Global.blockX)
          ),
          Text("Опубликован в ${_order.created.getFullDate()}", style: hintSmallPlusStyle).marginW(top: Global.blockX)
        ],
      ),
    ).onClick(() => Navigator.push(
        context,
        MaterialWithModalsPageRoute(builder: (c) => OrderPage(_order.id))
      )
    ).marginW(left: margin5, right: margin5, bottom: Global.blockY);
  }
}