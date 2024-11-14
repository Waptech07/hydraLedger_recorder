import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voice_recorder/models/vocie_save_model.dart';
import 'package:voice_recorder/services/auth/auth_http.dart';

class AuthState extends ChangeNotifier {
  static AuthState? _instance;
  AuthHttpService authHttpService = AuthHttpService();
  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController addressController2 = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController passwordHintController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController otpController = TextEditingController();

  bool allowMediaSharing = false;

  VoiceSaveModel? _voiceSaveModel;

  VoiceSaveModel? get voiceSaveModel => _voiceSaveModel;

  final AuthHttpService _auth = AuthHttpService();

  bool isOtpValid = false;

  updateMediaSharing(bool value) {
    allowMediaSharing = value;
    notifyListeners();
  }

  void initializeVoiceModel(VoiceSaveModel? model) {
    _voiceSaveModel = model;
    notifyListeners();
  }

  static AuthState? get instance {
    _instance ??= AuthState();
    return _instance;
  }

  Future getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedResponse = prefs.getString('createUserResponse') ?? '';
    if (savedResponse != '') {
      Map decodedMap = json.decode(savedResponse);
      idController.text = decodedMap['data']['id'];
    }
  }

  Future<bool> getIsUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isUserLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isUserLoggedIn) {
      return true;
    }

    return false;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = jsonEncode(userData);
    await prefs.setString('userdata', userDataJson);
  }

  Future<Map<String, dynamic>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('userdata');
    if (userDataJson != null) {
      return jsonDecode(userDataJson);
    }
    return null;
  }

  Future<Map<String, dynamic>> verifyOtp() {
    return _auth.verifyEmailOtp(emailController.text, otpController.text);
  }

  Future<Map<String, dynamic>> verifyPasswordChangeOtp() {
    return _auth.verifyPasswordChangeOtp(
        emailController.text, otpController.text);
  }

  clear() {
    otpController.clear();
  }
}
