import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cliente/util/state_widget.dart';
import 'package:cliente/models/state.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'dart:io';

class NotificationHandler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging providerMessaging = FirebaseMessaging();
  final BuildContext context;
  final String userId;
  StateModel appState;
  TabController tabController;
  Firestore _db = Firestore.instance;

  NotificationHandler({this.context, this.userId, this.tabController});

  dispose() {
    providerMessaging.deleteInstanceID();
    flutterLocalNotificationsPlugin.cancelAll();
  }

  setupNotifications() {
    appState = StateWidget.of(context).state;
    registerNotification();
    configLocalNotification();
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'app.coronapp.cliente' : 'app.coronapp.cliente',
      'Recicle+ Donor',
      'Notification for Donors',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: json.encode(message));
  }

  void registerNotification() async {
    providerMessaging.requestNotificationPermissions();

    providerMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('donors')
          .document(userId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Flushbar(
        message: err.message.toString(),
        duration: Duration(seconds: 3),
        isDismissible: false,
      )..show(context);
    });

    providerMessaging.configure(onMessage: (Map<String, dynamic> notification) {
      print('onMessage: $notification');

      bool isChatCurrent = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == '/chat' || route.settings.name == '/chat2')
          isChatCurrent = true;
        return true;
      });

      if (!isChatCurrent)
        showNotification(notification);
      else
        _db
            .collection('donors')
            .document(userId)
            .updateData({'chatNotification': 0});

      return;
    }, onResume: (Map<String, dynamic> notification) {
      print('onResume: $notification');
      _notificationHandler(notification);
      return;
    }, onLaunch: (Map<String, dynamic> notification) {
      print('onLaunch: $notification');
      _notificationHandler(notification);
      return;
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      Map notification = json.decode(payload);
      _notificationHandler(notification);
    }
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  _notificationHandler(Map<String, dynamic> notification) {
    if (appState.authUser != null) {
      String notificationType = notification['data']['type'];
      if (notificationType == 'message') {
        bool isChatCurrent = false;
        Navigator.of(context).popUntil((route) {
          if (route.settings.name == '/chat' ||
              route.settings.name == '/chat2') {
            isChatCurrent = true;
            return true;
          }
          if (route.settings.name == '/') return true;
          return false;
        });
        tabController.animateTo(1);

        if (!isChatCurrent) Navigator.of(context).pushNamed('/');
      } else if (notificationType == 'accept' ||
          notificationType == 'dismiss') {
        _db.collection('donors').document(userId).updateData({
          'requestNotification': null,
        });
        Navigator.of(context).popUntil((route) {
          if (route.settings.name == '/') return true;
          return false;
        });
        tabController.animateTo(1);
      } else if (notificationType == 'finish') {
        _db.collection('donors').document(userId).updateData({
          'finishedRequestsNotification': null,
        });
        Navigator.of(context).popUntil((route) {
          if (route.settings.name == '/') return true;
          return false;
        });
        tabController.animateTo(0);
      }
    }
  }
}
