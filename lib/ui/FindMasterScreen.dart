import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/NotifySettings.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/SearchFilterProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/service/MastersRepository.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/MasterProfileScreen.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class FindMaster extends StatefulWidget {
  const FindMaster();
  @override
  State<StatefulWidget> createState() => FindMasterState();
}

class FindMasterState extends State<FindMaster> {
  List<Service> findByService = [];
  List<int> findByCity = [];
  List<UserShortData> _users = [];
  bool _isLoading = false;
  bool _isFirstLoad = false;
  bool _hasMore = true;
  int _page = 0;
  int _itemsPerPage = 10;

  Future<List<UserShortData>> loadList(ProfileProvider profile, int page, int perPage) async {
    _isLoading = true;
    var list = await MastersRepository.get().loadMastersList(profile, page, perPage);
    return list;
  }

  void loadListAsync(ProfileProvider profile) async {
    _isLoading = true;
    MastersRepository.get().loadMastersList(profile, _page, _itemsPerPage).then((list) {
      setState(() {
        _isLoading = false;
        _isFirstLoad = true;
        _page++;
        _users.clear();
        _users.addAll(list);
        if(list.length < _itemsPerPage)
          _hasMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);

    if(!_isLoading && !_isFirstLoad)
      loadListAsync(profile);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(Icons.filter_list, color: Colors.transparent),
            Text("Поиск мастеров", style: titleStyle),
            Icon(Icons.filter_list, color: Colors.blueAccent)
                .onClick(() => showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) {
                      return FilterModal();
                    }))
          ],
        ).marginW(
            left: Global.blockX * 5,
            top: Global.blockY * 2,
            right: Global.blockX * 5,
            bottom: Global.blockY),
        Expanded(
          child: Container(
            child: RefreshIndicator(
              onRefresh: () async {
                if(!_isLoading) {
                  var r = await loadList(profile, 0, _itemsPerPage);
                  setState(() {
                    _users.clear();
                    _users.addAll(r);
                    _hasMore = r.length == _itemsPerPage;
                    _page = 1;
                    _isLoading = false;
                  });
                }
              },
              child: _isLoading && _users.isEmpty ? CircularProgressIndicator().center() : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (b, i) {
                    if(_hasMore && i >= _users.length - 1 && !_isLoading) {
                      loadList(profile, _page++, _itemsPerPage).then((value) {
                        setState(() {
                          _isLoading = false;
                          _users.addAll(value);
                          _hasMore = value.length == _itemsPerPage;
                        });
                      });
                      return CircularProgressIndicator().center();
                    }
                    return ProfilePreview(_users[i])
                        .marginW(
                        left: Global.blockX * 5,
                        top: Global.blockY,
                        right: Global.blockX * 5,
                        bottom: Global.blockY);
                  }
              )
            )
          )
        )
      ]
    );
  }
}

class SelectCityModalSheet extends StatefulWidget {
  SelectCityModalSheet();

  @override
  State<StatefulWidget> createState() => SelectCityModalSheetState();
}

class SelectCityModalSheetState extends State<SelectCityModalSheet> {
  SelectCityModalSheetState();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Global.blockY * 75,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            color: Colors.white),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text("Выберите город", style: titleStyle),
            Container(
                height: Global.blockY * 50,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Cities.cities.length,
                    itemBuilder: (context, position) {
                      return SelectableCityPreview(position);
                    }))
          ],
        ).paddingW(left: Global.blockX * 5, right: Global.blockX * 5));
  }
}

class SelectableCityPreview extends StatelessWidget {
  final int position;

  SelectableCityPreview(this.position);

  @override
  Widget build(BuildContext context) {
    final SearchFilterProvider filter =
        Provider.of<SearchFilterProvider>(context);
    return Container(
        height: Global.blockY * 5,
        width: Global.blockX * 60,
        child: ListTile(
          dense: true,
          leading: Text("${Cities.cities[position]}",
                  style: filter.cities.contains(position)
                      ? titleSmallBlueStyle
                      : titleSmallStyle)
              .onClick(() {
            filter.toggleCity(position);
          }),
        ).onClick(() => Navigator.pop(context)));
  }
}

class SelectServiceModalSheet extends StatefulWidget {
  SelectServiceModalSheet();

  @override
  State<StatefulWidget> createState() => SelectServiceModalSheetState();
}

class SelectServiceModalSheetState extends State<SelectServiceModalSheet> {
  SelectServiceModalSheetState();

  @override
  Widget build(BuildContext context) {
    final SearchFilterProvider filter =
        Provider.of<SearchFilterProvider>(context);
    final ServicesProvider services =
        Provider.of<ServicesProvider>(context);
    return Container(
            height: Global.blockY * 75,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: Colors.white),
            child: ListView(
                    shrinkWrap: true,
                    children:
                        buildServiceList(filter, services.map))
                .marginAll(Global.blockX))
        .background(Colors.transparent);
  }

  List<Widget> buildServiceList(
      SearchFilterProvider filter, List<Category> map) {
    List<Widget> widgets = <Widget>[];
    widgets.add(Text("Выберите услуги", style: titleStyle)
        .center()
        .marginW(bottom: Global.blockY));
    map.forEach((value) {
      widgets.add(Container(
          alignment: Alignment.bottomLeft,
          color: Colors.grey.withOpacity(0.1),
          child: Text(value.name, style: titleMediumStyle)));
      value.services?.forEach((service) {
        widgets.add(SelectableServicePreview(service));
      });
    });
    return widgets;
  }
}

class SelectableServicePreview extends StatelessWidget {
  final Service service;

  SelectableServicePreview(this.service);

  @override
  Widget build(BuildContext context) {
    final SearchFilterProvider filter =
        Provider.of<SearchFilterProvider>(context);
    return Column(children: <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(service.name,
                style: filter.services.contains(service)
                    ? titleSmallBlueStyle
                    : hintSmallStyle)
            .onClick(() {
          filter.toggleService(service);
        }),
        Switch(
          value: filter.services.contains(service),
          onChanged: (value) => filter.toggleService(service),
        )
      ])
    ]).paddingW(left: Global.blockX * 3, right: Global.blockX * 3);
  }
}

class ProfilePreview extends StatefulWidget {
  final UserShortData data;

  ProfilePreview(this.data);

  @override
  State<StatefulWidget> createState() => ProfilePreviewState();
}

class ProfilePreviewState extends State<ProfilePreview> {

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: <Widget>[
                  Container(
                          height: Global.blockX * 10,
                          width: Global.blockX * 10,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Global.blockX * 10))),
                          child: Text("${widget.data.name[0]}${widget.data.surname[0]}",
                                  style: titleSmallBlueStyle)
                              .center())
                      .marginW(right: Global.blockY),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${widget.data.name} ${widget.data.surname}",
                          style: titleMediumStyle),
                      Row(
                        children: <Widget>[
                          Text(
                              "${widget.data.rate.toStringAsFixed(1)}/5 "),
                          RatingBar(
                            itemSize: Global.blockY * 2,
                            ignoreGestures: true,
                            initialRating: double.parse(
                                widget.data.rate.toStringAsFixed(1)),
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.blueAccent,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ).onClick(() {
                Navigator.push(
                    context,
                    MaterialWithModalsPageRoute(
                        builder: (context) => UserProfile(widget.data.id)));
              })
            ],
          ),
          widget.data.portfolio != null?
          CarouselSlider(
            options: CarouselOptions(
              height: Global.blockY * 15,
            ),
            items: widget.data.portfolio.split(",").map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('$i', style: TextStyle(fontSize: 16.0))
                          .center())
                      .onClick(() {
                    Navigator.push(
                        context,
                        MaterialWithModalsPageRoute(
                            builder: (context) =>
                                ImagePage(widget.data.portfolio.split(","))));
                  });
                },
              );
            }).toList(),
          ).marginW(top: Global.blockX, bottom: Global.blockX) :
              Container(
                child: Text("Мастер еще не добавит фотографий").center(),
              ).marginW(top: Global.blockY, bottom: Global.blockY)
        ],
      ).paddingAll(Global.blockY),
    );
  }
}