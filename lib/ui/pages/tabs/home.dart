import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cliente/ui/pages/tabs/finished_requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cliente/util/notification_handler.dart';
import 'package:cliente/ui/pages/tabs/request.dart';
import 'package:cliente/ui/pages/tabs/user_info.dart';
import 'package:cliente/ui/widgets/loading.dart';
import 'package:cliente/util/state_widget.dart';
import 'package:cliente/ui/pages/sign.dart';
import 'package:cliente/models/state.dart';
import 'package:cliente/models/user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<_HomePageState> homePageState = GlobalKey<_HomePageState>();
  NotificationHandler notificationHandler;
  Firestore _db = Firestore.instance;
  bool _loadingVisible = false;
  TabController _tabController;
  StateModel appState;
  int currentTab = 0;

  bool _hasFinishedRequestNotification = false;
  bool _hasRequestNotification = false;
  bool _hasChatNotification = false;

  SharedPreferences prefs;
  String userId;
  User user;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    super.initState();
  }

  initNotifications() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
    userId = user.userId;

    notificationHandler = NotificationHandler(
        userId: userId, context: context, tabController: _tabController);
    notificationHandler.setupNotifications();
    _checkNotifications();
  }

  Future readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
  }

  _checkNotifications() async {
    _db.collection('donors').document(userId).snapshots().listen((snapshot) {
      if (snapshot.data['finishedRequestNotification'] != null) {
        if (_tabController.index != 0) {
          setState(() {
            _hasFinishedRequestNotification = true;
          });
        } else {
          _db.collection('donors').document(userId).updateData({
            'finishedRequestsNotification': null,
          });
        }
      } else {
        setState(() {
          _hasFinishedRequestNotification = false;
        });
      }
      if (snapshot.data['requestNotification'] != null) {
        if (_tabController.index != 1) {
          setState(() {
            _hasRequestNotification = true;
          });
        } else {
          _db.collection('donors').document(userId).updateData({
            'requestNotification': null,
          });
        }
      } else {
        setState(() {
          _hasRequestNotification = false;
        });
      }
      if (snapshot.data['chatNotification'] != null &&
          snapshot.data['chatNotification'] != 0) {
        setState(() {
          _hasChatNotification = true;
        });
      } else {
        setState(() {
          _hasChatNotification = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.authUser == null || appState.user == null)) {
      if (notificationHandler != null) notificationHandler.dispose();
      notificationHandler = null;
      return SignInPage();
    } else {
      if (appState.isLoading) {
        setState(() {
          _loadingVisible = true;
        });
        return Container();
      } else {
        if (notificationHandler == null) initNotifications();
        setState(() {
          _loadingVisible = false;
        });
        return Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 12.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.0, 12.0),
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                onTap: (value) {
                  if (value == 0) {
                    _db.collection('donors').document(userId).updateData({
                      'finishedRequestNotification': null,
                    });
                    setState(() {
                      _hasFinishedRequestNotification = false;
                    });
                  } else if (value == 1) {
                    _db.collection('donors').document(userId).updateData({
                      'requestNotification': null,
                    });
                    setState(() {
                      _hasRequestNotification = false;
                    });
                  }
                },
                unselectedLabelColor: Colors.black54,
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                tabs: [
                  _buildNotificationDot(
                    0,
                    _hasFinishedRequestNotification,
                    false,
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.only(top: 2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.listAlt, size: 20),
                          SizedBox(height: 6.0),
                          Text('HISTÓRICO', style: TextStyle(fontSize: 14))
                        ],
                      ),
                    ),
                  ),
                  _buildNotificationDot(
                    1,
                    _hasRequestNotification,
                    _hasChatNotification,
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.only(top: 2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.recycle, size: 20),
                          SizedBox(height: 6.0),
                          Text('COLETA', style: TextStyle(fontSize: 14))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(top: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.user, size: 20),
                        SizedBox(height: 6.0),
                        Text('PERFIL', style: TextStyle(fontSize: 14))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: LoadingPage(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                FinishedRequestsPage(),
                RequestPage(),
                UserInfoPage(),
              ],
            ),
            inAsyncCall: _loadingVisible,
          ),
        );
      }
    }
  }

  Widget _buildNotificationDot(
      int index, bool notification, bool secondNotification,
      {Widget child}) {
    return Stack(
      children: <Widget>[
        child,
        notification || secondNotification
            ? Positioned(
                top: 6,
                right: index == 0 ? 20 : 10,
                child: CircleAvatar(
                  maxRadius: 5.5,
                  backgroundColor: Colors.red,
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
