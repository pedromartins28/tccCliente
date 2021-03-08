import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cliente/ui/widgets/dot_loader.dart';
import 'package:cliente/models/user.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class ChatPage2 extends StatefulWidget {
  _ChatPage2State createState() => _ChatPage2State();
}

class _ChatPage2State extends State<ChatPage2> {
  TextEditingController _messageController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();
  final Firestore _db = Firestore.instance;
  bool _visible = false;
  String pickerName;
  String pickerId;

  SharedPreferences prefs;
  String userId = '';
  User user;

  @override
  void initState() {
    _notificationCleaning();
    super.initState();
  }

  Future<void> readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
    userId = user.userId;
    setState(() {});
  }

  Future<bool> _verifyConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  _notificationCleaning() async {
    await readLocal();
    _db.collection('donors').document(userId).updateData(
      {'chatNotification': 0},
    );
  }

  Future<void> callback(DocumentSnapshot document) async {
    if (await _verifyConnection()) {
      if (_messageController.text.length > 0) {
        document.reference.collection('messages').document().setData({
          'date': Timestamp.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch,
          ),
          'requestId': document.documentID,
          'text': _messageController.text,
          'sentByDonor': true,
          'to': pickerId,
          'from': userId,
        });
        _messageController.clear();
        _listScrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        document.reference.updateData(
          {'pickerChatNotification': FieldValue.increment(1)},
        );
      }
    } else {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      _disconnectedDialog();
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: _defaultAppBar(),
      body: StreamBuilder(
        stream: _db
            .collection('requestsMedic')
            .where('donorId', isEqualTo: userId)
            .where('state', isEqualTo: 2)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return JumpingText(
              ". . .",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).primaryColor,
              ),
            );
          } else {
            if (snapshot.data.documents.isEmpty) {
              return Center(
                child: Text(
                  "Você não está em um atendimento no momento",
                ),
              );
            } else {
              DocumentSnapshot document = snapshot.data.documents[0];
              pickerId = document['pickerId'];
              if (pickerName == null) {
                _db
                    .collection('pickers')
                    .document(document['pickerId'])
                    .get()
                    .then((picker) {
                  setState(() {
                    pickerName = picker.data['name'];
                  });
                  Future.delayed(Duration(milliseconds: 100), () {
                    setState(() {
                      _visible = true;
                    });
                  });
                });
              }

              return Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('requestsMedic')
                              .document(document.documentID)
                              .collection('messages')
                              .orderBy('date', descending: true)
                              .limit(20)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return JumpingText(
                                ". . .",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            } else {
                              return ListView.builder(
                                reverse: true,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) => Message(
                                  date: snapshot.data.documents[index]['date'],
                                  text: snapshot.data.documents[index]['text'],
                                  me: userId ==
                                      snapshot.data.documents[index]['from'],
                                ),
                                controller: _listScrollController,
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        color: Colors.grey.shade200,
                        width: double.infinity,
                        height: 54,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                onSubmitted: (value) => callback(document),
                                decoration: InputDecoration.collapsed(
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Digite aqui...',
                                ),
                                controller: _messageController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () => callback(document),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }

  _disconnectedDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          content: Container(
            padding: EdgeInsets.all(8.0),
            width: 318.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.grey,
                    size: 64.0,
                  ),
                  margin: EdgeInsets.only(bottom: 8.0),
                ),
                Text(
                  "SEM CONEXÃO",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.0),
                Text(
                  "Não foi possível enviar a mensagem",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _defaultAppBar() {
    return AppBar(
      title: pickerName == null
          ? FadingText(
              '. . . .',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            )
          : AnimatedOpacity(
              child: Text(pickerName),
              opacity: _visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
            ),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await SystemChannels.textInput.invokeMethod('TextInput.hide');
              Navigator.of(context).pop();
            },
          );
        },
      ),
      centerTitle: true,
    );
  }
}

class Message extends StatelessWidget {
  final Timestamp date;
  final String text;
  final bool me;

  const Message({Key key, this.date, this.text, this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(me ? 72.0 : 12.0, 4.0, me ? 12.0 : 72.0, 4.0),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: me
                  ? Theme.of(context).primaryColor.withAlpha(150)
                  : Colors.grey.withAlpha(50),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
            child: Text(
              text,
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            _getDateInString(date),
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateInString(Timestamp when) {
    String weekDay;
    String hour;
    switch (when.toDate().weekday) {
      case 1:
        weekDay = "Seg";
        break;
      case 2:
        weekDay = "Ter";
        break;
      case 3:
        weekDay = "Qua";
        break;
      case 4:
        weekDay = "Qui";
        break;
      case 5:
        weekDay = "Sex";
        break;
      case 6:
        weekDay = "Sab";
        break;
      case 7:
        weekDay = "Dom";
        break;
    }
    hour = when.toDate().toString().substring(11, 16);
    return weekDay + " - " + hour;
  }
}
