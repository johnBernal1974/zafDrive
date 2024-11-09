
import 'package:intl/intl.dart';

class PasswordFormValidator {
  static String message = 'La contraseña no es correcta';
  static String? validatePassword({ required String password }) {
    return password.isNotEmpty && password.length >= 6 ? null : message;
  }
}

class DefaultFormValidator {
  static String message = 'El campo está vacío';
  static String? validateIsNotEmpty({ required String value }) {
    return value.isNotEmpty ? null : message;
  }
}

class CelularFormValidator {
  static String message = 'El celular no es correcto';
  static String? validateCelular({ required String value }) {
    return value.isNotEmpty && value.length >= 10 ? null : message;
  }
}

bool isValidEmail(String email) {
  // Expresión regular para validar el formato de un correo electrónico
  final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  // Utilizar el método test de la expresión regular para verificar el formato
  return emailRegex.hasMatch(email.trim());
}

//Colocar divisor de miles
class FormatUtils {
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);
    String formatted = formatter.format(amount);
    return formatted.replaceAll(',', '.');
  }
}


