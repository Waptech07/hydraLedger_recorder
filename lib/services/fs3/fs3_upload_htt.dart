import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../base_http.dart';

class Fs3UploadHttpService extends HttpService {
  Fs3UploadHttpService()
      : super(
          collectionUrl: "",
          isUploadingToFs3: true,
        );

  // Future<Map<String, dynamic>> fs3Upload(String path) async {
  //   try {
  //     var formData = FormData.fromMap({
  //       'file': await MultipartFile.fromFile(
  //         path,
  //       ),
  //     });
  //     final req = await http.post(
  //       "/api/v0/add",
  //       data: formData,
  //     );

  //     log("fs3 response -${req.data}");

  //     return req.data;
  //   } on DioError catch (e) {
  //     log('Error while making request: $e');
  //     throw {
  //       "statusCode": e.response?.statusCode,
  //       "data": e.response?.data ?? {"message": e.error ?? e}
  //     };
  //   }
  // }

  Future<Map<String, dynamic>> fs3Upload(String path) async {
    try {
      var formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          path,
        ),
      });
      final req = await http.post(
        "/api/v0/add",
        data: formData,
      );

      log("fs3 response -${req.data}");

      // Parse the JSON string to a Map
      if (req.data is String) {
        return json.decode(req.data);
      } else if (req.data is Map<String, dynamic>) {
        return req.data;
      } else {
        throw FormatException("Unexpected response format");
      }
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    } on FormatException catch (e) {
      log('Error parsing response: $e');
      throw {
        "statusCode": 500,
        "data": {"message": "Failed to parse server response"}
      };
    }
  }
}
