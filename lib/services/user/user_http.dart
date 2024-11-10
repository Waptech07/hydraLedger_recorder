import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hydraledger_recorder/models/request/edit_profile_request.dart';
import 'package:hydraledger_recorder/services/base_http.dart';

class UserHttpService extends HttpService {
  UserHttpService()
      : super(
          collectionUrl: "",
        );

  Future getUser(String email) async {
    try {
      final req = await http.get(
        "/user/$email",
      );

      log("user data -${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  // Future<Map<String, dynamic>> updateUser(
  //     String email, EditProfileRequest data) async {
  //   try {
  //     final req = await http.post(
  //       "/user/update",
  //       data: {"email": email, "data": data.toJson()},
  //     );

  //     return req.data;
  //   } on DioError catch (e) {
  //     log('Error while making request: $e');
  //     throw {
  //       "statusCode": e.response?.statusCode,
  //       "data": e.response?.data ?? {"message": e.error ?? e}
  //     };
  //   }
  // }

  Future<String> updateUser(String email, EditProfileRequest data) async {
    try {
      log('update profile request ${data.toJson()}');

      final response = await http.post(
        "/user/update",
        data: {"email": email, ...data.toJson()},
      );
      return response.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e.toString()}
      };
    }
  }

  Future<Map<String, dynamic>> updateUserTap(
    String username,
    String cid,
  ) async {
    try {
      final req = await http.post(
        "/user/tap",
        data: {
          "username": username,
          "cid": cid,
        },
      );

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }
}
