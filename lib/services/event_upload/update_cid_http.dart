import 'dart:developer';

import 'package:dio/dio.dart';

import '../base_http.dart';

class UpdateCIDHttpService extends HttpService {
  UpdateCIDHttpService()
      : super(
          collectionUrl: "",
        );

  Future<Map<String, dynamic>> updateCID({
    String? username,
    String? cid,
    String? name,
    String? date,
    String? txId,
    String? bcProof,
    String? mediaHash,
    String? deviceId,
    String? description,
  }) async {
    try {
      final req = await http.post(
        "/user/set-cid",
        data: {
          "username": username,
          "cid": cid,
          "name": name,
          "date": date,
          "proof": {
            "tx_id": txId,
            "bc_proof": bcProof,
            "device_id": deviceId,
            "media_hash": mediaHash,
          },
          "descripton": description,
        },
      );

      log("updated cid -${req.data}");

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
