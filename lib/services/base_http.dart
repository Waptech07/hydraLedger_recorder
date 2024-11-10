import 'dart:developer';

import 'package:dio/dio.dart';

import '../utils/helpers.dart';

class AppTransformer extends DefaultTransformer {
  AppTransformer() : super(jsonDecodeCallback: parseJson);
}

//baseUrl
// String baseUrl = "https://hrecorder-api.onrender.com";
String baseUrl = "http://api.hrecorder.com";
String fs3BaseUrl = "https://node.lighthouse.storage";

class HttpService {
  final collectionUrl;
  final bool isUploadingToFs3;
  late Dio http;

  HttpService({
    required this.collectionUrl,
    this.isUploadingToFs3 = false,
  }) {
    http = Dio(
      BaseOptions(
        baseUrl: isUploadingToFs3
            ? "$fs3BaseUrl$collectionUrl"
            : "$baseUrl$collectionUrl",
      ),
    );

    // Configure the interceptors and transformers for both instances as needed
    _configureInterceptors(http, isUploadingToFs3);

    http.transformer = AppTransformer();
  }

  void _configureInterceptors(Dio dioInterceptors, bool isUploadingToFs3) {
    dioInterceptors.interceptors.add(
      InterceptorsWrapper(onRequest: (RequestOptions opts, handler) async {
        print({
          "url": "${opts.baseUrl}${opts.path}",
          "body": opts.data,
          "params": opts.queryParameters,
        });

        if (isUploadingToFs3) {
          opts.headers["Authorization"] =
              "Bearer 70c1b967.ee5bac114aae488f9ddac5787f2a676f";
        }

        return handler.next(opts);
      }, onError: (DioError e, handler) async {
        print({
          "statusCode": e.response?.statusCode,
          "statusMessage": e.response?.statusMessage,
          "data": e.response?.data ?? {"message": e.error ?? e}
        });
        if (e.response?.statusCode == 404) {
          // todo: return service not found
          DioError response = e;
          response.response?.statusMessage =
              "Service is presently unavailable at the moment";
          return handler.next(response);
        }
        if ((e.response?.statusCode ?? 500) >= 500) {
          // todo: return service not found
          DioError response = e;
          response.response?.statusMessage =
              "Service is presently unavailable at the moment";
          return handler.next(response);
        }
        if (e.response?.statusCode == 400) {
          // todo: return bad request.
          DioError response = e;
          response.response?.statusMessage =
              "Request sent is badly formatted, please try again.";
          return handler.next(response);
        }

        DioError response = e;
        response.response?.statusMessage =
            "Service is temporary unavailable, please try again.";
        return handler.next(response);
      }, onResponse: (Response res, handler) {
        log({
          "data": res.data,
          "statusCode": res.statusCode,
          "statusMessage": res.statusMessage,
        }.toString());

        return handler.next(res);
      }),
    );
  }
}
