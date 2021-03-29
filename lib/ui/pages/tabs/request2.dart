import 'dart:io';

import 'package:cliente/models/globals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cliente/ui/pages/tabs/create_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cliente/models/user.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cliente/ui/pages/tabs/new_home.dart';

import 'create_request2.dart';

class RequestPage2 extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage2>
    with AutomaticKeepAliveClientMixin {
  Firestore _db = Firestore.instance;
  int _chatNotification = 0;
  SharedPreferences prefs;
  String userId = '';
  User user;

  @override
  void initState() {
    _notificationCleaning();
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
    userId = user.userId;
    _checkNotifications();
    setState(() {});
  }

  _notificationCleaning() async {
    await readLocal();
    _db.collection('donors').document(userId).updateData(
      {'requestNotification': null},
    );
  }

  Future<bool> _verifyConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == '/')
          return true;
        else
          return false;
      });
      Flushbar(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
        message: "Falha de Conexão",
        duration: Duration(milliseconds: 1500),
        isDismissible: false,
      )..show(context);
      return false;
    }
    return false;
  }

  _checkNotifications() async {
    _db.collection('donors').document(userId).snapshots().listen((snapshot) {
      if (snapshot.data['chatNotification'] != null ||
          snapshot.data['chatNotification'] != 0) {
        if (mounted) {
          setState(() {
            _chatNotification = snapshot.data['chatNotification'];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _chatNotification = 0;
          });
        }
      }
    });
  }

  _verifyIfRequestCanBeDismissed(
      var weekDays, DateTime periodStart, DateTime periodEnd) {
    DateTime now = DateTime.now();
    DateTime periodStartMinus1 = DateTime(now.year, now.month, now.day,
        periodStart.hour - 1, periodStart.minute, 0, 0, 0);
    DateTime realPeriodTime = DateTime(now.year, now.month, now.day,
        periodEnd.hour, periodEnd.minute, 0, 0, 0);

    int currentWeekDay = now.weekday;
    if (currentWeekDay == 7) currentWeekDay = 0;

    if (weekDays[currentWeekDay]) {
      if ((now.isBefore(periodStartMinus1) || now.isAfter(realPeriodTime)))
        return true;
      else {
        Flushbar(
          message:
              "Só é possível dispensar um atendimento com uma hora de antecedência..",
          duration: Duration(seconds: 4),
          isDismissible: false,
        )..show(context);
        return false;
      }
    } else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      stream: _db
          .collection('requestsMedic')
          .where('donorId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingScaffold();
        } else {
          if (snapshot.data.documents.isEmpty) {
            block1 = false;
            return _buildCreateRequestScaffold();
          } else {
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              block1 = true;
              if ((snapshot.data.documents[i]['state'] == 1) ||
                  (snapshot.data.documents[i]['state'] == 2)) {
                return _buildRequestScaffold(snapshot.data.documents[i]);
              }
              block1 = false;
            }
            return _buildCreateRequestScaffold();
          }
        }
      },
    );
  }

  Widget _normalAppBar(String text) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            estado = 0;
          });
        },
      ),
      title: Text(text),
      centerTitle: true,
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Container(
          child: CircularProgressIndicator(
            strokeWidth: 5.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          height: 30.0,
          width: 30.0,
        ),
      ),
    );
  }

  Widget _buildRequestScaffold(DocumentSnapshot document) {
    return Scaffold(
      body: _buildRequestPanelBody(document),
    );
  }

  Widget _buildCreateRequestScaffold() {
    return Scaffold(
      body: CreateRequest2(),
    );
  }

  _dismissRequestDialog(DocumentSnapshot document) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          contentPadding: EdgeInsets.only(top: 12.0),
          content: Container(
            width: 318.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Icon(
                    Icons.not_interested,
                    color: Colors.black54,
                    size: 64.0,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 2.0),
                  child: Text(
                    "DISPENSAR AGENTE DA SAÚDE?",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
                  child: Text(
                    "NOTIFIQUE-O ANTES DE DISPENSA-LO!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withAlpha(200),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4.0)),
                          ),
                          child: Icon(
                            FontAwesomeIcons.timesCircle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (await _verifyConnection()) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed('/chat2');
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withAlpha(200),
                          ),
                          child: Icon(Icons.chat, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (await _verifyConnection()) {
                            var dismissedPickers = document['dismissedPickers'];
                            if (dismissedPickers == null)
                              dismissedPickers = [document['pickerId']];
                            else {
                              dismissedPickers =
                                  document['dismissedPickers'].toList();
                              dismissedPickers.add(document['pickerId']);
                            }

                            Navigator.of(context).pop();
                            document.reference.updateData({
                              'dismissedByDonor': true,
                              'pickerId': null,
                              'state': 1,
                              'pickerChatNotification': 0,
                              'dismissedPickers': dismissedPickers
                            }).then((doc) {
                              document.reference
                                  .collection('messages')
                                  .getDocuments()
                                  .then((snapshot) {
                                for (DocumentSnapshot doc
                                    in snapshot.documents) {
                                  doc.reference.delete();
                                }
                              });
                            }).catchError((err) {
                              Flushbar(
                                padding: EdgeInsets.symmetric(
                                    vertical: 24.0, horizontal: 12.0),
                                message:
                                    "Não foi possível dispensar o agente da saúde.",
                                duration: Duration(seconds: 3),
                                isDismissible: false,
                              )..show(context);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(4.0),
                            ),
                          ),
                          child: Icon(
                            FontAwesomeIcons.checkCircle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _cancelRequestDialog(DocumentSnapshot document) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          contentPadding: EdgeInsets.only(top: 12.0),
          content: Container(
            width: 318.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Icon(Icons.delete_forever,
                      color: Colors.black54, size: 64),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: Text(
                    "CANCELAR ATENDIMENTO?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 20.0),
                  child: Text(
                    "VOCÊ PODERÁ REALIZAR OUTRA SOLICITAÇÃO, APÓS CANCELAR ESTA.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          block1 = false;
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withAlpha(200),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(4.0),
                            ),
                          ),
                          child: Icon(
                            FontAwesomeIcons.timesCircle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (await _verifyConnection()) {
                            Navigator.of(context).pop();
                            await document.reference.delete().then((doc) {
                              _db
                                  .collection('donors')
                                  .document(userId)
                                  .updateData({
                                'chatNotification': 0,
                                'requestNotification': null,
                              });
                            }).catchError((err) {
                              Flushbar(
                                padding: EdgeInsets.symmetric(
                                    vertical: 24.0, horizontal: 12.0),
                                message:
                                    "Não foi possível cancelar o atendimento",
                                duration: Duration(seconds: 3),
                                isDismissible: false,
                              )..show(context);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(4.0),
                            ),
                          ),
                          child: Icon(
                            FontAwesomeIcons.checkCircle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget dataUnit(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 15),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Text(
                  text1,
                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 16),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                child: Text(
                  text2,
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestPanelBody(DocumentSnapshot document) {
    return StreamBuilder(
      stream: _db
          .collection('pickers')
          .where('userId', isEqualTo: document['pickerId'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map request = {
            'pickerId': document['pickerId'],
            'donorId': document['donorId'],
            'requestId': document.documentID,
          };
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  subtitle: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[],
                        ),
                        _buildSizedBox(),
                        Text("ENDEREÇO:"),
                        SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Icon(
                              Icons.my_location,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                document['address'].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        _buildSizedBox(),
                        Text("DISPONIBILIDADE:"),
                        SizedBox(height: 6),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "DE " +
                                  document['periodStart']
                                      .toDate()
                                      .toString()
                                      .substring(11, 16) +
                                  " ATÉ " +
                                  document['periodEnd']
                                      .toDate()
                                      .toString()
                                      .substring(11, 16),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildDayFieldRow(document),
                        _buildSizedBox(),
                        Text("SITUAÇÃO:"),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            document['state'] == 1
                                ? Icon(
                                    Icons.help_outline,
                                    color: Colors.blueAccent,
                                    size: 20,
                                  )
                                : Icon(
                                    Icons.error_outline,
                                    color: Colors.red[200],
                                    size: 20,
                                  ),
                            document['state'] == 1
                                ? Text(
                                    " BUSCANDO AGENTES DA SAÚDE",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                : Text(
                                    " ATENDIMENTO EM ANDAMENTO",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.red[200],
                                    ),
                                  ),
                          ],
                        ),
                        _buildSizedBox(),
                        _buildNotificationDot(
                          _chatNotification,
                          child: _buildButtonOption(
                            2,
                            'CHAT COM AGENTE DA SAÚDE',
                            document,
                            Icons.chat_bubble_outline,
                            Colors.orangeAccent,
                            () async {
                              Navigator.of(context).pushNamed(
                                '/chat2',
                                arguments: request,
                              );
                            },
                          ),
                        ),
                        _buildButtonOption(
                          2,
                          'DADOS DO AGENTE DA SAÚDE',
                          document,
                          Icons.info_outline,
                          Colors.blueAccent,
                          () async {
                            if (await _verifyConnection()) {
                              Navigator.of(context).pushNamed(
                                '/picker_info',
                                arguments: document['pickerId'],
                              );
                            }
                          },
                        ),
                        _buildButtonOption(
                          2,
                          'DISPENSAR AGENTE DA SAÚDE',
                          document,
                          Icons.not_interested,
                          Colors.redAccent,
                          () async {
                            if (_verifyIfRequestCanBeDismissed(
                                document['periodDays'],
                                document['periodStart'].toDate(),
                                document['periodEnd'].toDate())) {
                              _dismissRequestDialog(document);
                            }
                          },
                        ),
                        _buildButtonOption(
                          1,
                          'CANCELAR ATENDIMENTO',
                          document,
                          Icons.delete_forever,
                          Colors.redAccent,
                          () async {
                            _cancelRequestDialog(document);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Center(
            child: Container(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              height: 30.0,
              width: 30.0,
            ),
          );
        }
      },
    );
  }

  Widget _buildButtonOption(
      int necessaryState,
      String text,
      DocumentSnapshot document,
      IconData icon,
      Color color,
      Function onPressed) {
    if (document['state'] == necessaryState)
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: OutlineButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: color),
              SizedBox(width: 8.0),
              Text(text, style: TextStyle(color: color)),
            ],
          ),
          borderSide: BorderSide(color: color),
          highlightedBorderColor: color,
          onPressed: onPressed,
        ),
      );
    return Container();
  }

  Widget _buildSizedBox() {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.04);
  }

  Widget _buildDayFieldRow(DocumentSnapshot document) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildDayField("D", document['periodDays'][0]),
        _buildDayField("S", document['periodDays'][1]),
        _buildDayField("T", document['periodDays'][2]),
        _buildDayField("Q", document['periodDays'][3]),
        _buildDayField("Q", document['periodDays'][4]),
        _buildDayField("S", document['periodDays'][5]),
        _buildDayField("S", document['periodDays'][6]),
      ],
    );
  }

  Widget _buildDayField(String text, bool day) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: day ? Colors.grey : Colors.black54,
        ),
        color: day ? Colors.grey : Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: day ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildNotificationDot(int notification, {Widget child}) {
    return Stack(
      children: <Widget>[
        child,
        (notification != 0 && notification != null)
            ? Positioned(
                right: 0,
                child: CircleAvatar(
                  maxRadius: 10,
                  backgroundColor: Colors.red,
                  child: Center(
                    child: Text(
                      notification > 9 ? '+9' : notification.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 12.0),
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
