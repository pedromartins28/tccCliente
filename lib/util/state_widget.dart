import 'package:firebase_auth/firebase_auth.dart';
import 'package:cliente/models/state.dart';
import 'package:flutter/foundation.dart';
import 'package:cliente/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cliente/util/auth.dart';
import 'dart:async';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({@required this.child, this.state});

  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;

  @override
  void initState() {
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = StateModel(isLoading: true);
      initUser();
    }
  }

  Future<Null> initUser() async {
    FirebaseUser authUser = await Auth.getCurrentAuthUser();
    User user = await Auth.getUserLocal();
    setState(() {
      state.authUser = authUser;
      state.isLoading = false;
      state.user = user;
    });
  }

  Future<void> logOutUser() async {
    await Auth.setUserNotActive(state.user.userId);
    await Auth.signOut();
    setState(() {
      state.user = null;
      state.authUser = null;
    });
  }

  Future<void> signInUser(String userId) async {
    User user = await Auth.getUserFromDB(userId);
    await Auth.storeUserLocal(user);
    await Auth.setUserActive(userId);
    await initUser();
  }

  @override
  Widget build(BuildContext context) {
    return _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
