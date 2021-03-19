import 'package:firebase_auth/firebase_auth.dart';
import 'package:cliente/models/user.dart';

class StateModel {
  FirebaseUser authUser;
  bool isLoading;
  bool goAhead;
  bool goAheadAux;
  bool naoCadastrou;
  User user;

  StateModel({
    this.isLoading = false,
    this.authUser,
    this.user,
    this.goAhead = false,
    this.goAheadAux = false,
    this.naoCadastrou = false,
  });
}
