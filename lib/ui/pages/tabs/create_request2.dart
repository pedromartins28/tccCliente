import 'dart:io';

import 'package:cliente/models/globals.dart';
import 'package:cliente/ui/pages/tabs/new_home.dart';
import 'package:cliente/ui/widgets/loading.dart';
import 'package:cliente/models/chechLabel.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:cliente/models/user.dart';
import 'package:flushbar/flushbar.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';

class CreateRequest2 extends StatefulWidget {
  @override
  _CreateRequest2State createState() => _CreateRequest2State();
}

class _CreateRequest2State extends State<CreateRequest2> {
  final TextEditingController _periodStartController = TextEditingController();
  final TextEditingController _periodEndController = TextEditingController();
  List<bool> days = [false, false, false, false, false, false, false];
  bool _quest01 = false,
      _quest02 = false,
      _quest03 = false,
      _quest04 = false,
      _quest05 = false,
      _quest06 = false,
      _quest07 = false,
      _quest08 = false,
      _quest09 = false,
      _quest10 = false,
      _quest11 = false,
      _quest13 = false,
      _quest12 = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _addressText = "Escolha um Endereço";
  String _allergyText = "Possui Alergia? Qual?";
  String _medicText = "Está usando algum medicamento? Qual?";
  Firestore _db = Firestore.instance;
  List<String> addressList = [];
  bool _loadingVisible = false;
  DateTime _periodStart;
  DateTime _periodEnd;

  static final _apiKey = "AIzaSyBnaELr9Ggz-8v5BpJ9W4yykiOViLmDz8M";

  Location _midTownLocation = Location(-20.1524122, -44.9366794);
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: _apiKey);
  GeoPoint _location;

  SharedPreferences prefs;
  String userId;
  User user;
  int stt = 0;

  @override
  void initState() {
    readLocal();
    super.initState();
  }

  Widget _normalAppBar(String text) {
    return AppBar(
      title: Text(text),
      centerTitle: true,
    );
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
    userId = user.userId;
    setState(() {});
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
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

  Future<Null> displayPrediction(Prediction prediction) async {
    if (prediction != null) {
      String aux = _addressText;
      _addressText = "Carregando...";
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        prediction.placeId,
      );
      var address = await Geocoder.local.findAddressesFromQuery(
        prediction.description,
      );

      if (address[0].featureName != address[0].thoroughfare &&
          address[0].subAdminArea == 'Divinópolis' &&
          address[0].adminArea == 'Minas Gerais' &&
          address[0].thoroughfare != null &&
          address[0].featureName != null) {
        _addressText = address[0].thoroughfare + ", " + address[0].featureName;
        double lat = detail.result.geometry.location.lat;
        double lng = detail.result.geometry.location.lng;
        _location = GeoPoint(lat, lng);

        _db
            .collection('donors')
            .document(userId)
            .collection('locations')
            .document()
            .setData({
          'address': _addressText,
          'location': _location,
        });
      } else {
        setState(() {
          _addressText = aux;
        });
        Flushbar(
          message: "Endereço Inválido",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stt == 0) {
      return _buildPrincipalScaffold();
    } else {
      return _buildQuestionario();
    }
  }

  Widget _buildSizedBox() {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.05);
  }

  _buildAddressDropdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          border: Border.all(width: 0.75, color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: StreamBuilder(
            stream: _db
                .collection('donors')
                .document(userId)
                .collection('locations')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return DropdownButton(
                  onChanged: null,
                  items: null,
                  iconSize: 28.0,
                  elevation: 2,
                  disabledHint: Row(
                    children: <Widget>[
                      Icon(Icons.my_location, color: Colors.black54),
                      SizedBox(width: 12.0),
                      Text(
                        "Carregando...",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                );
              } else {
                List<DropdownMenuItem<Map>> list =
                    List<DropdownMenuItem<Map>>();

                if (snapshot.data.documents.isNotEmpty) {
                  for (int i = 0; i < snapshot.data.documents.length; i++) {
                    list.add(
                      DropdownMenuItem(
                        value: {
                          'address': snapshot.data.documents[i]['address'],
                          'location': snapshot.data.documents[i]['location']
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: Text(
                              snapshot.data.documents[i]['address'],
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }

                if (snapshot.data.documents.length < 5) {
                  list.add(DropdownMenuItem(
                    value: {'address': "add", 'location': null},
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 8.0),
                        Text("Adicionar Endereço"),
                      ],
                    ),
                  ));
                }
                if (snapshot.data.documents.length > 0) {
                  list.add(DropdownMenuItem(
                    value: {'address': "delete", 'location': null},
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        SizedBox(width: 8.0),
                        Text("Remover Endereço"),
                      ],
                    ),
                  ));
                }

                return Material(
                  child: DropdownButton<Map>(
                    iconSize: 28.0,
                    elevation: 2,
                    items: list,
                    onChanged: (choice) async {
                      if (choice['address'] == "add") {
                        Prediction prediction = await PlacesAutocomplete.show(
                          location: _midTownLocation,
                          hint: "Digite o Endereço",
                          mode: Mode.fullscreen,
                          strictbounds: true,
                          language: 'pt-BR',
                          context: context,
                          apiKey: _apiKey,
                          radius: 16777,
                        );
                        displayPrediction(prediction);
                      } else if (choice['address'] == "delete") {
                        removeLocationDialog(snapshot.data.documents);
                      } else {
                        setState(() {
                          _addressText = choice['address'];
                          _location = choice['location'];
                        });
                      }
                    },
                    hint: Row(
                      children: <Widget>[
                        Icon(Icons.my_location, color: Colors.black54),
                        SizedBox(width: 12.0),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.67,
                          child: Text(
                            _addressText,
                            style: TextStyle(color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayFieldRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildDayField("D", 0),
        _buildDayField("S", 1),
        _buildDayField("T", 2),
        _buildDayField("Q", 3),
        _buildDayField("Q", 4),
        _buildDayField("S", 5),
        _buildDayField("S", 6),
      ],
    );
  }

  Widget _buildQuestField2(String queryCollection) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(7, 10, 0, 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: Colors.white60,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: Colors.white60,
              width: 2.0,
            ),
          ),
          hintText: queryCollection == 'medicText' ? _medicText : _allergyText,
          hintStyle: TextStyle(fontSize: 18.0, color: Colors.white60),
        ),
        onChanged: (text) {
          setState(() {
            if (queryCollection == 'medicText')
              _medicText = text;
            else
              _allergyText = text;
          });
        },
      ),
    );
  }

  Widget _buildDayField(String text, int position) {
    return GestureDetector(
      onTap: () {
        setState(() {
          days[position] = !days[position];
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: days[position]
                ? Theme.of(context).primaryColor
                : Colors.black54,
          ),
          color: days[position] ? Theme.of(context).primaryColor : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: days[position] ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildStartClockField(String text, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
        SizedBox(width: 4),
        Text(controller.text, style: TextStyle(fontSize: 20)),
        Material(
          child: IconButton(
            onPressed: () {
              DatePicker.showDatePicker(
                context,
                locale: DateTimePickerLocale.pt_br,
                minDateTime: DateTime.parse('2010-05-12 07:00:00'),
                maxDateTime: _periodEnd != null
                    ? DateTime(
                        _periodEnd.year,
                        _periodEnd.month,
                        _periodEnd.day,
                        _periodEnd.hour - 1,
                        _periodEnd.minute,
                        0,
                        0,
                        0,
                      )
                    : DateTime.parse('2100-11-25 21:00:00'),
                initialDateTime: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  13,
                  0,
                  0,
                  0,
                  0,
                ),
                dateFormat: 'H:m',
                pickerMode: DateTimePickerMode.time,
                pickerTheme: DateTimePickerTheme(
                  backgroundColor: Theme.of(context).backgroundColor,
                  cancel: Text(
                    "Cancelar",
                    style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  confirm: Text(
                    "Confirmar",
                    style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                onConfirm: (date, integers) {
                  if (_periodEnd == null) {
                    setState(() {
                      controller.text =
                          "$date".substring(11, "$date".length - 7);
                      _periodStart = date;
                    });
                  } else {
                    setState(() {
                      controller.text =
                          "$date".substring(11, "$date".length - 7);
                      _periodStart = date;
                    });
                  }
                },
              );
            },
            icon: Icon(Icons.access_time, color: Colors.black87, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishClockField(String text, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
        SizedBox(width: 4),
        Text(controller.text, style: TextStyle(fontSize: 20)),
        Material(
          child: IconButton(
            onPressed: () {
              DatePicker.showDatePicker(
                context,
                locale: DateTimePickerLocale.pt_br,
                minDateTime: _periodStart != null
                    ? DateTime(
                        _periodStart.year,
                        _periodStart.month,
                        _periodStart.day,
                        _periodStart.hour + 1,
                        _periodStart.minute,
                        0,
                        0,
                        0,
                      )
                    : DateTime.parse('2010-05-12 08:00:00'),
                maxDateTime: DateTime.parse('2100-11-25 22:00:01'),
                initialDateTime: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  13,
                  0,
                  0,
                  0,
                  0,
                ),
                dateFormat: 'H:m',
                pickerMode: DateTimePickerMode.time,
                // show TimePicker
                pickerTheme: DateTimePickerTheme(
                  backgroundColor: Theme.of(context).backgroundColor,
                  cancel: Text(
                    "Cancelar",
                    style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  confirm: Text(
                    "Confirmar",
                    style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                onConfirm: (date, integers) {
                  setState(() {
                    controller.text = "$date".substring(11, "$date".length - 7);
                    _periodEnd = date;
                  });
                },
              );
            },
            icon: Icon(Icons.access_time, color: Colors.black87, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 2.0),
            Text(
              'PRÓXIMA PÁGINA',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        color: Theme.of(context).primaryColor,
        onPressed: () async {
          if (_addressText != "Escolha um Endereço" &&
              _addressText != "Carregando..." &&
              _periodEnd != null &&
              _periodStart != null &&
              days.contains(true)) {
            setState(() {
              stt = 1;
            });
          } else {
            setState(() {
              _loadingVisible = false;
            });
            Flushbar(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              message: "Preencha todos os campos para criar a solicitação",
              duration: Duration(seconds: 3),
              isDismissible: false,
            )..show(context);
          }
        });
  }

  Widget _buildCreateRequestButton() {
    return RaisedButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 2.0),
          Text(
            'SOLICITAR',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      color: Theme.of(context).primaryColor,
      onPressed: () async {
        _changeLoadingVisible();
        if (_addressText != "Escolha um Endereço" &&
            _addressText != "Carregando..." &&
            _periodEnd != null &&
            _periodStart != null &&
            days.contains(true)) {
          if (await _verifyConnection()) {
            zerarForm();
            block1 = true;
            Future.delayed(Duration(seconds: 1), () {
              _db.collection('requestsMedic').add({
                'periodStart': Timestamp.fromDate(_periodStart),
                'periodEnd': Timestamp.fromDate(_periodEnd),
                'trashAmount': 'Atendimento',
                'address': _addressText,
                'trashType': 'Individual',
                'location': _location,
                'donorId': userId,
                'state': 1,
                'periodDays': days,
                'quest01': _quest01,
                'quest02': _quest02,
                'quest03': _quest03,
                'quest04': _quest04,
                'quest05': _quest05,
                'quest06': _quest06,
                'quest07': _quest07,
                'quest08': _quest08,
                'quest09': _quest09,
                'quest10': _quest10,
                'quest11': _quest11,
                'quest12': _quest12,
                'quest13': _quest13,
                'medicText': _medicText,
                'allergyText': _allergyText,
                'occupation': 'medico',
              }).then((doc) {
                _db.collection('donors').document(userId).updateData({
                  'chatNotification': 0,
                  'requestNotification': null,
                });
              }).catchError((err) {
                setState(() {
                  _loadingVisible = false;
                });
                Flushbar(
                  padding:
                      EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                  message: "Não foi possível criar a solicitação",
                  duration: Duration(seconds: 3),
                  isDismissible: false,
                )..show(context);
              });
            });
          } else {
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                _loadingVisible = false;
              });
              Flushbar(
                padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                message: "Falha de Conexão",
                duration: Duration(seconds: 3),
                isDismissible: false,
              )..show(context);
            });
          }
        } else {
          setState(() {
            _loadingVisible = false;
          });
          Flushbar(
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            message: "Preencha todos os campos para criar a solicitação",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);
        }
      },
    );
  }

  Widget _buildQuestionario() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('PREENCHA O FORMULÁRIO:'),
      ),
      body: Center(
        child: LoadingPage(
          inAsyncCall: _loadingVisible,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(6.0, 24.0, 6.0, 24.0),
              child: Card(
                color: Colors.red[200],
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          LabeledCheckbox(
                            label: 'Você está com febre acima de 37,8°C?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest01,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest01 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label: 'Você está tossindo?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest02,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest02 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label:
                                'Você está espirrando, com o nariz escorrendo ou com nariz entupido?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest03,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest03 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label:
                                'Você está com dificuldade para respirar, ou a respiração está\n ofegante?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest04,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest04 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label: 'Você está com dor de garganta?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest05,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest05 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label:
                                'Você está com dor ou sentindo pressão no peito?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest06,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest06 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label: 'Você está com arrepios ou com calafrios?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest07,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest07 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label: 'Você está com dor muscular?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest08,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest08 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label: 'Em crianças: batimento da asa do nariz?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest09,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest09 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label:
                                'Você está com dificuldade em sentir cheiros?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest10,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest10 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label: 'Você está com diarreia?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest11,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest11 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label:
                                'Você está com os lábios ou a face arroxeados?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest12,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest12 = newValue;
                              });
                            },
                          ),
                          LabeledCheckbox(
                            label: 'Você acha que está com confusão mental?',
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                            value: _quest13,
                            onChanged: (bool newValue) {
                              setState(() {
                                _quest13 = newValue;
                              });
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          _buildQuestField2("medicText"),
                          SizedBox(
                            height: 20,
                          ),
                          _buildQuestField2("allergyText"),
                          SizedBox(
                            height: 20,
                          ),
                          _buildCreateRequestButton()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrincipalScaffold() {
    return Scaffold(
      body: Center(
          child: LoadingPage(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildAddressDropdown(),
                  _buildSizedBox(),
                  _buildSizedBox(),
                  Text(
                    "PERÍODOS DE DISPONIBILIDADE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "SELECIONE OS DIAS E A HORA EM QUE VOCÊ DESEJA SER ATENDIDO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 12),
                  _buildDayFieldRow(),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _buildStartClockField("DE: ", _periodStartController),
                      _buildFinishClockField("ATÉ: ", _periodEndController),
                    ],
                  ),
                  _buildSizedBox(),
                  _buildNextButton(),
                  _buildSizedBox()
                ],
              ),
            ),
          ),
        ),
        inAsyncCall: _loadingVisible,
      )),
    );
  }

  removeLocationDialog(List<DocumentSnapshot> documents) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          contentPadding: EdgeInsets.only(top: 12.0),
          content: Container(
            padding: EdgeInsets.all(8.0),
            width: 318.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent.withAlpha(200),
                    size: 64.0,
                  ),
                  margin: EdgeInsets.only(bottom: 8.0),
                ),
                Text(
                  "CLIQUE PARA REMOVER O ENDEREÇO QUE DESEJA",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                  color: Colors.grey,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(documents[index]['address']),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent.withAlpha(200),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          documents[index].reference.delete();
                          if (documents[index]['address'] == _addressText) {
                            setState(() {
                              _addressText = "Escolha um Endereço";
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void zerarForm() async {
  prefs = await SharedPreferences.getInstance();
  user = userFromJson(prefs.getString('user'));
  userId = user.userId;
  Firestore.instance.collection('donors').document(userId).updateData(
    {
      'quest01': false,
      'quest02': false,
      'quest03': false,
      'quest04': false,
      'quest05': false,
      'quest06': false,
      'quest07': false,
      'quest08': false,
      'quest09': false,
      'quest10': false,
      'quest11': false,
      'quest12': false,
      'quest13': false,
      'quest14': false,
      'quest15': false,
      'quest16': false,
      'quest17': false,
      'quest18': false,
      'quest19': false,
      'quest20': '',
    },
  );
}
