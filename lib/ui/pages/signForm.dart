import 'package:cliente/ui/widgets/forms.dart';
import 'package:cliente/ui/widgets/loading.dart';
import 'package:cliente/util/validator.dart';
import 'package:flutter/material.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  bool form01 = true;

  @override
  Widget build(BuildContext context) {
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
                      form01
                          ? InputForm(
                              icone: Icons.ac_unit, texto: "Data de Nascimento")
                          : InputForm(
                              icone: Icons.ac_unit, texto: "Número SUS"),
                      form01
                          ? InputForm(icone: Icons.ac_unit, texto: "Sexo")
                          : InputForm(
                              icone: Icons.ac_unit, texto: "Plano de Saúde 1"),
                      form01
                          ? InputForm(icone: Icons.ac_unit, texto: "Endereço")
                          : InputForm(
                              icone: Icons.ac_unit, texto: "Plano de Saúde 2"),
                      form01
                          ? SizedBox(
                              height: 50,
                            )
                          : InputForm(
                              icone: Icons.ac_unit,
                              texto: "Unidade Básica de Saúde"),
                      form01
                          ? Botao(texto2: "Próxima Etapa")
                          : SizedBox(
                              height: 50,
                            ),
                      !form01 ? Botao(texto2: "Próximo") : Container(),
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
}

class InputForm extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  String texto;
  IconData icone;

  InputForm({this.texto, this.icone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
      child: CustomField(
        enable: true,
        prefixIcon: icone,
        iconColor: Colors.white,
        labelText: texto,
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
}

class Botao extends StatelessWidget {
  String texto2;

  Botao({this.texto2});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child:
          Text(texto2, style: TextStyle(fontSize: 18.0, color: Colors.black)),
      padding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: Colors.white,
      onPressed: () {},
    );
  }
}
