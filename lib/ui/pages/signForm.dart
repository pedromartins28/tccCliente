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
  bool form01 = false;

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
                          ? InputForm("Data de Nascimento", Icons.date_range)
                          : InputForm("Número SUS", Icons.healing),
                      form01
                          ? InputForm("Sexo", Icons.person)
                          : InputForm("Plano de Saúde 01", Icons.note_add),
                      form01
                          ? InputForm("Endereço", Icons.home)
                          : InputForm("Plano de Saúde 02", Icons.note_add),
                      form01
                          ? SizedBox(
                              height: 50,
                            )
                          : InputForm(
                              "Unidade Básica de Saúde", Icons.local_hospital),
                      form01
                          ? Botao("Próxima Etapa", changeForm01())
                          : SizedBox(
                              height: 50,
                            ),
                      !form01
                          ? Botao("Última Etapa", changeForm01())
                          : Container(),
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

  Widget InputForm(String text, IconData icon) {
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

  Widget Botao(String texto, Function function) {
    String _texto2 = texto;
    Function _funcao = function;

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
      onPressed: _funcao,
    );
  }

  changeForm01() {
    setState(() {
      form01 = !form01;
    });
  }
}
