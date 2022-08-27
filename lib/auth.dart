import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate = DateTime.now();
  String? _userId;

  bool get isAuth {
    return token != '';
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != '') {
      return _token;
    }
    return '';
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAcKxAyjNPUb9shY8noj1EFwrXZIfoNfjo";

    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final resdata = json.decode(res.body);
      if (resdata['error'] != null) {
        throw '${resdata['error']['message']}';
      }
      _token = resdata['idToken'];
      _userId = resdata['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(resdata['expiresIn'])));
      _autoLogout();
      notifyListeners();

      //SharedPreferences من  obj
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (e) {
      print('MMMMMMMM: $e');
      //throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final Map<String, Object> extractedData = json
        .decode(prefs.getString('userData') as String) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedData['token'] as String;
    _userId = extractedData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    //_expiryDate='';
    print('Test');
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    //prefs.remove('userData');
  }

  // تنتهي فترة تسجيل الدخول للشخص
  void _autoLogout() {
    // حتى نحسب فرق الوقت
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    print('<<<<<<<<<<<<<<<<object>>>>>>>>>>>>>>>>');
    Timer(
      Duration(seconds: timeToExpiry),
      logout,
    );
  }
}
