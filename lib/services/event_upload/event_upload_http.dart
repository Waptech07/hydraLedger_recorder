import 'dart:developer';

import 'package:dio/dio.dart';

import '../base_http.dart';

class EventUploadHttpService extends HttpService {
  EventUploadHttpService()
      : super(
          collectionUrl: "",
        );

  Future eventUpload(String path, deviceId) async {
    try {
      var formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          path,
        ),
        'id': deviceId,
      });
      final req = await http.post(
        "/event/upload",
        data: formData,
      );

      log("event upload response -${req.data}");

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
