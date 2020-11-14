import 'package:async/async.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_app/model/NotifySettings.dart';
import 'package:style_app/providers/CitiesProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/providers/ServicesProvider.dart';
import 'package:style_app/providers/SettingProvider.dart';
import 'package:style_app/service/CitiesService.dart';
import 'package:style_app/service/ProfileService.dart';
import 'package:style_app/service/ServicesRepository.dart';
import 'package:style_app/ui/AuthScreen.dart';
import 'package:style_app/ui/Main.dart';
import 'package:style_app/utils/Constants.dart';
import 'package:style_app/utils/TempData.dart';
import 'package:style_app/utils/Widget.dart';

class PreloaderScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PreloaderScreenState();
}

class PreloaderScreenState extends State<PreloaderScreen> {
  final AsyncMemoizer memoizer = AsyncMemoizer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final CitiesProvider cities = Provider.of<CitiesProvider>(context);
    final ServicesProvider services = Provider.of<ServicesProvider>(context);
    final SettingProvider settings = Provider.of<SettingProvider>(context);

    memoizer.runOnce(() async {
      var s = await SharedPreferences.getInstance();
      var language = s.getInt("locale");
      if(language == null) {
        language = 2;
        s.setInt("locale", 2);
      }
      var lang = Languages.byId(language);
      print("$lang");
      var res = await FlutterI18n.refresh(context, lang.locale);
      print("res $res");
      settings.language = lang;

      var c = await Connectivity().checkConnectivity();
      if(c.index == ConnectivityResult.none.index) {
        Navigator.pushReplacement(
            context,
            MaterialWithModalsPageRoute(
                builder: (c) => AuthScreen()
            )
        );
        return;
      }
      await CitiesService.get().getCities(cities);
      await ServicesRepository.get().getAllCategoriesAndServices(services);
      if(s.containsKey("token") && s.containsKey("type")) {
        var token = s.getString("token");
        var type = s.getInt("type");
        var user = await UserService.get().getCurrentUserByTokenAndRole(token, type);

        if(user != null) {
          TempData.user = user;
          profile.set(user);
          Navigator.pushReplacement(
              context,
              MaterialWithModalsPageRoute(
                  builder: (c) => Main()
              )
          );
        }
      } else {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
              context,
              MaterialWithModalsPageRoute(
                  builder: (c) => AuthScreen()
              )
          );
        });
      }
    });

    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Expanded(
              child: Icon(Icons.format_paint, color: primaryColor, size: 72).center()
          )
        ]
      ).safe(),
    );
  }
}