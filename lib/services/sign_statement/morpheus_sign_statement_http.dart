import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hydraledger_recorder/models/request/morpheus_sign_statement_request.dart';

import '../base_http.dart';

class MorpheusSignStatementHttpService extends HttpService {
  MorpheusSignStatementHttpService()
      : super(
          collectionUrl: "",
        );

  Future morpheusSignStatement(MorpheusSignStatementRequest data) async {
    try {
      final req = await http.post(
        "/morpheus/sign_statement",
        data: data.toJson(),
      );

      log("my new data -${req.data}");

      return req.data;
    } on DioError catch (e) {
      log('Error while making request: $e');
      throw {
        "statusCode": e.response?.statusCode,
        "data": e.response?.data ?? {"message": e.error ?? e}
      };
    }
  }

  Future updateWitness(
    String userName,
    String cid,
    String witnessUsername,
    String did,
  ) async {
    try {
      final req = await http.post(
        "/witness/update",
        data: {
          "username": userName,
          "cid": cid,
          "witness": {
            "username": witnessUsername,
            "did": did,
          }
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
