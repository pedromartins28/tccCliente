import 'package:firebase_auth/firebase_auth.dart';
import 'package:cliente/models/user.dart';

class StateModel {
  FirebaseUser authUser;
  bool isLoading;
  bool goAhead = false;
  User user;

  StateModel({
    this.isLoading = false,
    this.authUser,
    this.user,
  });
}
