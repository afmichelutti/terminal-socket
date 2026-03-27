import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:shop_blink/api/config/environment.dart';

class ShoppAPI {
  static final Dio _dio = Dio();

  static void configureDio({required bool socket, String token = ''}) {
    _dio.options.baseUrl = EnvironmentConfig.urlsConfig(socket: socket);
    _dio.options.headers.clear();
    if (socket) {
      _dio.options.headers = {'socket_client': token};
    } else {
      if (token.isNotEmpty) {
        _dio.options.headers = {'Authorization': 'Bearer $token'};
      }
    }
    _dio.options.contentType = 'application/json';
  }

  static Future httpGet(String path) async {
    try {
      final resp = await _dio.get(path);
      return resp.data;
    } on DioError catch (e) {
      throw ('Erro no GET ${e.response}');
    }
  }

  static Future post(String path, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post<String>(path, data: data);
      return resp.data;
    } on DioError catch (e) {
      throw ('Erro no POST ${e.response}');
    }
  }

  static Future put(String path, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put<String>(path, data: data);
      return resp.data;
    } on DioError catch (e) {
      throw ('Erro no PUT  ${e.response}');
    }
  }

  static Future delete(String path, Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);
    try {
      final resp = await _dio.delete(path, data: formData);
      return resp.data;
    } on DioError catch (e) {
      throw ('Erro no DELETE  ${e.response}');
    }
  }

  static Future uploadFile(String path, Uint8List bytes) async {
    final formData = FormData.fromMap({
      'archivo': MultipartFile.fromBytes(bytes),
    });
    try {
      final resp = await _dio.put(path, data: formData);
      return resp.data;
    } on DioError catch (e) {
      throw ('Erro no PUT  ${e.response}');
    }
  }
}
