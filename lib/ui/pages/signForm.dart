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
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _susController = TextEditingController();
  final TextEditingController _planSaude01Controller = TextEditingController();
  final TextEditingController _planSaude02Controller = TextEditingController();
  final TextEditingController _unidadeBasicaSaudeController =
      TextEditingController();
  final TextEditingController _pessoasCasaController = TextEditingController();
  final TextEditingController _estadoCivilController = TextEditingController();
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _escolaridadeController = TextEditingController();
  final TextEditingController _religiaoController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();
  final TextEditingController _rendaController = TextEditingController();
  String _selectedDropSexo;
  String _selectedDropEstadoCivil;
  String _selectedDropCor;

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
                                  _dataController,
                                  "Data de Nascimento",
                                  Icons.date_range,
                                ),
                                dropDownButtonSexo("Sexo"),
                                dropDownButtonEstadoCivil("Estado Civil"),
                                dropDownButtonCor("Cor Declarada"),
                                botao("Próxima Etapa", changeForm01)
                              ],
                            )
                          : form01 == 1
                              ? Column(
                                  children: <Widget>[
                                    inputForm(
                                      _susController,
                                      "Número SUS",
                                      Icons.healing,
                                    ),
                                    inputForm(
                                      _planSaude01Controller,
                                      "Plano de Saúde 01",
                                      Icons.note_add,
                                    ),
                                    inputForm(
                                      _planSaude02Controller,
                                      "Plano de Saúde 02",
                                      Icons.note_add,
                                    ),
                                    inputForm(
                                      _unidadeBasicaSaudeController,
                                      "Unidade Básica de Saúde",
                                      Icons.local_hospital,
                                    ),
                                    botao("Última Etapa", changeForm02)
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    inputForm(
                                      _pessoasCasaController,
                                      "Número de pessoas no domicílio",
                                      Icons.person,
                                    ),
                                    inputForm(
                                      _escolaridadeController,
                                      "Escolaridade",
                                      Icons.school,
                                    ),
                                    inputForm(
                                      _religiaoController,
                                      "Religião",
                                      Icons.cloud,
                                    ),
                                    inputForm(
                                      _profissaoController,
                                      "Profissão",
                                      Icons.monetization_on,
                                    ),
                                    inputForm(
                                      _rendaController,
                                      "Renda Familiar",
                                      Icons.attach_money,
                                    ),
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

  Widget inputForm(
      TextEditingController _controller, String text, IconData icon) {
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
        controller: _controller,
        textColor: Colors.white,
        labelColor: Colors.white,
      ),
    );
  }

  Widget botao(String texto, Function funcaoSend) {
    String _texto2 = texto;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 5),
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        child: RaisedButton(
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
        ),
      ),
    );
  }

  Widget dropDownButtonSexo(String cabecalho) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60, width: 2.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    cabecalho + ":",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  iconEnabledColor: Colors.red[500],
                  value: _selectedDropSexo,
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(0.8),
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red[500].withOpacity(0)),
                    ),
                  ),
                  items: ["Masculino", "Feminino", "Outro"]
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDropSexo = value);
                  },
                ),
              ],
            ),
          )),
    );
  }

  Widget dropDownButtonEstadoCivil(String cabecalho) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60, width: 2.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    cabecalho + ":",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  iconEnabledColor: Colors.red[500],
                  value: _selectedDropEstadoCivil,
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(0.8),
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red[500].withOpacity(0)),
                    ),
                  ),
                  items: [
                    "Solteiro(a)",
                    "Casado(a)",
                    "Divorciado(a)",
                    "Viúvo(a)",
                    "Separado(a)"
                  ]
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDropEstadoCivil = value);
                  },
                ),
              ],
            ),
          )),
    );
  }

  Widget dropDownButtonCor(String cabecalho) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white60, width: 2.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    cabecalho + ":",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  iconEnabledColor: Colors.red[500],
                  value: _selectedDropCor,
                  decoration: InputDecoration(
                    fillColor: Colors.white.withOpacity(0.8),
                    filled: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.red[500].withOpacity(0)),
                    ),
                  ),
                  items: ["Preto", "Pardo", "Branco", "Indígena", "Amarelo"]
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDropCor = value);
                  },
                ),
              ],
            ),
          )),
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
        'dataNascimento': _dataController.text,
        'sexo': _selectedDropSexo,
        'endereco': _enderecoController.text,
        'numSus': _susController.text,
        'planoSaude01': _planSaude01Controller.text,
        'planoSaude02': _planSaude02Controller.text,
        'unidadeBasSaude': _unidadeBasicaSaudeController.text,
        'numPessoasCasa': _pessoasCasaController.text,
        'estadoCivil': _selectedDropEstadoCivil,
        'corDeclarada': _corController.text,
        'escolaridade': _escolaridadeController.text,
        'religiao': _religiaoController.text,
        'profissao': _profissaoController.text,
        'rendaFamiliar': _rendaController.text,
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
