import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cliente/models/user.dart';
import 'package:flutter/material.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';

class FinishedRequestsPage extends StatefulWidget {
  _FinishedRequestsPageState createState() => _FinishedRequestsPageState();
}

class _FinishedRequestsPageState extends State<FinishedRequestsPage>
    with AutomaticKeepAliveClientMixin {
  Firestore _db = Firestore.instance;
  SharedPreferences prefs;
  String userId;
  User user;
  int est = 0;

  @override
  void initState() {
    super.initState();
    _notificationCleaning();
    readLocal();
  }

  Future<void> readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
    userId = user.userId;
    setState(() {});
  }

  _notificationCleaning() async {
    await readLocal();
    _db.collection('donors').document(userId).updateData(
      {'finishedRequestNotification': null},
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (est == 0) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "HISTÓRICO VOLUNTÁRIO",
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  est = 1;
                });
              },
              child: Icon(Icons.autorenew),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: _db
              .collection('requestsVolunt')
              .where('donorId', isEqualTo: userId)
              .where('state', isEqualTo: 3)
              .orderBy('endTime')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              );
            } else {
              if (snapshot.data.documents.isEmpty) {
                return Center(
                    child:
                        Text("Você ainda não possui atendimentos finalizados"));
              } else {
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  itemCount: snapshot.data.documents.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return _buildListItem(
                        context, snapshot.data.documents[index]);
                  },
                );
              }
            }
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "HISTÓRICO ATENDIMENTO",
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  est = 0;
                });
              },
              child: Icon(Icons.autorenew),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: _db
              .collection('requestsMedic')
              .where('donorId', isEqualTo: userId)
              .where('state', isEqualTo: 3)
              .orderBy('endTime')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              );
            } else {
              if (snapshot.data.documents.isEmpty) {
                return Center(
                    child:
                        Text("Você ainda não possui atendimentos finalizados"));
              } else {
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  itemCount: snapshot.data.documents.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return _buildListItem(
                        context, snapshot.data.documents[index]);
                  },
                );
              }
            }
          },
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    String day, month, year;
    var date = DateTime.fromMillisecondsSinceEpoch(
      document['endTime'].seconds * 1000,
    );
    if (date.day < 10)
      day = "0${date.day}";
    else
      day = date.day.toString();
    if (date.month < 10)
      month = "0${date.month}";
    else
      month = date.month.toString();
    year = date.year.toString();
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        subtitle: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Text("DATA:")],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.access_time, color: Colors.black54, size: 20),
                      SizedBox(width: 6),
                      Text(
                        "$day/$month/$year",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text("ATIVIDADE:"),
              SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(FontAwesomeIcons.paperclip,
                      color: Colors.black54, size: 20),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "${document['trashAmount']}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text("DESCRIÇÃO:"),
              SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(FontAwesomeIcons.newspaper,
                      color: Colors.black54, size: 20),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "${document['trashType']}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text("ENDEREÇO:"),
              SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Icon(Icons.my_location, color: Colors.black54, size: 20),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      document['address'],
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
