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

class CreateRequest2 extends StatefulWidget {
  @override
  _CreateRequest2State createState() => _CreateRequest2State();
}

class _CreateRequest2State extends State<CreateRequest2> {
  final TextEditingController _periodStartController = TextEditingController();
  final TextEditingController _periodEndController = TextEditingController();
  List<bool> days = [false, false, false, false, false, false, false];
  List<bool> quest = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _addressText = "Escolha um Endereço";
  String _allergyText = "Possui Alergia? Qual?";
  String _medicText = "Medicamentos em uso";
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
    return TextFormField(
      decoration: InputDecoration(
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.horizontal(),
          borderSide: new BorderSide(),
        ),
        hintText: queryCollection == 'medicText' ? _medicText : _allergyText,
      ),
      onChanged: (text) {
        setState(() {
          if (queryCollection == 'medicText')
            _medicText = text;
          else
            _allergyText = text;
        });
      },
    );
  }

  Widget _buildQuestField(String text, int position) {
    return GestureDetector(
      onTap: () {
        setState(() {
          quest[position] = !quest[position];
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: quest[position]
                ? Theme.of(context).primaryColor
                : Colors.black54,
          ),
          color:
              quest[position] ? Theme.of(context).primaryColor : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: quest[position] ? Colors.white : Colors.black54,
          ),
        ),
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
                'questAnswers': quest,
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
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  subtitle: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildSizedBox(),
                              Text('Você está com febre acima de 37,8°C?',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.black)),
                              _buildSizedBox(),
                              Text(
                                "Você está tossindo? ",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está espirrando, com o nariz escorrendo ou com nariz entupido?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com dificuldade para respirar, ou a respiração está\n ofegante?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com dor de garganta?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com dor ou sentindo pressão no peito?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com arrepios ou com calafrios?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com dor muscular?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Em crianças: batimento da asa do nariz?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com dificuldade em sentir cheiros?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com diarreia?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você está com os lábios ou a face arroxeados? ",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              Text(
                                "Você acha que está com confusão mental?",
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                              _buildSizedBox(),
                              _buildQuestField2("medicText"),
                              _buildSizedBox(),
                              _buildQuestField2("allergyText"),
                              _buildSizedBox(),
                              _buildCreateRequestButton()
                            ],
                          ),
                        )),
                        Container(
                            child: Column(
                          children: <Widget>[
                            _buildQuestField("", 0),
                            _buildSizedBox(),
                            _buildQuestField("", 1),
                            _buildSizedBox(),
                            _buildQuestField("", 2),
                            _buildSizedBox(),
                            _buildQuestField("", 3),
                            _buildSizedBox(),
                            _buildQuestField("", 4),
                            _buildSizedBox(),
                            _buildQuestField("", 5),
                            _buildSizedBox(),
                            _buildQuestField("", 6),
                            _buildSizedBox(),
                            _buildQuestField("", 7),
                            _buildSizedBox(),
                            _buildQuestField("", 8),
                            _buildSizedBox(),
                            _buildQuestField("", 9),
                            _buildSizedBox(),
                            _buildQuestField("", 10),
                            _buildSizedBox(),
                            _buildQuestField("", 11),
                            _buildSizedBox(),
                          ],
                        )),
                      ],
                    ),
                  ),
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
              padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 4.0),
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
