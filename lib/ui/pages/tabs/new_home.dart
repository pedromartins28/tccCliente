import 'dart:io';
import 'package:cliente/ui/pages/tabs/home.dart';
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

class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  bool _loadingVisible = false;
  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  @override
  Widget _buildVoluntarioButton() {
    return RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 2.0),
            Text(
              'Solicitar Voluntário',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/volunt');
        });
  }

  Widget _buildAtendimentoButton() {
    return RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 2.0),
            Text(
              'Solicitar Atendimento',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, '/medic');
        });
  }

  Widget _buildTutorialButton() {
    return RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 2.0),
            Text(
              'Tutorial EPI',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        color: Theme.of(context).primaryColor,
        onPressed: () {});
  }

  Widget _normalAppBar(String text) {
    return AppBar(
      title: Text(text),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    /*return LoadingPage(
      opacity: 0.2,
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
      ),
      inAsyncCall: _loadingVisible,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 4.0),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            _buildVoluntarioButton(),
            _buildAtendimentoButton(),
            _buildTutorialButton(),
          ],
        ),
      ),
    );*/
    return Scaffold(
      appBar: _normalAppBar("INÍCIO"),
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 4.0),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 150.0,
                child: Image.asset(
                  'assets/logo.png',
                  height: 550,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              _buildVoluntarioButton(),
              const SizedBox(height: 30),
              _buildAtendimentoButton(),
              const SizedBox(height: 30),
              _buildTutorialButton(),
            ],
          ),
        ),
      ),
    );
  }
}
