import 'dart:convert';
import 'package:http/http.dart' as http;

class CotohaApi {
  final _clientId;
  final _clientSecret;
  final _devApiBaseUrl;
  final _accessTokenPublishUrl;
  var _accessToken;

  CotohaApi(this._clientId, this._clientSecret, this._devApiBaseUrl,
      this._accessTokenPublishUrl) {}

  Future<bool> init() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8'
    };

    String body = json.encode({
      "grantType": "client_credentials",
      "clientId": _clientId,
      "clientSecret": _clientSecret
    });
    http.Response response =
        await http.post(_accessTokenPublishUrl, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _accessToken = jsonDecode(response.body)["access_token"];
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> userAttribute(
      String message, String type, bool do_segment) async {
    var url = _devApiBaseUrl + "nlp/beta/user_attribute";
    Map<String, String> headers = {
      "Content-Type": "application/json;charset=UTF-8",
      "Authorization": "Bearer " + _accessToken,
    };

    String body = json.encode({
      "document": message,
      "type": type,
      "do_segment": do_segment,
    });

    http.Response response = await http.post(url, headers: headers, body: body);
    return jsonDecode(response.body)['result'];
    /*
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return "";
    }
    */
  }
}
