import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/holders/CitiesHolder.dart';
import 'package:style_app/holders/UsersHolder.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/model/Photo.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/SearchFilterProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/service/MastersRepository.dart';
import 'package:style_app/ui/ImagePage.dart';
import 'package:style_app/ui/ProfileScreen.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class FindMaster extends StatefulWidget {
  const FindMaster({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => FindMasterState();
}

class FindMasterState extends State<FindMaster>
with AutomaticKeepAliveClientMixin {
  String filter = "";

  @override
  bool get wantKeepAlive => true;

  Future<List<UserShortData>> loadList(ProfileProvider profile, int page, int perPage, {String filter = ""}) async {
    UsersHolder.isLoading = true;
    var list = await MastersRepository.get().loadMastersList(profile, page, perPage, filter: filter);
    return list;
  }

  void loadListAsync(ProfileProvider profile, {String filter}) async {
    UsersHolder.isLoading = true;
    MastersRepository.get().loadMastersList(profile, UsersHolder.page, UsersHolder.itemsPerPage, filter: filter).then((list) {
      setState(() {
        UsersHolder.isLoading = false;
        UsersHolder.isFirstLoad = true;
        UsersHolder.page++;
        UsersHolder.users.clear();
        UsersHolder.users.addAll(list);
        UsersHolder.hasMore = list.length <= UsersHolder.itemsPerPage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);

    UsersHolder.memoizer.runOnce(() => loadListAsync(profile, filter: ""));

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(Icons.filter_list, color: Colors.transparent),
            Text("Поиск мастеров", style: titleStyle),
            Icon(Icons.filter_list, color: Colors.blueAccent)
                .onClick(() async {
                  var data = await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) {
                        return MastersFilterModal();
                      });
                  if(data != null) {
                    var newList = await loadList(profile, 0, UsersHolder.itemsPerPage, filter: data["filter"] ?? "");
                    setState(() {
                      UsersHolder.page = 1;
                      UsersHolder.hasMore = newList.length >= UsersHolder.itemsPerPage;
                      UsersHolder.users.clear();
                      UsersHolder.users.addAll(newList);
                      filter = data["filter"] ?? "";
                      UsersHolder.isLoading = false;
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
          child: Container(
            child: RefreshIndicator(
              onRefresh: () async {
                if(!UsersHolder.isLoading) {
                  var r = await loadList(profile, 0, UsersHolder.itemsPerPage, filter: filter);
                  setState(() {
                    UsersHolder.users.clear();
                    UsersHolder.users.addAll(r);
                    UsersHolder.hasMore = r.length >= UsersHolder.itemsPerPage;
                    UsersHolder.page = 1;
                    UsersHolder.isLoading = false;
                  });
                }
              },
              child: UsersHolder.isLoading && UsersHolder.users.isEmpty ?
              CircularProgressIndicator().center() :
              ListView.builder(
                  itemCount: UsersHolder.users.length,
                  itemBuilder: (b, i) {
                    if(UsersHolder.hasMore && i >= UsersHolder.users.length - 1 && !UsersHolder.isLoading) {
                      print("loadList 1");
                      loadList(profile, UsersHolder.page++, UsersHolder.itemsPerPage, filter: filter).then((value) {
                        setState(() {
                          UsersHolder.isLoading = false;
                          UsersHolder.users.addAll(value);
                          UsersHolder.hasMore = value.length == UsersHolder.itemsPerPage;
                        });
                      });
                      return CircularProgressIndicator().center();
                    }
                    return ProfilePreview(UsersHolder.users[i])
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
                    itemCount: CitiesHolder.cities.length,
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
          leading: Text("${CitiesHolder.cities[position]}",
                  style: filter.cities.contains(CitiesHolder.cities[position])
                      ? titleSmallBlueStyle
                      : titleSmallStyle)
              .onClick(() {
            filter.toggleCity(CitiesHolder.cities[position]);
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
      if(value.services != null && value.services.length > 0) {
        widgets.add(Container(
            alignment: Alignment.bottomLeft,
            color: Colors.grey.withOpacity(0.1),
            child: Text(value.name, style: titleSmallStyle)));
        value.services?.forEach((service) {
          widgets.add(SelectableServicePreview(service));
      });
      }
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
                          child: widget.data.avatar == null ?
                          Text("${widget.data.name[0]}${widget.data.surname[0]}",
                              style: titleSmallBlueStyle).center() :
                              widget.data.avatar.getWidget()
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
              enableInfiniteScroll: false,
              height: Global.blockY * 15,
            ),
            items: widget.data.portfolio.split(",").map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: defaultItemColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Image.network("$url/images/$i")
                          .center())
                      .onClick(() {
                    Navigator.push(
                        context,
                        MaterialWithModalsPageRoute(
                            builder: (context) =>
                                ImagePage(
                                    widget.data.portfolio.split(",").map((i) => Photo(i, PhotoSource.NETWORK)).toList()
                                )));
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