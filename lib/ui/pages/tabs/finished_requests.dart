import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cliente/models/user.dart';
import 'package:flutter/material.dart';

class FinishedRequestsPage extends StatefulWidget {
  _FinishedRequestsPageState createState() => _FinishedRequestsPageState();
}

class _FinishedRequestsPageState extends State<FinishedRequestsPage>
    with AutomaticKeepAliveClientMixin {
  Firestore _db = Firestore.instance;
  SharedPreferences prefs;
  String userId;
  User user;

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "HISTÓRICO",
        ),
      ),
      body: StreamBuilder(
        stream: _db
            .collection('requests')
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
                  /*Container(
                    padding: EdgeInsets.only(
                      right: document['donorRating'] == null ? 20.0 : 8.0,
                    ),
                    child: document['donorRating'] == null
                        ? GestureDetector(
                            onTap: () {
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
                                    content: FinishedRequestDialog(document),
                                  );
                                },
                              );
                            },
                            /*child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.star,
                                  color: Theme.of(context).primaryColor,
                                  size: 14,
                                ),
                                SizedBox(width: 2.0),
                                Text(
                                  "AVALIAR",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),*/
                          )
                        : SmoothStarRating(
                            rating: document['donorRating'].toDouble(),
                            borderColor: Colors.black,
                            size: 20,
                          ),
                  ),*/
                ],
              ),
              SizedBox(height: 12),
              Text("RESÍDUO:"),
              SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(Icons.delete_outline, color: Colors.black54, size: 20),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "${document['trashAmount']} DE ${document['trashType']}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text("ENDEREÇO:"),
              SizedBox(height: 4),
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

class FinishedRequestDialog extends StatefulWidget {
  final DocumentSnapshot document;

  FinishedRequestDialog(this.document);

  @override
  _FinishedRequestDialogState createState() =>
      _FinishedRequestDialogState(document);
}

class _FinishedRequestDialogState extends State<FinishedRequestDialog> {
  Firestore _db = Firestore.instance;
  final DocumentSnapshot document;
  var rating = 0.0;

  _FinishedRequestDialogState(this.document);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 318.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 8.0),
            child: Icon(
              FontAwesomeIcons.checkCircle,
              color: Colors.black54,
              size: 64.0,
            ),
          ),
          /* Container(
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: Text(
              "AVALIAR O COLETOR",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
          ),*/
          SizedBox(height: 16.0),
          /*SmoothStarRating(
            color: Theme.of(context).primaryColor,
            borderColor: Colors.black54,
            allowHalfRating: true,
            rating: rating,
            size: 40.0,
            onRated: (value) {
              setState(() {
                rating = value;
              });
            },
          ),*/
          SizedBox(height: 12.0),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: InkWell(
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
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(200),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(4.0),
                      ),
                    ),
                    child: Icon(
                      FontAwesomeIcons.checkCircle,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    /*await document.reference.updateData(
                      {'donorRating': rating},
                    );*/
                    _db
                        .collection('pickers')
                        .document(document['pickerId'])
                        .get()
                        .then((DocumentSnapshot picker) async {
                      num finishedRequests = picker.data['finishedRequests'];
                      //num currentRating = picker.data['rating'];
                      await picker.reference.updateData({
                        'finishedRequests': FieldValue.increment(1),
                        /*'rating': (((finishedRequests.toDouble() + 5) *
                                    currentRating.toDouble()) +
                                rating) /
                            (finishedRequests.toDouble() + 6)*/
                      });
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
