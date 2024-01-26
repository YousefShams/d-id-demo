import 'package:http/http.dart' as http;
class RemoteApi {

  Future<http.Response> get(String url, Map<String,String>? headers) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }

  Future<http.Response> post(String url, Map<String,String>? headers, Object? body) async {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    return response;
  }

  Future<http.Response> delete(String url, Map<String,String>? headers, Object? body) async {
    final response = await http.delete(Uri.parse(url), headers: headers, body: body);
    return response;
  }
}