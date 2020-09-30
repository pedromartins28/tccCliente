import 'package:firebase_auth/firebase_auth.dart';
import 'package:cliente/models/user.dart';

class StateModel {
  FirebaseUser authUser;
  bool isLoading;
  int goAhead = 0;
  User user;

  StateModel({
    this.isLoading = false,
    this.authUser,
    this.user,
    this.goAhead,
  });
}
