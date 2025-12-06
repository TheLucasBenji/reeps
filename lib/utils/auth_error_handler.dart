import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'El correo electrónico ya está registrado.';
        case 'invalid-email':
          return 'El correo electrónico no es válido.';
        case 'operation-not-allowed':
          return 'Operación no permitida. Contacte al soporte.';
        case 'weak-password':
          return 'La contraseña es muy débil.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        case 'user-not-found':
          return 'No se encontró una cuenta con este correo.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'invalid-credential':
          return 'Credenciales inválidas.';
        case 'account-exists-with-different-credential':
          return 'Ya existe una cuenta con este correo pero con otro método de inicio de sesión.';
        case 'network-request-failed':
          return 'Error de red. Verifique su conexión a internet.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intente más tarde.';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Ocurrió un error inesperado: ${error.toString()}';
  }
}
