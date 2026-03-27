import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:painel_producao_blink/config/environment.dart';
// import 'package:painel_producao_blink/services/local_storage.dart';

class CafeApi {
  static final Dio _dio = Dio();

  static void configureDio() {
    _dio.options.baseUrl = EnvironmentConfig.urlsConfig();
    _dio.options.headers = {
      'socket_client':
          '3C5B0512-81F1-4740-A5EC-54F21A24571A', //LocalStorage.prefs.getString('token'),
    };
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
    //final formData = FormData.fromMap(data);
    try {
      final resp = await _dio.post<String>(path, data: data);
      return resp.data;
    } on DioError catch (e) {
      throw ('Erro no POST ${e.response}');
    }
  }

  static Future put(String path, Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);
    try {
      final resp = await _dio.put(path, data: formData);
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
