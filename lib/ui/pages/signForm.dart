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
  final TextEditingController _susController = TextEditingController();
  final TextEditingController _planSaude01Controller = TextEditingController();
  final TextEditingController _planSaude02Controller = TextEditingController();
  final TextEditingController _unidadeBasicaSaudeController =
      TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();
  final formKeySexo = GlobalKey<FormState>();
  final formKeyEstadoCivil = GlobalKey<FormState>();
  final formKeyCor = GlobalKey<FormState>();
  final formKeyPessoas = GlobalKey<FormState>();
  final formKeyEscolaridade = GlobalKey<FormState>();
  final formKeyRenda = GlobalKey<FormState>();
  final formKeyReligiao = GlobalKey<FormState>();
  final GlobalKey<MaskedTextFieldState> _maskedDataKey =
      GlobalKey<MaskedTextFieldState>();
  String _dataerrorMessage;
  bool _loadingVisible = false;

  List<String> _itensSexo = ["Masculino", "Feminino", "Outro"];
  String _mostrarSexo;
  String _selectedDropSexo;
  List<String> _itensEstadoCivil = [
    "Solteiro(a)",
    "Casado(a)",
    "Divorciado(a)",
    "Viúvo(a)",
    "Separado(a)"
  ];
  String _mostrarEstado;
  String _selectedDropEstadoCivil;
  List<String> _itensCor = [
    "Preto(a)",
    "Pardo(a)",
    "Branco(a)",
    "Indígena",
    "Amarelo(a)"
  ];
  String _mostrarCor;
  String _selectedCor;
  List<String> _itensPessoas = ["1", "2", "3", "4", "5", "6+"];
  String _mostrarPessoas;
  String _selectedPessoas;
  List<String> _itensEscolaridade = [
    "Analfabeto",
    "Fundamental Incompleto",
    "Fundamental Completo",
    "Médio Incompleto",
    "Médio Completo",
    "Superior Incompleto",
    "Superior Completo"
  ];
  String _mostrarEscolaridade;
  String _selectedEscolaridade;
  List<String> _itensReligiao = [
    "Católica",
    "Evangélica",
    "Não tem",
    "Espírita",
    "Religiões afro-brasileiras",
    "Outra",
  ];
  String _mostrarReligiao;
  String _selectedReligiao;
  List<String> _itensRenda = [
    "Até 2 salários mínimos",
    "De 2 a 3 salários mínimos",
    "De 3 a 5 salários mínimos",
    "de 5 a 10 salários mínimos",
    "Mais de 10 salários mínimos",
  ];
  String _mostrarRenda;
  String _selectedRenda;

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
                                _buildField(
                                    _dataController,
                                    "xx/xx/xxxx",
                                    Icons.date_range,
                                    TextInputType.datetime,
                                    "DD/MM/AAAA",
                                    "Data de Nascimento",
                                    _dataerrorMessage),
                                dropDownButton("Sexo", _itensSexo, _mostrarSexo,
                                    Icons.access_alarm),
                                dropDownButton(
                                    "Estado Civil",
                                    _itensEstadoCivil,
                                    _mostrarEstado,
                                    Icons.verified_user),
                                dropDownButton("Cor", _itensCor, _mostrarCor,
                                    Icons.healing),
                                botao("Próxima Etapa", changeForm01)
                              ],
                            )
                          : form01 == 1
                              ? Column(
                                  children: <Widget>[
                                    inputForm(_susController, "Número SUS",
                                        Icons.healing, TextInputType.text),
                                    inputForm(
                                        _planSaude01Controller,
                                        "Plano de Saúde 01",
                                        Icons.note_add,
                                        TextInputType.text),
                                    inputForm(
                                        _planSaude02Controller,
                                        "Plano de Saúde 02",
                                        Icons.note_add,
                                        TextInputType.text),
                                    inputForm(
                                        _unidadeBasicaSaudeController,
                                        "Unidade Básica de Saúde",
                                        Icons.local_hospital,
                                        TextInputType.text),
                                    botao("Última Etapa", changeForm02)
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    inputForm(
                                        _profissaoController,
                                        "Profissão",
                                        Icons.monetization_on,
                                        TextInputType.text),
                                    dropDownButton(
                                        "Número de pessoas no domicílio",
                                        _itensPessoas,
                                        _mostrarPessoas,
                                        Icons.youtube_searched_for),
                                    dropDownButton(
                                        "Escolaridade",
                                        _itensEscolaridade,
                                        _mostrarEscolaridade,
                                        Icons.keyboard_arrow_up),
                                    dropDownButton(
                                        "Religião",
                                        _itensReligiao,
                                        _mostrarReligiao,
                                        Icons.format_align_justify),
                                    dropDownButton(
                                        "Renda Familiar",
                                        _itensRenda,
                                        _mostrarRenda,
                                        Icons.format_align_justify),
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
          inAsyncCall: _loadingVisible,
        ),
      ),
    );
  }

  String _dataInputValidator() {
    if (_dataController.text.isEmpty) {
      return "Digite a sua data de nascimento!";
    } else if (_dataController.text.length < 10) {
      return "Essa data é inválida!";
    } else {
      int dia = int.parse(_dataController.text[0] + _dataController.text[1]);
      int mes = int.parse(_dataController.text[3] + _dataController.text[4]);
      int ano = int.parse(_dataController.text[6] +
          _dataController.text[7] +
          _dataController.text[8] +
          _dataController.text[9]);

      if (dia <= 0 || dia > 31) {
        return "Essa data é inválida!";
      } else if (mes <= 0 || mes > 12) {
        return "Essa data é inválida!";
      } else if (ano <= 1900) {
        return "Essa data é inválida!";
      }
    }

    return null;
  }

  Widget _buildField(
      TextEditingController _controller,
      String mask,
      IconData icon,
      TextInputType teclado,
      String hintText,
      String labelText,
      String error) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: MaskedTextField(
        key: _maskedDataKey,
        mask: mask,
        keyboardType: teclado,
        maskedTextFieldController: _controller,
        maxLength: 10,
        onSubmitted: (text) {},
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(fontSize: 18.0, color: Colors.white),
        inputDecoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.white, fontSize: 16.0),
          prefixIcon: Icon(icon, color: Colors.white),
          hintStyle: TextStyle(color: Colors.white24),
          hintText: hintText,
          labelText: labelText,
          counterText: "",
          isDense: false,
          enabled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(color: Colors.white60, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
          ),
          errorText: error,
          errorStyle:
              TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget inputForm(TextEditingController _controller, String text,
      IconData icon, TextInputType teclado) {
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
        inputType: teclado,
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

  Widget dropDownButton(
      String cabecalho, List<String> itens, String selected, IconData icone) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Form(
        key: cabecalho == "Sexo"
            ? formKeySexo
            : cabecalho == "Estado Civil"
                ? formKeyEstadoCivil
                : cabecalho == "Cor"
                    ? formKeyCor
                    : cabecalho == "Número de pessoas no domicílio"
                        ? formKeyPessoas
                        : cabecalho == "Escolaridade"
                            ? formKeyEscolaridade
                            : cabecalho == "Religião"
                                ? formKeyReligiao
                                : cabecalho == "Renda Familiar"
                                    ? formKeyRenda
                                    : null,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.blue[300],
          ),
          child: DropdownButtonFormField<String>(
            value: selected,
            iconEnabledColor: Colors.white,
            hint: Row(
              children: <Widget>[
                Icon(
                  icone,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  cabecalho,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            validator: (selected) =>
                selected == null ? 'Esse campo não pode ficar vazio' : null,
            decoration: InputDecoration(
              fillColor: Colors.white.withOpacity(0),
              filled: true,
              labelStyle: TextStyle(color: Colors.white, fontSize: 16.0),
              hintStyle: TextStyle(color: Colors.white24),
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.white60, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
              ),
              errorStyle: TextStyle(
                  color: Colors.yellow[700], fontWeight: FontWeight.w500),
            ),
            items: itens.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: <Widget>[
                    Icon(
                      icone,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      value,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(
                () {
                  selected = value;
                  if (itens.contains("Masculino")) {
                    _selectedDropSexo = value;
                  } else if (itens.contains("Solteiro(a)")) {
                    _selectedDropEstadoCivil = value;
                  } else if (itens.contains("Preto(a)")) {
                    _selectedCor = value;
                  } else if (itens.contains("1")) {
                    _selectedPessoas = value;
                  } else if (itens.contains("Analfabeto")) {
                    _selectedEscolaridade = value;
                  } else if (itens.contains("Não tem")) {
                    _selectedReligiao = value;
                  } else if (itens.contains("Até 2 salários mínimos")) {
                    _selectedRenda = value;
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  changeForm01() {
    String error = _dataInputValidator();
    if (error != null) {
      setState(() {
        _dataerrorMessage = error;
      });
    } else if (formKeySexo.currentState.validate() &&
        formKeyEstadoCivil.currentState.validate() &&
        formKeyCor.currentState.validate()) {
      setState(() {
        form01 = 1;
      });
    } else {
      setState(() {
        _dataerrorMessage = error;
      });
    }
  }

  changeForm02() {
    setState(() {
      form01 = 2;
    });
  }

  void finishSignIn() async {
    user = await Auth.getUserLocal();
    userId = user.userId;

    if (formKeyPessoas.currentState.validate() &&
        formKeyEscolaridade.currentState.validate() &&
        formKeyReligiao.currentState.validate() &&
        formKeyRenda.currentState.validate()) {
      _changeLoadingVisible();
      Firestore.instance.collection('donors').document(userId).updateData(
        {
          'dataNascimento': _dataController.text,
          'sexo': _selectedDropSexo,
          'estadoCivil': _selectedDropEstadoCivil,
          'corDeclarada': _selectedCor,
          'numSus': _susController.text,
          'planoSaude01': _planSaude01Controller.text,
          'planoSaude02': _planSaude02Controller.text,
          'unidadeBasSaude': _unidadeBasicaSaudeController.text,
          'numPessoasCasa': _selectedPessoas,
          'escolaridade': _selectedEscolaridade,
          'religiao': _selectedReligiao,
          'profissao': _profissaoController.text,
          'rendaFamiliar': _selectedRenda,
        },
      );

      setState(() {
        _changeLoadingVisible();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        appState.goAhead = false;
        appState.goAheadAux = false;
      });
    } else {}
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }
}
