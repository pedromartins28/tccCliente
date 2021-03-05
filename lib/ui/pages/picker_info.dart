import 'package:cached_network_image/cached_network_image.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PickerInfoPage extends StatefulWidget {
  final String userId;

  @required
  PickerInfoPage(this.userId);

  @override
  _PickerInfoPageState createState() => _PickerInfoPageState(userId);
}

class _PickerInfoPageState extends State<PickerInfoPage> {
  final String userId;

  _PickerInfoPageState(this.userId);

  Widget _normalAppBar(String text) {
    return AppBar(
      title: Text(text),
      centerTitle: true,
    );
  }

  Widget _buildLoadingBody() {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _normalAppBar("DADOS DO FUNCIONÁRIO"),
        backgroundColor: Theme.of(context).backgroundColor,
        body: StreamBuilder(
          stream: Firestore.instance
              .collection('pickers')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildLoadingBody();
            } else {
              var pickerFinishedRequests =
                  snapshot.data.documents[0]['finishedRequests'];
              String photoUrl = snapshot.data.documents[0]['photoUrl'];
              //num inputRating = snapshot.data.documents[0]['rating'];
              String name = snapshot.data.documents[0]['name'];
              //double rating = inputRating.toDouble();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 8.0),
                        Container(
                          child: photoUrl != null
                              ? GestureDetector(
                                  onTap: () => Navigator.of(context).pushNamed(
                                        '/show_photo',
                                        arguments: {
                                          'name': name,
                                          'photoUrl': photoUrl
                                        },
                                      ),
                                  child: Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 5.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        width: 120.0,
                                        height: 120.0,
                                      ),
                                      imageUrl: photoUrl,
                                      width: 120.0,
                                      height: 120.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(60.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ))
                              : Icon(
                                  Icons.account_circle,
                                  size: 120.0,
                                  color: Theme.of(context).primaryColor,
                                ),
                        ),
                        SizedBox(height: 4.0),
                        //Center(child: SmoothStarRating(rating: rating)),
                        /*Text(
                          rating.toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                          ),
                        ),*/
                        SizedBox(height: 16.0),
                        Divider(
                          height: 1.0,
                          indent: 8.0,
                          endIndent: 8.0,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8.0),
                        dataUnit('NOME: ', name),
                        dataUnit(
                          'ATENDIMENTOS REALIZADOS: ',
                          pickerFinishedRequests.toStringAsFixed(0),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                    child: photoUrl != null
                        ? GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                  '/show_photo',
                                  arguments: {
                                    'name': name,
                                    'photoUrl': photoUrl
                                  },
                                ),
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  width: 120.0,
                                  height: 120.0,
                                ),
                                imageUrl: photoUrl,
                                width: 120.0,
                                height: 120.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(60.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ))
                        : Icon(
                            Icons.account_circle,
                            size: 120.0,
                            color: Theme.of(context).primaryColor,
                          ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 23,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  /*Center(
                    child: SmoothStarRating(
                      rating: rating,
                    ),
                  ),*/
                  SizedBox(height: 10),
                  Divider(
                    color: Theme.of(context).primaryColor,
                    endIndent: 10.0,
                    indent: 10,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget dataUnit(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 0.0, 16.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Text(
                  text1,
                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 15),
                ),
              )
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Container(
                child: Text(
                  text2,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
