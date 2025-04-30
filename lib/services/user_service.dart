import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const _userKey = 'registered_users';
  // Estructura: { 'usuario1': 'contrasena1', ... }

  static Future<Map<String, String>> _getStoredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return {};
    return Map<String, String>.from(json.decode(data));
  }

  static Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(users));
  }

  static Future<bool> registerUser(String username, String password) async {
    final users = await _getStoredUsers();
    if (users.containsKey(username)) return false; // Usuario ya existe
    users[username] = password;
    await _saveUsers(users);
    return true;
  }

  static Future<bool> loginUser(String username, String password) async {
    final users = await _getStoredUsers();
    return users[username] == password;
  }

  static Future<bool> userExists(String username) async {
    final users = await _getStoredUsers();
    return users.containsKey(username);
  }

  static Future<void> resetPassword(String username, String newPassword) async {
    final users = await _getStoredUsers();
    if (users.containsKey(username)) {
      users[username] = newPassword;
      await _saveUsers(users);
    }
  }

  static Future<List<String>> getRegisteredUsers() async {
    final users = await _getStoredUsers();
    return users.keys.toList();
  }

  // Nuevo método para borrar todos los usuarios
  static Future<void> deleteAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Método para borrar un usuario específico
  static Future<bool> deleteUser(String username) async {
    final users = await _getStoredUsers();
    if (!users.containsKey(username)) return false;

    users.remove(username);
    await _saveUsers(users);
    return true;
  }
}
