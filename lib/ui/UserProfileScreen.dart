import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:style_app/model/Category.dart';
import 'package:style_app/model/NotifySettings.dart';
import 'package:style_app/model/Service.dart';
import 'package:style_app/model/ServiceWrapper.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/providers/SettingProvider.dart';
import 'package:style_app/service/CategoryService.dart';
import 'package:style_app/service/ProfileService.dart';
import 'package:style_app/service/ServicesRepository.dart';
import 'package:style_app/ui/AuthScreen.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/ui/PortfolioScreen.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/Widget.dart';

class Profile extends StatefulWidget {
  const Profile();

  @override
  State createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  File _image;
  TextEditingController _nameController;
  TextEditingController _surnameController;
  TextEditingController _phoneController;
  TextEditingController _emailController;
  TextEditingController _addressController;
  int city = 0;

  ProfileState();

  @override
  void initState() {
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final SettingProvider settings = Provider.of<SettingProvider>(context);
    final CitiesProvider cities = Provider.of<CitiesProvider>(context);
    _nameController.text = profile.name;
    _surnameController.text = profile.surname;
    _phoneController.text = profile.phone;
    _emailController.text = profile.email;
    _addressController.text = profile.address;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: Global.blockY * 4,
                child: Text("Мой профиль", style: titleStyle),
              ).center().marginW(
                  left: Global.blockX * 5,
                  top: Global.blockY * 2,
                  right: Global.blockX * 5,
                  bottom: Global.blockY),
              Expanded(
                child: Container(
                    child: Stack(children: <Widget>[
                      Container(
                        width: Global.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 15,
                                  offset: Offset(0, 10))
                            ]),
                        child: Column(
                          children: <Widget>[
                            ProfileItem("Имя", _nameController)
                                .marginW(left: margin5,
                                right: margin5),
                            ProfileItem("Фамилия", _surnameController)
                                .marginW(left: margin5,
                                top: Global.blockY * 1,
                                right: margin5,
                                bottom: Global.blockY * 1),
                            ProfileItem("Телефон", _phoneController)
                                .marginW(left: margin5,
                                top: Global.blockY * 1,
                                right: margin5,
                                bottom: Global.blockY * 1),
                            ProfileItem("E-mail", _emailController)
                                .marginW(left: margin5,
                                top: Global.blockY * 1,
                                right: margin5,
                                bottom: Global.blockY * 1),
                            ProfileItem("Адресс", _addressController)
                                  .marginW(left: margin5,
                                  top: Global.blockY * 1,
                                  right: margin5,
                                  bottom: Global.blockY * 1),
                            ProfileSelectItem("Язык", Languages.languages[settings.language], () async {
                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) {
                                    return SelectLanguageModal();
                                  });
                            })
                                .marginW(left: margin5,
                                top: Global.blockY * 1,
                                right: margin5,
                                bottom: Global.blockY * 1),
                            ProfileSelectItem("Город", cities.byId(profile.city).name, () async {
                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) {
                                    return SelectCityModal();
                                  });
                            })
                                .marginW(left: margin5,
                                top: Global.blockY * 1,
                                right: margin5,
                                bottom: Global.blockY * 1),
                            Visibility(
                              visible: profile.profileType == 1,
                              child: ProfileActionItem(
                                  "Настройка специализаций", Icons.bubble_chart)
                                  .marginW(left: margin5,
                                  top: Global.blockY * 1,
                                  right: margin5,
                                  bottom: Global.blockY * 1)
                                  .onClick(() {
                                    Navigator.push(
                                        context,
                                        MaterialWithModalsPageRoute(
                                          builder: (c) => SetServicesScreen()
                                        )
                                    );
                              })
                            ),
                            Visibility(
                                visible: profile.profileType == 1,
                                child: ProfileActionItem(
                                    "Настройка портфолио", Icons.format_paint)
                                    .marginW(left: margin5,
                                    top: Global.blockY * 1,
                                    right: margin5,
                                    bottom: Global.blockY * 1)
                                    .onClick(() {
                                  Navigator.push(
                                      context,
                                      MaterialWithModalsPageRoute(
                                          builder: (c) => PortfolioScreen()
                                      )
                                  );
                                })
                            ),
                            ProfileActionItem(
                                "Настройка приватности", Icons.security)
                                .marginW(left: margin5,
                                top: Global.blockY * 1,
                                right: margin5,
                                bottom: Global.blockY * 1)
                                .onClick(() {
                                  showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) {
                                        return PrivateSettingsModal();
                                      });
                            }),
                            Container(
                                width: Global.blockX * 80,
                                child: RaisedButton(
                                    onPressed: () async {
                                      var result = await UserService.get().update(
                                          profile,
                                          _nameController.text,
                                          _surnameController.text,
                                          _emailController.text,
                                          _addressController.text,
                                          profile.city);
                                      if(result) {
                                        profile.name = _nameController.text;
                                        profile.surname = _surnameController.text;
                                        profile.email = _emailController.text;
                                      }
                                    },
                                    child: Text("Сохранить"),
                                    textColor: Colors.white,
                                    color: Colors.blueAccent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: defaultItemBorderRadius
                                    ))),
                            Container(
                              width: Global.blockX * 80,
                              child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AuthScreen()
                                        )
                                    );
                                  },
                                  child: Text("Выход", style: titleSmallBlueStyle),
                                  textColor: Colors.black,
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: defaultItemBorderRadius)),
                            )
                          ],
                        ).paddingW(top: Global.blockY * 10),
                      ).marginW(
                          top: Global.blockY * 7.5,
                          left: Global.blockX * 5,
                          right: Global.blockX * 5,
                          bottom: Global.blockY * 5),
                      Container(
                        width: Global.blockX * 25,
                        height: Global.blockX * 25,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            boxShadow: [
                            ]),
                          child: _image == null ? Container(
                            child: Text("${profile.name[0]}${profile.surname[0]}", style: titleBigBlueStyle).center(),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(70),
                              borderRadius:
                              BorderRadius.circular(Global.blockX * 50),
                            ),
                          ) : Image.file(_image),
                      ).onClick(() async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.getImage(source: ImageSource.gallery);
                        setState(() {
                          if(pickedFile != null)
                            _image = File(pickedFile.path);
                        });
                      }).positionW(
                          Global.blockX * 37.5, 0, Global.blockX * 37.5, null)
                    ]).scroll()),
              )
            ]));
  }
}

class ProfileItem extends StatelessWidget {
  final String _name;
  final TextEditingController _controller;
  ProfileItem(this._name, this._controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Global.blockY * 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              width: Global.blockX * 20,
              child: Text(_name, style: profileAttributeStyle)),
          Container(
            width: Global.blockX * 60,
            child: TextField(
              controller: _controller,
              style: profileInputStyle,
              decoration: InputDecoration(
                  hintText: _name,
                  hintStyle: profileHintStyle,
                  border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileSelectItem extends StatelessWidget {
  final String _name;
  final String _value;
  final Function _action;

  ProfileSelectItem(this._name, this._value, this._action);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
            width: Global.blockX * 20,
            child: Text(_name, style: profileAttributeStyle)),
        Container(
            height: Global.blockY * 5,
            width: Global.blockX * 60,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                    left: 0,
                    child: Text(
                      _value,
                      style: profileInputStyle,
                    )),
                Positioned(right: 0, child: Icon(Icons.keyboard_arrow_right))
              ],
            )).onClick(_action)
      ],
    );
  }
}

class ProfileActionItem extends StatelessWidget {
  final String _name;
  final IconData _icon;

  ProfileActionItem(this._name, this._icon);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(child: Icon(_icon)),
            Text(
              _name,
              style: profileInputStyle,
            ),
            Icon(Icons.keyboard_arrow_right)
          ]
        ));
  }
}

class SetServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    print("rebuild");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                  Navigator.pop(context);
                }).marginW(left: Global.blockX * 5),
                Text("Настройка услуг", style: titleStyle),
                Icon(Icons.file_upload, size: 20, color: Colors.white)
              ],
            ).sizeW(Global.width, Global.blockY * 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  color: Colors.white),
                child: FutureBuilder(
                  future: ServicesRepository.get().getMasterServices(profile),
                  builder: (c, snapshot) {
                    var data = snapshot.data;
                    if(!snapshot.hasError && snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                      return ListView(
                          shrinkWrap: true,
                          children: buildServiceList(profile, data))
                          .marginAll(Global.blockX);
                    }
                    return CircularProgressIndicator();
                  },
                )
              )
            )
          ]
      )
          .background(Colors.transparent)
    ).safe();
  }

  List<Widget> buildServiceList(ProfileProvider profile, List<Category> map) {
    List<Widget> widgets = <Widget>[];
    for(var c in map) {
      if(c.services == null || c.services.isEmpty)
        continue;
      widgets.add(
          Container(
              alignment: Alignment.bottomLeft,
              color: defaultItemColor,
              child: Text(c.name, style: titleMediumStyle).marginW(left: margin5, top: Global.blockX, bottom: Global.blockX)
          )
      );
      c?.services?.forEach((service) {
        widgets.add(SelectableServicePreview(service));
      });
    }
    return widgets;
  }
}

class SelectableServicePreview extends StatefulWidget {
  final Service service;
  SelectableServicePreview(this.service);

  @override
  State<StatefulWidget> createState() => SelectableServicePreviewState();
}

class SelectableServicePreviewState extends State<SelectableServicePreview> {

  @override
  Widget build(BuildContext context) {
    print("build service ${widget.service.toString()}");
    return Container(
      padding: EdgeInsets.only(left: Global.blockY, right: Global.blockY),
      decoration: BoxDecoration(
        // color: defaultItemColor,
        // borderRadius: defaultItemBorderRadius
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Text(widget.service.name,
              style:
              titleSmallBlueStyle
          ).marginW(top: Global.blockY, bottom: Global.blockY)
              .onClick(() {
          }),
          // )
        ])
    ).marginW(left: margin5, top: Global.blockY, right: margin5, bottom: Global.blockX)
    .onClick(() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (c) => EditMasterServiceModal(widget.service)
    ));
  }
}

class ModalNotifySettings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final SettingProvider settings = Provider.of<SettingProvider>(context);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(10)),
            color: Colors.white),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text("Настройка уведомлений",
                style: titleStyle)
                .marginW(
                bottom: Global.blockY * 2),
            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: <Widget>[
                Text("Новая запись",
                    style: titleMediumStyle),
                Switch(
                  onChanged: (value) {
                    settings.newOrder = value;
//                    setState(() {
//                      notifySettings.newOrderNotify = value;
//                    });
                  },
                  value: settings.newOrder,
                ).sizeW(Global.blockX * 15,
                    Global.blockY * 5)
              ],
            ),
            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: <Widget>[
                Text("Отмена записи",
                    style: titleMediumStyle),
                Switch(
                  onChanged: (value) {
                    settings.cancelOrder = value;
//                    setState(() {
//                      notifySettings.cancelOrderNotify = value;
//                    });
                  },
                  value: settings.cancelOrder,
                ).sizeW(Global.blockX * 15,
                    Global.blockY * 5)
              ],
            ),
            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: <Widget>[
                Text("Перенос записи",
                    style: titleMediumStyle),
                Switch(
                  onChanged: (value) {
                    settings.changeOrder = value;
                  },
                  value: settings.changeOrder,
                ).sizeW(Global.blockX * 15,
                    Global.blockY * 5)
              ],
            )
          ],
        ).paddingW(
            left: Global.blockX * 5,
            top: Global.blockX * 5,
            right: Global.blockX * 5,
            bottom: Global.blockX * 5));
  }
}