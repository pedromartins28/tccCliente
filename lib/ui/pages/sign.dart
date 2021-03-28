import 'package:cliente/models/state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cliente/ui/widgets/loading.dart';
import 'package:cliente/util/state_widget.dart';
import 'package:cliente/ui/widgets/forms.dart';
import 'package:cliente/util/validator.dart';
import 'package:cliente/models/user.dart';
import 'package:cliente/util/logger.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cliente/util/auth.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<MaskedTextFieldState> _maskedPhoneKey =
      GlobalKey<MaskedTextFieldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  static const String tag = "AUTH";
  StateModel appState;

  String _errorMessage, _phoneNumber, _verificationId;
  Duration _timeOut = const Duration(minutes: 1);
  bool _loadingVisible = false,
      _codeVerified = false,
      _codeTimedOut = false,
      _autoValidate = false,
      _isAlreadySignedIn,
      _isSignIn = true,
      _isSMS = false;
  FirebaseUser _authUser;
  Timer _codeTimer;
  bool policiesChecked = false;

  @override
  void initState() {
    super.initState();
  }

  void showFlushBar(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      isDismissible: false,
    )..show(context);
  }

  _launchURL() async {
    const url = 'https://saudeemcasadiv.web.app/download/policy1.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _policiesValidator() {
    if (policiesChecked)
      return true;
    else {
      showFlushBar(
          "É preciso aceitar a Política de Privacidade para realizar o cadastro.");
      return false;
    }
  }

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
            autovalidate: _autoValidate,
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
                          'assets/logo2.png',
                          height: 550,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: _isSMS || _isSignIn ? 48.0 : 38.0),
                      _isSMS ? Container() : _buildPhoneField(),
                      _isSignIn ? SizedBox(height: 16) : SizedBox(height: 18),
                      _isSMS
                          ? Container()
                          : _isSignIn ? Container() : _buildNameField(),
                      _isSMS
                          ? Container()
                          : _isSignIn ? Container() : _buildPoliciesCheckbox(),
                      _isSMS ? _buildSmsField() : Container(),
                      _isSMS ? _buildResendSmsWidget() : Container(),
                      SizedBox(
                        height: _isSMS || _isSignIn
                            ? MediaQuery.of(context).size.height * 0.07
                            : MediaQuery.of(context).size.height * 0.03,
                      ),
                      _isSMS
                          ? Container()
                          : _isSignIn
                              ? _buildLogInButton()
                              : _buildSignUpButton(),
                      SizedBox(height: 16.0),
                      _isSMS ? _buildSmsInputButton() : Container(),
                      _isSMS
                          ? Container()
                          : _isSignIn
                              ? _buildChangeGoToSignUpButton()
                              : _buildBackToLoginButton(),
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

  // Widgets
  Widget _buildChangeGoToSignUpButton() {
    return FlatButton(
      child: Text(
        'CRIAR UMA CONTA',
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      onPressed: () {
        setState(() {
          _isSignIn = false;
        });
      },
    );
  }

  Widget _buildSmsInputButton() {
    return FlatButton(
      child: Text(
        'CONFIRMAR CÓDIGO',
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      onPressed: () {
        _submitSmsCode();
      },
    );
  }

  Widget _buildLogInButton() {
    return RaisedButton(
      child: Text(
        'ENTRAR',
        style: TextStyle(fontSize: 18.0, color: Colors.black),
      ),
      padding: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: Colors.white,
      onPressed: () {
        _signInProcedure();
        appState.goAheadAux = false;
      },
    );
  }

  Widget _buildSignUpButton() {
    return RaisedButton(
      child: Text('CADASTRAR',
          style: TextStyle(fontSize: 18.0, color: Colors.black)),
      padding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: Colors.white,
      onPressed: () {
        _signUpProcedure();
        appState.goAheadAux = true;
      },
    );
  }

  Widget _buildBackToLoginButton() {
    return FlatButton(
      child: Text(
        'ENTRAR EM CONTA EXISTENTE',
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      onPressed: () {
        setState(() {
          _isSignIn = true;
        });
      },
    );
  }

  Widget _buildNameField() {
    return CustomField(
      enable: true,
      prefixIcon: Icons.person,
      iconColor: Colors.white,
      labelText: 'Nome Completo',
      onFieldSubmitted: (term) {
        FocusScope.of(context).requestFocus(_nameFocus);
      },
      validator: Validator.validateName,
      textCap: TextCapitalization.words,
      inputType: TextInputType.text,
      action: TextInputAction.next,
      controller: _nameController,
      textColor: Colors.white,
      labelColor: Colors.white,
    );
  }

  Widget _buildPhoneField() {
    return MaskedTextField(
      key: _maskedPhoneKey,
      mask: "(xx) xxxxx-xxxx",
      keyboardType: TextInputType.number,
      maskedTextFieldController: _phoneController,
      maxLength: 15,
      onSubmitted: (text) {
        FocusScope.of(context).requestFocus(_phoneFocus);
        print("text");
      },
      style: Theme.of(context)
          .textTheme
          .subtitle1
          .copyWith(fontSize: 18.0, color: Colors.white),
      inputDecoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.white, fontSize: 16.0),
        prefixIcon: Icon(Icons.phone, color: Colors.white),
        hintStyle: TextStyle(color: Colors.white24),
        hintText: "(99) 99999-9999",
        labelText: "Telefone",
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
        errorText: _errorMessage,
        errorStyle:
            TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSmsField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 64.0),
      child: TextField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        controller: _smsController,
        maxLength: 6,
        style: TextStyle(color: Colors.white, fontSize: 32),
        decoration: InputDecoration(
          counterText: "",
          hintText: "--- ---",
          hintStyle: TextStyle(color: Colors.white24, fontSize: 32),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white60, width: 2.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSmsWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: InkWell(
        onTap: () async {
          if (_codeTimedOut) {
            _changeLoadingVisible();
            await _verifyPhoneNumber();
          } else {
            showFlushBar("Você não pode tentar ainda!");
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Se a sua mensagem não chegar em 1 minuto, clique",
              style: TextStyle(color: Colors.grey[50], fontSize: 16.0),
              children: <TextSpan>[
                TextSpan(
                  text: " aqui",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoliciesCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: policiesChecked,
            onChanged: (value) {
              setState(() {
                policiesChecked = value;
              });
            },
            checkColor: Theme.of(context).primaryColor,
            activeColor: Colors.white,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Eu li e Concordo com a ",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: "Política de Privacidade.",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _launchURL();
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  //validators
  String _smsInputValidator() {
    if (_smsController.text.isEmpty) {
      return "Seu código de verificação não pode estar vazio";
    } else if (_smsController.text.length < 6) {
      return "Esse código de verificação é inválido!";
    }
    return null;
  }

  String _phoneInputValidator() {
    if (_phoneController.text.isEmpty) {
      return "Digite seu número!";
    } else if (_phoneController.text.length < 15) {
      return "Esse número é inválido!";
    }
    return null;
  }

  //unmaskPhoneNumber
  String get phoneNumber {
    try {
      String unmaskedText = _maskedPhoneKey.currentState?.unmaskedText;
      if (unmaskedText != null) _phoneNumber = "+55$unmaskedText".trim();
    } catch (error) {
      Logger.log(tag,
          message: "Couldn't access state from _maskedPhoneKey: $error");
    }
    return _phoneNumber;
  }

  // call the main verification of the number and the SMS
  // Your parameters are Funcions that are Bellow this Funcion
  Future<Null> _verifyPhoneNumber() async {
    print("Got phone number as: ${this.phoneNumber}");
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: _timeOut,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationCompleted: _linkWithPhoneNumber,
        verificationFailed: verificationFailed);
    Logger.log(tag, message: "Returning null from _verifyPhoneNumber");
    return null;
  }

  codeSent(String verificationId, [int forceResendingToken]) async {
    Logger.log(tag,
        message: "Verification code sent to number ${_phoneController.text}");
    _codeTimer = Timer(_timeOut, () {
      setState(() {
        _codeTimedOut = true;
      });
    });
    setState(() {
      this._verificationId = verificationId;
      _isSMS = true;
    });
    _changeLoadingVisible();
  }

  codeAutoRetrievalTimeout(String verificationId) {
    Logger.log(tag, message: "onCodeTimeout");
    setState(() {
      this._verificationId = verificationId;
      this._codeTimedOut = true;
    });
  }

  Future<bool> _onCodeVerified(FirebaseUser user) async {
    final isUserValid = (user != null &&
        (user.phoneNumber != null && user.phoneNumber.isNotEmpty));
    if (isUserValid) {
      if (!_isAlreadySignedIn) {
        Auth.addUserToDB(
            User(
              userId: user.uid,
              phone: _phoneController.text,
              name: _nameController.text,
              finishedRequests: 0,
              dataNascimento: null,
            ),
            phoneNumber);
      }
    } else {
      showFlushBar("Não foi possível verificar seu Código, tente novamente!");
      return null;
    }
    return isUserValid;
  }

  _finishSignIn(FirebaseUser user) async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    print("User Loged In");
    if (appState.goAheadAux == true) {
      appState.goAhead = true;
    }
    await StateWidget.of(context).signInUser(user.uid);
    try {
      _codeTimer.cancel();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _linkWithPhoneNumber(AuthCredential credential) async {
    final errorMessage =
        "Não foi possível criar seu usuário agora, tente novamente mais tarde.";

    final result = await Auth.phoneSignIn(credential);
    _authUser = result.user;

    await _onCodeVerified(_authUser).then((codeVerified) async {
      this._codeVerified = codeVerified;
      Logger.log(
        tag,
        message: "Returning ${this._codeVerified} from _onCodeVerified",
      );
      if (this._codeVerified) {
        setState(() {
          _autoValidate = true;
        });
        await _finishSignIn(_authUser);
      } else {
        showFlushBar(errorMessage);
      }
    });
  }

  verificationFailed(AuthException authException) {
    _changeLoadingVisible();
    showFlushBar("Não foi possível verificar seu código, tente novamente!");
    Logger.log(tag,
        message:
            'onVerificationFailed, code: ${authException.code}, message: ${authException.message}');
  }

  // Submit the SMS code
  Future<Null> _submitSmsCode() async {
    final error = _smsInputValidator();
    if (error != null) {
      showFlushBar(error);
      return null;
    } else {
      _changeLoadingVisible();
      if (this._codeVerified) {
        await _finishSignIn(await _auth.currentUser());
      } else {
        Logger.log(tag, message: "_linkWithPhoneNumber called");
        _changeLoadingVisible();
        await _linkWithPhoneNumber(
          PhoneAuthProvider.getCredential(
            smsCode: _smsController.text,
            verificationId: _verificationId,
          ),
        );
      }
      return null;
    }
  }

  //Main Procedures Callers

  Future<Null> _signUpProcedure() async {
    if (_formKey.currentState.validate() && _policiesValidator()) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      String error = _phoneInputValidator();
      if (error != null) {
        setState(() {
          _errorMessage = error;
        });
        return null;
      } else {
        _changeLoadingVisible();
        _isAlreadySignedIn = await Auth.alreadyPhoneSignedIn(phoneNumber);
        if (_isAlreadySignedIn != null) {
          if (_isAlreadySignedIn) {
            error = "Esse Número já foi cadastrado. Tente outro número";
            showFlushBar(error);
            await _changeLoadingVisible();
            return null;
          } else {
            setState(() {
              _errorMessage = null;
            });
            final result = await _verifyPhoneNumber();

            Logger.log(tag,
                message: "Returning $result from _submitPhoneNumber");
            return result;
          }
        } else {
          await _changeLoadingVisible();
          showFlushBar("Falha ao verificar se o usuario existe");
          return null;
        }
      }
    }
  }

  void _signInProcedure({BuildContext context}) async {
    print(phoneNumber);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String error = _phoneInputValidator();
    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
      return null;
    } else {
      await _changeLoadingVisible();
      _isAlreadySignedIn = await Auth.alreadyPhoneSignedIn(phoneNumber);
      if (_isAlreadySignedIn != null) {
        if (_isAlreadySignedIn) {
          setState(() {
            _errorMessage = null;
          });
          final result = await _verifyPhoneNumber();
          Logger.log(tag, message: "Returning $result from _submitPhoneNumber");
          return result;
        } else {
          await _changeLoadingVisible();
          error = "Esse Número ainda não foi cadastrado.";
          showFlushBar(error);
          return null;
        }
      } else {
        await _changeLoadingVisible();
        showFlushBar("Falha ao verificar se o usuario existe");
        return null;
      }
    }
  }
}
