import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class HashHelper {
  Dio client = Dio(
    BaseOptions(
        baseUrl: 'http://185.163.116.168:3000/api/',
        validateStatus: (status) => true,
        receiveTimeout: Duration(seconds: 6)),
  );

  Future<String?> tryAddHashToBC(String hash) async {
    log('||| $hash');
    //using dio
    print("Started hashing request...");
    var res = await client.post('blockchain/hash/' + hash);
    if (res.statusCode == 200) {
      print("Hashing request completed with result: ${res.toString()}");
      var body = jsonDecode(res.toString());
      return body["id"];
    } else {
      print("Hashing request failed with result: ${res.toString()}");
      return null;
    }
  }

  Future<bool> checkIfHashAlreadyExist(String hash) async {
    var encodedHash = Uri.encodeComponent(hash);
    print("Checking for hash existance of hash: $encodedHash");
    var res = await client.get('blockchain/hash/$encodedHash/exists');
    print(
        "Checked for hash existance of hash: $encodedHash, result: ${res.data}");
    return res.statusCode == 200;
  }
}
