import 'package:firebase_auth/firebase_auth.dart';
import 'package:cliente/models/user.dart';

class StateModel {
  FirebaseUser authUser;
  bool isLoading;
  bool goAhead;
  bool goAheadAux;
  User user;

  StateModel({
    this.isLoading = false,
    this.authUser,
    this.user,
    bool goAhead = false,
    bool goAheadAux = false,
  });
}
