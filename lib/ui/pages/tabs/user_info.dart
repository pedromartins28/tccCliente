import 'package:cached_network_image/cached_network_image.dart';
import 'package:cliente/ui/pages/signForm.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cliente/util/image_handler.dart';
import 'package:cliente/util/state_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:flushbar/flushbar.dart';
import 'package:cliente/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cliente/util/auth.dart';
import 'dart:async';
import 'dart:io';

class UserInfoPage extends StatefulWidget {
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage>
    with
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin,
        ImagePickerListener {
  ImageHandler imagePicker;
  bool isLoading = false;
  String photoUrl = '';

  SharedPreferences prefs;
  String userId = '';
  User user;

  @override
  void initState() {
    readLocal();
    imagePicker = ImageHandler(this, this.context);
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void readLocal() async {
    user = await Auth.getUserLocal();
    userId = user.userId;
    print(user.toJson().toString());
    setState(() {});
  }

  @override
  userImage(File _image) {
    if (_image != null) uploadFile(_image);
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

  Future uploadFile(File file) async {
    String fileName = userId;
    setState(() {
      isLoading = true;
    });
    if (await _verifyConnection()) {
      try {
        StorageReference reference =
            FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = reference.putFile(file);
        StorageTaskSnapshot storageTaskSnapshot;
        uploadTask.onComplete.then((value) {
          if (value.error == null) {
            storageTaskSnapshot = value;
            storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
              photoUrl = downloadUrl;
              Firestore.instance
                  .collection('donors')
                  .document(userId)
                  .updateData(
                {'photoUrl': photoUrl},
              ).then((data) async {
                Flushbar(
                  message: "Foto Atualizada com sucesso",
                  duration: Duration(seconds: 3),
                  isDismissible: false,
                )..show(context);
                setState(() {
                  isLoading = false;
                });
              }).catchError((err) {
                print(err);
                Flushbar(
                  title: "Erro na gravacao do banco.",
                  message: err.toString(),
                  duration: Duration(seconds: 3),
                  isDismissible: false,
                )..show(context);
                setState(() {
                  isLoading = false;
                });
              });
            }, onError: (err) {
              Flushbar(
                message: "Erro no link de Download do Firebase Storage.",
                duration: Duration(seconds: 3),
                isDismissible: false,
              )..show(context);
              setState(() {
                isLoading = false;
              });
            });
          } else {
            Flushbar(
              title: "Erro ao gravar o imagem na nuvem",
              message: "O arquivo pode não ser uma Imagem.",
              duration: Duration(seconds: 3),
              isDismissible: false,
            )..show(context);
            setState(() {
              isLoading = false;
            });
          }
        });
      } catch (e) {
        Flushbar(
          title: "Falha de Conexão",
          message: "Sua foto pode não ter sido atualizada.",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.questionCircle),
            onPressed: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
        title: Text("SEU PERFIL"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('donors')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var finishedRequests;
            String phone,
                name,
                cor,
                dataNas,
                escolaridade,
                estadoCivil,
                pessoasCasa,
                sus,
                saude01,
                saude02,
                profissao,
                religiao,
                renda,
                sexo,
                unidadeBasica;
            num inputRating;
            //double rating;
            try {
              finishedRequests = snapshot.data.documents[0]['finishedRequests'];
              /*inputRating = snapshot.data.documents[0]['rating'];*/
              phone = snapshot.data.documents[0]['phone'];
              photoUrl = snapshot.data.documents[0]['photoUrl'];
              name = snapshot.data.documents[0]['name'];
              cor = snapshot.data.documents[0]['corDeclarada'];
              dataNas = snapshot.data.documents[0]['dataNascimento'];
              escolaridade = snapshot.data.documents[0]['escolaridade'];
              estadoCivil = snapshot.data.documents[0]['estadoCivil'];
              pessoasCasa = snapshot.data.documents[0]['numPessoasCasa'];
              sus = snapshot.data.documents[0]['numSus'];
              saude01 = snapshot.data.documents[0]['planoSaude01'];
              saude02 = snapshot.data.documents[0]['planoSaude02'];
              profissao = snapshot.data.documents[0]['profissao'];
              religiao = snapshot.data.documents[0]['religiao'];
              renda = snapshot.data.documents[0]['rendaFamiliar'];
              sexo = snapshot.data.documents[0]['sexo'];
              unidadeBasica = snapshot.data.documents[0]['unidadeBasSaude'];
              //rating = inputRating.toDouble();
            } catch (err) {
              phone = "Carregando...";
              name = "Carregando...";
              finishedRequests = 0;
              //inputRating = 0;
              //rating = 5.0;
              photoUrl = null;
            }
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 8.0),
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: photoUrl != null
                              ? !isLoading
                                  ? Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 5.0,
                                            valueColor: AlwaysStoppedAnimation<
                                                    Color>(
                                                Theme.of(context).primaryColor),
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
                                          Radius.circular(60.0)),
                                      clipBehavior: Clip.hardEdge,
                                    )
                                  : Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 5.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor),
                                      ),
                                      height: 120,
                                      width: 120,
                                    )
                              : !isLoading
                                  ? Icon(
                                      Icons.account_circle,
                                      size: 138.0,
                                      color: Colors.grey,
                                    )
                                  : Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 5.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      height: 120,
                                      width: 120,
                                    ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 48.0,
                            height: 48.0,
                            margin: EdgeInsets.only(right: 112.0),
                            child: FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15.0)),
                                  ),
                                  context: context,
                                  builder: (context) => Container(
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                            leading: Icon(
                                              Icons.photo,
                                            ),
                                            title: Text('Galeria'),
                                            onTap: () {
                                              imagePicker.openGallery();
                                              Navigator.of(context).pop();
                                            }),
                                        ListTile(
                                          leading: Icon(
                                            Icons.camera_alt,
                                          ),
                                          title: Text('Câmera'),
                                          onTap: () {
                                            imagePicker.openCamera();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(
                                            Icons.close,
                                          ),
                                          title: Text('Cancelar'),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    height: 124.0,
                    width: double.infinity,
                    margin: EdgeInsets.all(18.0),
                  ),
                  Text(
                    'Sua foto não será exibida',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
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
                    indent: 12.0,
                    endIndent: 12.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8.0),
                  dataUnit('NOME: ', name),
                  dataUnit('TELEFONE: ', phone),
                  dataUnit('DATA DE NASCIMENTO: ', dataNas),
                  dataUnit('SEXO: ', sexo),
                  dataUnit('NÚMERO DO SUS: ', sus),
                  dataUnit('UNIDADE BÁSICA DE SAÚDE: ', unidadeBasica),
                  dataUnit('PLANO DE SAÚDE 01: ', saude01),
                  dataUnit('PLANO DE SAÚDE 02: ', saude02),
                  dataUnit('PROFISSÃO: ', profissao),
                  dataUnit('NÚMERO DE PESSOAS EM CASA: ', pessoasCasa),
                  dataUnit('ESCOLARIDADE: ', escolaridade),
                  dataUnit('RELIGIÃO: ', religiao),
                  dataUnit('RENDA FAMILIAR: ', renda),
                  dataUnit('ESTADO CIVIL: ', estadoCivil),
                  dataUnit('COR: ', cor),
                  dataUnit(
                    'TOTAL DE ATENDIMENTOS: ',
                    finishedRequests != null
                        ? finishedRequests.toStringAsFixed(0)
                        : '0',
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: OutlineButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.info,
                            color: Colors.black.withAlpha(200),
                            size: 20,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'EDITAR INFORMAÇÕES',
                            style:
                                TextStyle(color: Colors.black.withAlpha(200)),
                          ),
                        ],
                      ),
                      borderSide: BorderSide(
                        color: Colors.black.withAlpha(200),
                      ),
                      highlightedBorderColor: Colors.black.withAlpha(200),
                      onPressed: editInfo,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(
                    height: 1.0,
                    indent: 12.0,
                    endIndent: 12.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Caso tenha alguma dúvida, entre em contato: covidcefet@gmail.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w300,
                          ),
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: OutlineButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.power_settings_new,
                            color: Colors.redAccent.withAlpha(200),
                            size: 20,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'SAIR DA CONTA',
                            style: TextStyle(
                                color: Colors.redAccent.withAlpha(200)),
                          ),
                        ],
                      ),
                      borderSide: BorderSide(
                        color: Colors.redAccent.withAlpha(200),
                      ),
                      highlightedBorderColor: Colors.redAccent.withAlpha(200),
                      onPressed: logOutDialog,
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
            );
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ),
            );
          }
        },
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

  logOutDialog() async {
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
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Icon(
                    Icons.power_settings_new,
                    color: Colors.black54,
                    size: 64.0,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: Text(
                    "TEM CERTEZA QUE DESEJA SAIR DA SUA CONTA?",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20.0),
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
                            StateWidget.of(context).logOutUser();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.orange[300],
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

  editInfo() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignForm()));
  }
}
