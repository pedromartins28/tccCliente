import 'package:cliente/models/state.dart';
import 'package:cliente/models/user.dart';
import 'package:cliente/ui/pages/tabs/home.dart';
import 'package:cliente/ui/widgets/forms.dart';
import 'package:cliente/ui/widgets/loading.dart';
import 'package:cliente/util/auth.dart';
import 'package:cliente/util/state_widget.dart';
import 'package:cliente/util/validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  int form01 = 0;
  StateModel appState;
  String userId = '';
  User user;

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.red[600],
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.15),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: LoadingPage(
          child: Form(
            autovalidate: true,
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 75.0,
                        child: Image.asset(
                          'assets/logo.png',
                          height: 550,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      form01 == 0
                          ? Column(
                              children: <Widget>[
                                inputForm(
                                    "Data de Nascimento", Icons.date_range),
                                inputForm("Sexo", Icons.person),
                                inputForm("Endereço", Icons.home),
                                SizedBox(
                                  height: 50,
                                ),
                                botao("Próxima Etapa", changeForm01)
                              ],
                            )
                          : form01 == 1
                              ? Column(
                                  children: <Widget>[
                                    inputForm("Número SUS", Icons.healing),
                                    inputForm(
                                        "Plano de Saúde 01", Icons.note_add),
                                    inputForm(
                                        "Plano de Saúde 02", Icons.note_add),
                                    inputForm("Unidade Básica de Saúde",
                                        Icons.local_hospital),
                                    SizedBox(
                                      height: 50,
                                    ),
                                    botao("Última Etapa", changeForm02)
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    inputForm("Número de pessoas no domicílio",
                                        Icons.person),
                                    inputForm(
                                        "Estado Civil", Icons.thumbs_up_down),
                                    inputForm(
                                        "Cor declarada", Icons.color_lens),
                                    inputForm("Escolaridade", Icons.school),
                                    inputForm("Religião", Icons.cloud),
                                    inputForm(
                                        "Profissão", Icons.monetization_on),
                                    inputForm(
                                        "Renda Familiar", Icons.attach_money),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    botao("Finalizar Cadastro", finishSignIn),
                                  ],
                                )
                    ],
                  ),
                ),
              ),
            ),
          ),
          inAsyncCall: false,
        ),
      ),
    );
  }

  Widget inputForm(String text, IconData icon) {
    final TextEditingController _nameController = TextEditingController();
    final FocusNode _nameFocus = FocusNode();
    String _texto = text;
    IconData _icone = icon;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
      child: CustomField(
        enable: true,
        prefixIcon: _icone,
        iconColor: Colors.white,
        labelText: _texto,
        onFieldSubmitted: (term) {
          FocusScope.of(context).requestFocus(_nameFocus);
        },
        validator: Validator.validateForm,
        textCap: TextCapitalization.words,
        inputType: TextInputType.text,
        action: TextInputAction.next,
        controller: _nameController,
        textColor: Colors.white,
        labelColor: Colors.white,
      ),
    );
  }

  Widget botao(String texto, Function funcaoSend) {
    String _texto2 = texto;

    return RaisedButton(
      child: Text(
        _texto2,
        style: TextStyle(fontSize: 18.0, color: Colors.black),
      ),
      padding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: Colors.white,
      onPressed: funcaoSend,
    );
  }

  changeForm01() {
    setState(() {
      form01 = 1;
    });
  }

  changeForm02() {
    setState(() {
      form01 = 2;
    });
  }

  void finishSignIn() async {
    user = await Auth.getUserLocal();
    userId = user.userId;

    Firestore.instance.collection('donors').document(userId).updateData(
      {
        'opaBao': "bao",
        'beleza': "sim",
      },
    );

    setState(() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
      appState.goAhead = false;
      appState.goAheadAux = false;
      form01 = 0;
    });
  }
}
