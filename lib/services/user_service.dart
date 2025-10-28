import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _userMatriculaKey = 'user_matricula';
  static const String _userNombreKey = 'user_nombre';
  static const String _userApellidoKey = 'user_apellido';
  static const String _userClubKey = 'user_club';
  static const String _userMailKey = 'user_mail';
  static const String _userCelularKey = 'user_celular';

  // Guardar datos del usuario logueado
  static Future<void> saveUserData(Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_userMatriculaKey, usuario['nombreUsuario'] ?? '');
    await prefs.setString(_userNombreKey, usuario['nombre'] ?? '');
    await prefs.setString(_userApellidoKey, usuario['apellido'] ?? '');
    await prefs.setString(_userClubKey, usuario['club'] ?? '');
    await prefs.setString(_userMailKey, usuario['mail'] ?? '');
    await prefs.setString(_userCelularKey, usuario['celular'] ?? '');
  }

  // Obtener matrícula del usuario logueado
  static Future<String> getUserMatricula() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userMatriculaKey) ?? '';
  }

  // Obtener nombre completo del usuario logueado
  static Future<String> getUserFullName() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString(_userNombreKey) ?? '';
    final apellido = prefs.getString(_userApellidoKey) ?? '';
    return '$nombre $apellido'.trim();
  }

  // Obtener todos los datos del usuario
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'matricula': prefs.getString(_userMatriculaKey) ?? '',
      'nombre': prefs.getString(_userNombreKey) ?? '',
      'apellido': prefs.getString(_userApellidoKey) ?? '',
      'club': prefs.getString(_userClubKey) ?? '',
      'mail': prefs.getString(_userMailKey) ?? '',
      'celular': prefs.getString(_userCelularKey) ?? '',
    };
  }

  // Verificar si hay un usuario logueado
  static Future<bool> isUserLoggedIn() async {
    final matricula = await getUserMatricula();
    return matricula.isNotEmpty;
  }

  // Cerrar sesión (limpiar datos)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_userMatriculaKey);
    await prefs.remove(_userNombreKey);
    await prefs.remove(_userApellidoKey);
    await prefs.remove(_userClubKey);
    await prefs.remove(_userMailKey);
    await prefs.remove(_userCelularKey);
  }
}
