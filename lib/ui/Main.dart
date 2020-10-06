import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:style_app/SocketController.dart';
import 'package:style_app/providers/ConversionProvider.dart';
import 'package:style_app/providers/ProfileProvider.dart';
import 'package:style_app/ui/FindMasterScreen.dart';
import 'package:style_app/ui/FindOrdersScreen.dart';
import 'package:style_app/ui/MessagesScreen.dart';
import 'package:style_app/ui/SketchesScreen.dart';
import 'package:style_app/ui/UserRecordsScreen.dart';
import 'package:style_app/utils/Widget.dart';

import '../utils/Global.dart';
import 'UserProfileScreen.dart';

class Main extends StatefulWidget {
  const Main();

  @override
  State<StatefulWidget> createState() => MainState();
}

class MainState extends State<Main> with WidgetsBindingObserver {
  final AsyncMemoizer memoizer = AsyncMemoizer();
  int _page = 0;
  static final List<Widget> clientPages = <Widget> [
    const FindMaster(),
    const Sketches(),
    const Messages(),
    const Records(),
    Profile()
  ];
  static final List<Widget> masterPages = <Widget> [
    const FindOrdersScreen(),
    const MasterSketchesPage(),
    const Messages(),
    const Records(),
    Profile()
  ];

  Timer socketTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state ${state.toString()}");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    memoizer.runOnce(() => Global.build(MediaQuery.of(context)));
    final ProfileProvider profile = Provider.of<ProfileProvider>(context);
    final ConversionProvider conversions = Provider.of<ConversionProvider>(context);
    if(socketTimer == null) {
      SocketController(profile, conversions).init();
      socketTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        SocketController(profile, conversions).init();
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        onTap: (tapIndex) => setState(() {_page = tapIndex;}),
        selectedItemColor: Colors.blueAccent,
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.grey),
              title: Text("Поиск"),
              activeIcon: Icon(Icons.search, color: Colors.blueAccent)),
          BottomNavigationBarItem(
              icon: Icon(Icons.brush, color: Colors.grey),
              title: Text("Эскизы"),
              activeIcon: Icon(Icons.brush, color: Colors.blueAccent)
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.message, color: Colors.grey),
              title: Text("Сообщения"),
              activeIcon: Icon(Icons.message, color: Colors.blueAccent)),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, color: Colors.grey),
              title: Text("Записии"),
              activeIcon: Icon(Icons.calendar_today, color: Colors.blueAccent)),
//          BottomNavigationBarItem(
//              icon: Icon(Icons.favorite, color: Colors.grey),
//              title: Text("Мастера"),
//              activeIcon: Icon(Icons.favorite, color: Colors.blueAccent)),
          BottomNavigationBarItem(
              icon: Icon(Icons.people, color: Colors.grey),
              title: Text("Профиль"),
              activeIcon: Icon(Icons.people, color: Colors.blueAccent))
        ],
      ),
      body: profile.profileType == 0 ?
      clientPages[_page].safe() : (
      profile.profileType == 1 ?
      masterPages[_page].safe() : CircularProgressIndicator().center()
      )
    );
  }
}