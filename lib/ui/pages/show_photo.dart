import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ShowPhotoPage extends StatefulWidget {
  final Map data;

  ShowPhotoPage(this.data);

  @override
  _ShowPhotoPageState createState() => _ShowPhotoPageState(data);
}

class _ShowPhotoPageState extends State<ShowPhotoPage> {
  String userName = '';
  String photoUrl = '';
  final Map data;

  _ShowPhotoPageState(this.data);

  @override
  void initState() {
    photoUrl = data['photoUrl'];
    userName = data['name'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: Material(
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              placeholder: (context, url) => Container(
                child: CircularProgressIndicator(
                  strokeWidth: 5.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
              ),
              imageUrl: photoUrl,
              fit: BoxFit.cover,
            ),
            clipBehavior: Clip.hardEdge,
          ),
        ),
      ),
    );
  }
}
