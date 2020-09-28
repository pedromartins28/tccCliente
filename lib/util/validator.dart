class Validator {
  static String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Digite um email válido!';
    else
      return null;
  }

  static String validatePass(String value) {
    Pattern pattern = r'^.{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'A senha deve ter pelo menos 8 caracteres!';
    else
      return null;
  }

  static String validateName(String value) {
    Pattern pattern = r"^([a-zA-ZéúíóáÉÚÍÓÁçÇõãÕÃêûîôâÊÛÎÔÂ\-\ \s]{2,}\s"
        r"[a-zA-ZéúíóáÉÚÍÓÁçÇõãÕÃêûîôâÊÛÎÔÂ\-\ \s]{1,}'?-?"
        r"[a-zA-ZéúíóáÉÚÍÓÁçÇõãÕÃêûîôâÊÛÎÔÂ\-\ \s]{2,}\s?"
        r"([a-zA-ZéúíóáÉÚÍÓÁçÇõãÕÃêûîôâÊÛÎÔÂ\-\ \s]{1,})?)";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Digite seu nome completo!';
    else
      return null;
  }

  static String validateForm(String value) {
    return null;
  }
}
