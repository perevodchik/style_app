import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_app/model/MasterData.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/service/CitiesService.dart';
import 'package:style_app/service/ProfileService.dart';
import 'package:style_app/ui/Main.dart';
import 'package:style_app/ui/Modals.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/Global.dart';
import 'package:style_app/utils/Style.dart';
import 'package:style_app/utils/TempData.dart';
import 'package:style_app/utils/Widget.dart';

class AuthScreen extends StatelessWidget {
  static bool _isInit = false;
  const AuthScreen();

  @override
  Widget build(BuildContext context) {
    Global.build(MediaQuery.of(context));
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(FlutterI18n.translate(context, "title"), style: titleBigBlueStyle)
                ]
              ).marginW(top: Global.blockY * 5, bottom: Global.blockY * 20),
              RaisedButton(
                  onPressed: () async {
                    profile.profileType = 0;
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => AuthModal()
                    );
                  },
                  child: Text(FlutterI18n.translate(context, "auth_client"), style: smallWhiteStyle),
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: defaultItemBorderRadius,
                  )
              ).marginW(
                  left: margin5 * 5,
                  top: Global.blockY * 5,
                  right: margin5 * 5,
                  bottom: Global.blockY),
              RaisedButton(
                  onPressed: () {
                    profile.profileType = 1;
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => AuthModal()
                    );
                  },
                  child: Text(FlutterI18n.translate(context, "auth_master"), style: smallWhiteStyle),
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: defaultItemBorderRadius,
                  )
              ).marginW(left: margin5 * 5, right: margin5 * 5)
            ]
        )
      )
    ).safe();
  }
}

class AuthModal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AuthModalState();
}

class AuthModalState extends State<AuthModal> {
  TextEditingController _phoneController;
  bool isInProcess = false;
  bool isError = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _phoneController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: defaultItemBorderRadius
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(FlutterI18n.translate(context, "authorization"), textAlign: TextAlign.center, style: titleMediumBlueStyle).marginAll(Global.blockY * 2),
          TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                  hintText: "Номер телефона",
                  hintStyle: hintSmallStyle,
                  border: InputBorder.none
              )
          ).marginW(left: margin5, right: margin5),
          Container(
            height: Global.blockY * 2,
            child: Visibility(
              visible: isError,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(FlutterI18n.translate(context, "user_not_exist"), style: errorStyle)
                ]
              )
            )
          ),
          Text(FlutterI18n.translate(context, "create_account"), textAlign: TextAlign.center, style: titleSmallBlueStyle)
          .onClick(() {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    RegisterPage(0)
                )
            );
          })
          .marginW(top: Global.blockY * 2, bottom: Global.blockY * 3),
          Container(
            child: isInProcess ?
            LinearProgressIndicator()
                .marginW(top: Global.blockY * 3, bottom: Global.blockY * 2) :
            RaisedButton(
              onPressed: () async {
                setState(() {
                  isInProcess = true;
                  isError = false;
                });
                profile.phone = _phoneController.text;
                var isExist = await UserService.get().isExist(_phoneController.text, profile.profileType);
                if(isExist) {
                  profile.phone = _phoneController.text;
                  Navigator.pop(context);
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => SmsCodeModal()
                  );
                } else setState(() {
                  isError = true;
                  isInProcess = false;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: defaultItemBorderRadius,
              ),
              color: primaryColor,
              child: Text(FlutterI18n.translate(context, "log_in"), style: smallWhiteStyle),
            ).marginW(left: margin5 * 5, right: margin5 * 5)
          )
        ]
      )
    );
  }
}

class SmsCodeModal extends StatefulWidget {
  // final bool isRegisterMode;
  SmsCodeModal();
  @override
  State<StatefulWidget> createState() => SmsCodeModalState();
}

class SmsCodeModalState extends State<SmsCodeModal> {
  TextEditingController _smsCodeController;
  bool isInProcess = false;
  bool isError = false;

  @override
  void dispose() {
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _smsCodeController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    return Container(
        padding: MediaQuery.of(context).viewInsets,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: defaultItemBorderRadius
        ),
        child: ListView(
            shrinkWrap: true,
            children: [
              Text(FlutterI18n.translate(context, "input_code"), textAlign: TextAlign.center, style: titleMediumBlueStyle).marginAll(Global.blockY * 2),
              TextField(
                  controller: _smsCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "Код из смс",
                      hintStyle: hintSmallStyle,
                      border: InputBorder.none
                  )
              ).marginW(left: margin5, right: margin5),
              Container(
                  height: Global.blockY * 2,
                  child: Visibility(
                      visible: isError,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(FlutterI18n.translate(context, "incorrect_code"), style: errorStyle)
                          ]
                      )
                  )
              ),
              Container(
                  child: isInProcess ?
                  LinearProgressIndicator()
                      .marginW(top: Global.blockY * 3, bottom: Global.blockY * 2) :
                  RaisedButton(
                    onPressed: () async {
                      setState(() {
                        isInProcess = true;
                        isError = false;
                      });
                      if(_smsCodeController.text.isEmpty)
                        setState(() {
                          isError = true;
                          isInProcess = false;
                        });
                      else {
                        var user = await UserService.get().auth(profile.phone,
                            _smsCodeController.text, profile.profileType);
                        print(user.toString());
                        if(user != null) {
                          var s = await SharedPreferences.getInstance();
                          TempData.user = user;
                          profile.set(user);
                          s.setInt("type", profile.profileType);
                          s.setString("token", profile.token);
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Main()
                              )
                          );
                        } else
                          setState(() {
                            isError = true;
                            isInProcess = false;
                          });
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: defaultItemBorderRadius,
                    ),
                    color: primaryColor,
                    child: Text(FlutterI18n.translate(context, "log_in"), style: smallWhiteStyle),
                  ).marginW(left: margin5 * 5, right: margin5 * 5)
              )
            ]
        )
    );
  }
}

class RegisterPage extends StatefulWidget {
  final int type;
  RegisterPage(this.type);
  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController _phoneController;
  TextEditingController _nameController;
  TextEditingController _surnameController;
  bool isInProcess = false;
  bool isError = false;
  bool isEmptyFields = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _phoneController = TextEditingController();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final CitiesProvider cities = Provider.of<CitiesProvider>(context);
    return Scaffold(
        appBar: null,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isInProcess ?
        LinearProgressIndicator() :
        RaisedButton(
          elevation: 0,
          onPressed: () async {
            if (_phoneController.text.isEmpty ||
                _nameController.text.isEmpty ||
                _surnameController.text.isEmpty ||
                profile.city == null) {
              setState(() {
                isEmptyFields = true;
              });
            }
            else {
              setState(() {
                isEmptyFields = false;
                isError = false;
                isInProcess = true;
              });
              var isUserExist = await UserService.get().isExist(
                  _phoneController.text.replaceAll(" ", ""),
                  profile.profileType);
              if (!isUserExist) {
                setState(() {
                  isEmptyFields = false;
                  isError = false;
                  isInProcess = false;
                });
                await UserService.get().register(UserData(
                    -1,
                    profile.profileType,
                    profile.city,
                    0,
                    0.0,
                    _phoneController.text,
                    "",
                    _nameController.text,
                    _surnameController.text,
                    "",
                    "",
                    profile.email,
                    true,
                    true,
                    true,
                    false,
                    [],
                    [],
                    []), profile.profileType);
                profile.phone = _phoneController.text
                    .replaceAll(" ", "");
                profile.name = _nameController.text
                    .replaceAll(" ", "");
                profile.surname = _surnameController.text
                    .replaceAll(" ", "");
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => SmsCodeModal()
                );
              } else {
                setState(() {
                  isEmptyFields = false;
                  isError = true;
                  isInProcess = false;
                });
              }
            }
          },
          color: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: defaultItemBorderRadius,
          ),
          child: Text(FlutterI18n.translate(context, "send"), style: smallWhiteStyle),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(Icons.arrow_back_ios, size: 20).onClick(() {
                  Navigator.pop(context);
                }).marginW(left: Global.blockX * 5),
                Text(FlutterI18n.translate(context, "register"), style: titleStyle),
                Icon(Icons.file_upload, size: 20, color: Colors.white)
              ],
            ).sizeW(Global.width, Global.blockY * 10),
            Text(FlutterI18n.translate(context, "your_phone"), style: titleMediumStyle)
                .marginW(left: margin5, right: margin5),
            Container(
              padding: EdgeInsets.only(left: Global.blockX * 2),
              decoration: BoxDecoration(
                borderRadius: defaultItemBorderRadius,
                color: accentColor
              ),
              child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                      hintText: FlutterI18n.translate(context, "phone_number"),
                      hintStyle: hintSmallStyle,
                      border: InputBorder.none
                  )
              ),
            )
                .marginW(left: margin5, right: margin5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                    visible: isEmptyFields && _phoneController.text.isEmpty,
                    child: Text(FlutterI18n.translate(context, "field_need_be_fill"), style: errorStyle)
                )
              ]
            )
                .marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                      visible: isError,
                      child: Text(FlutterI18n.translate(context, "user_exist"), style: errorStyle)
                  )
                ]
            )
                .marginW(left: margin5, right: margin5),
            Text(FlutterI18n.translate(context, "your_name"), style: titleMediumStyle)
                .marginW(left: margin5, top: Global.blockY * 2, right: margin5),
            Container(
              padding: EdgeInsets.only(left: Global.blockX * 2),
              decoration: BoxDecoration(
                  borderRadius: defaultItemBorderRadius,
                  color: accentColor
              ),
              child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      hintText: FlutterI18n.translate(context, "name"),
                      hintStyle: hintSmallStyle,
                      border: InputBorder.none
                  )
              ),
            )
                .marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                      visible: isEmptyFields && _nameController.text.isEmpty,
                      child: Text(FlutterI18n.translate(context, "field_need_be_fill"), style: errorStyle)
                  )
                ]
            )
                .marginW(left: margin5, right: margin5),
            Text(FlutterI18n.translate(context, "your_surname"), style: titleMediumStyle)
                .marginW(left: margin5, top: Global.blockY * 2, right: margin5),
            Container(
                padding: EdgeInsets.only(left: Global.blockX * 2),
                decoration: BoxDecoration(
                    borderRadius: defaultItemBorderRadius,
                    color: accentColor
                ),
              child: TextField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                      hintText: FlutterI18n.translate(context, "surname"),
                      hintStyle: hintSmallStyle,
                      border: InputBorder.none
                  )
              )
            )
                .marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                      visible: isEmptyFields && _surnameController.text.isEmpty,
                      child: Text(FlutterI18n.translate(context, "field_need_be_fill"), style: errorStyle)
                  )
                ]
            ).marginW(left: margin5, right: margin5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(FlutterI18n.translate(context, "city"), style: titleMediumStyle),
                Text(FlutterI18n.translate(context, "select"), style: titleMediumBlueStyle)
                    .onClick(() async {
                  await CitiesService.get().getCities(cities);
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (c) => SelectCityModal());
                })
              ]
            )
                .marginW(left: margin5, top: Global.blockY * 2, right: margin5),
            Container(
                padding: EdgeInsets.only(left: Global.blockX * 2, top: Global.blockY * 2, bottom: Global.blockY * 2),
                decoration: BoxDecoration(
                    borderRadius: defaultItemBorderRadius,
                    color: accentColor
                ),
                child:Row(
                  mainAxisSize: MainAxisSize.max,
                    children: [
                      profile.city == null ?
                      Text(FlutterI18n.translate(context, "select_city"))
                          : Text(cities.byId(profile.city)?.name ?? "Город")
                    ]
                )
            ).marginW(left: margin5, right: margin5),
            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                      visible: isEmptyFields && _surnameController.text.isEmpty,
                      child: Text(FlutterI18n.translate(context, "select_city"), style: errorStyle)
                  )
                ]
            )
                .marginW(left: margin5, right: margin5),
          ]
        ).scroll()
    ).safe();
  }
}