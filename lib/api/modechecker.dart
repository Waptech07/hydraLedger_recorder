import 'package:dio/dio.dart';

class ModeChecker {
  Dio client = Dio(
    BaseOptions(
        baseUrl: 'http://185.163.116.168:3000/api/',
        validateStatus: (status) => true,
        receiveTimeout: Duration(seconds: 6)),
  );

  Future<NetMode> getMode() async {
    var res = await client.get('netmode');
    if (res.statusCode == 200) {
      var body = res.data;
      if (body['NETMODE'] == 'MAINNET') {
        return NetMode.main;
      } else {
        return NetMode.dev;
      }
    } else {
      return NetMode.dev;
    }
  }
}

enum NetMode {
  main,
  dev,
}
