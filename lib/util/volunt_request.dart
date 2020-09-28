import 'dart:io';

import 'package:cliente/ui/widgets/loading.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:cliente/models/user.dart';
import 'package:flushbar/flushbar.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';

class VoluntRequest extends StatefulWidget {
  @override
  _VoluntRequestState createState() => _VoluntRequestState();
}

class _VoluntRequestState extends State<VoluntRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SOLICITAR VOLUNTÁRIO"),
        centerTitle: true,
      ),
    );
  }
}
