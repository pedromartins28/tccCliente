import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cliente/models/user.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class Auth {
  static setUserActive(String userId) {
    Firestore.instance.collection('donors').document(userId).updateData(
      {'isActive': true},
    );
  }

  static setUserNotActive(String userId) {
    Firestore.instance.collection('donors').document(userId).updateData(
      {'isActive': false},
    );
  }

  static Future<AuthResult> phoneSignIn(AuthCredential credential) async {
    AuthResult result = await FirebaseAuth.instance
        .signInWithCredential(credential)
        .catchError((error) {
      print("Failed to verify SMS code: $error");
    });
    return result;
  }

  static Future<bool> alreadyPhoneSignedIn(String phone) async {
    var result = await Firestore.instance
        .collection('phones')
        .getDocuments()
        .then((QuerySnapshot snapshots) {
      List<DocumentSnapshot> documents = snapshots.documents;
      if (documents.isNotEmpty) {
        for (int i = 0; i < documents.length; i++) {
          if (documents[i]['phone'] == phone) return true;
        }
        return false;
      } else
        return false;
    }).catchError((error) {
      print("Falha ao verificar se o usuario existe: $error");
      return null;
    });
    return result;
  }

  static void addUserToDB(User user, String phone) async {
    var result = Firestore.instance
        .document("donors/${user.userId}")
        .setData(user.toJson())
        .then((onValue) {
      Firestore.instance
          .collection('phones')
          .add({'phone': phone}).then((onValue) {
        return true;
      }).catchError((onError) {
        return false;
      });
    }).catchError((onError) {
      return false;
    });
    return result;
  }

  static Future<bool> checkUserExist(String userId) async {
    bool exists = false;
    try {
      await Firestore.instance.document("pickers/$userId").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  static Future<User> getUserFromDB(String userId) async {
    if (userId != null) {
      return Firestore.instance
          .collection('donors')
          .document(userId)
          .get()
          .then((documentSnapshot) => User.fromDocument(documentSnapshot));
    } else {
      return null;
    }
  }

  static Future<String> storeUserLocal(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeUser = userToJson(user);
    await prefs.setString('user', storeUser);
    return user.userId;
  }

  static Future<FirebaseUser> getCurrentAuthUser() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    return currentUser;
  }

  static Future<User> getUserLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user') != null) {
      User user = userFromJson(prefs.getString('user'));
      return user;
    } else {
      return null;
    }
  }

  static Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    FirebaseAuth.instance.signOut();
  }

  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'Esse e-mail não está cadastrado.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'E-mail ou senha incorretos.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'Sem conexão com a internet.';
          break;
        case 'The email address is already in use by another account.':
          return 'Esse e-mail ja está cadastrado';
          break;
        default:
          return 'Erro desconhecido.';
      }
    } else {
      return 'Erro desconhecido.';
    }
  }
}
