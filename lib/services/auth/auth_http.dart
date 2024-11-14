import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:voice_recorder/services/base_http.dart';

import '../../models/request/create_user_request.dart';

class AuthHttpService extends HttpService {
  AuthHttpService()
      : super(
          collectionUrl: "",
        );

  Future createUser(CreateUserRequest data) async {
    try {
      final req = await http.post(
        "/create/user",
        data: data.toJson(),
      );

      log("create user data -${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  Future<String> login(String id, String password) async {
    try {
      final req = await http.post(
        "/auth",
        data: {
          "id": id,
          "password": password,
        },
      );

      log("login data - ${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  Future<Map<String, dynamic>> sendEmailVerifyOtp(String email) async {
    try {
      final req = await http.get(
        "/otp/send/$email",
      );

      log("sendEmailOtp data - ${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    try {
      final req = await http.post(
        "/otp/verify",
        data: {
          "email": email,
          "otp": otp,
        },
      );

      log("verifyOtp data - ${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetOtp(String email) async {
    try {
      final req = await http.get(
        "/password/otp/$email",
      );

      log("sendPassword otp data - ${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  Future<Map<String, dynamic>> verifyPasswordChangeOtp(
      String email, String otp) async {
    try {
      final req = await http.post(
        "/password/verify-otp",
        data: {
          "email": email,
          "otp": otp,
        },
      );

      log("verifyPasswordOtp data - ${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String token,
    required String password,
    required String passwordHint,
  }) async {
    try {
      final req = await http.post(
        "/password/change",
        data: {
          "email": email,
          "token": token,
          "password": password,
          "password_hint": passwordHint,
        },
      );

      log("changePassword data - ${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while changing password: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }
}
