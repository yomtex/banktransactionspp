import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String baseUrl = "http://10.0.2.2:8000/api/auth/";

  Future<String> register(String fname, String lname, String email,
      String username, String password, String country, String isoCode) async {
    final Map<String, String> data = {
      'lastname': lname,
      'firstname': fname,
      'email': email,
      'password': password,
      'username': username,
      'country': country,
      'country_code': isoCode,
    };
    // return iso_code;
    final response = await http.post(
      Uri.parse('${baseUrl}register'),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    var msg = json.decode(response.body)["message"];

    if (response.statusCode == 201) {
      // Registration successful
      return "1";
    } else {
      // Registration failed
      return msg;
      print("Registration failed with status: ${response.statusCode}");
      print("Response body: ${msg}");
      throw Exception("Failed to register");
    }
  }

  Future<String> authlogin(String email, String password) async {
    final Map<String, String> data = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse('${baseUrl}login'),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Login successful
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Save user data to SharedPreferences
      // saveUserDataToPrefs(jsonResponse);
      await saveUserDataToPrefs(jsonResponse);
      return jsonResponse["access_token"];
    } else {
      // Login failed
      print("Login failed with status: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception("Failed to authenticate");
    }
  }

  Future<void> saveUserDataToPrefs(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('oops_token', userData['access_token']);
    // Add any other user data you want to save
  }

  Future<Map<String, dynamic>> getUserDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userData = {
      'token': prefs.getString('oops_token') ?? '',
      // Add any other user data you want to retrieve
    };
    return userData;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('oops_token');
    // Add removal of any other user data as needed
  }
}
