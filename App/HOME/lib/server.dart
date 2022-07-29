import 'dart:convert';
import 'package:http/http.dart' as http;

class Server {
  final _urlGet = "http://192.168.8.100/get";
  final _urlPost = "http://192.168.8.100/post";

  bool _light1 = false;
  bool _light2 = false;
  bool _sub = false;
  bool _ceiling = false;
  bool _table = false;
  bool _fan = false;
  int _speed = 50;

  Future<String> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(_urlGet));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        _light1 = jsonData['light1'];
        _light2 = jsonData['light2'];
        _sub = jsonData['sub'];
        _ceiling = jsonData['ceiling'];
        _table = jsonData['table'];
        _fan = jsonData['fan'];
        _speed = jsonData['speed'];

        return "Data Fetching successful!";
      } else {
        return response.reasonPhrase.toString();
      }
    } catch (err) {
      return "Error!.Somethings wrong.Please try again.";
    }
  }

  Future<String> postData(String key, String value) async {
    try {
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var request = http.Request('POST', Uri.parse(_urlPost));
      request.bodyFields = {key: value};
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        if (key == 'sub' && value == 'true') {
          _sub = true;
        } else if (key == 'sub' && value == 'false') {
          _sub = false;
        }

        if (key == 'ceiling' && value == 'true') {
          _ceiling = true;
        } else if (key == 'ceiling' && value == 'false') {
          _ceiling = false;
        }

        if (key == 'table' && value == 'true') {
          _table = true;
        } else if (key == 'table' && value == 'false') {
          _table = false;
        }

        if (key == 'fan' && value == 'true') {
          _fan = true;
        } else if (key == 'fan' && value == 'false') {
          _fan = false;
        }

        if (key == 'speed') {
          _speed = int.parse(value);
        }

        if (key == 'off') {
          _light1 = false;
          _light2 = false;
          _sub = false;
          _ceiling = false;
          _table = false;
          _fan = false;
          _speed = 50;
        }

        return "Change Successful!";
      } else {
        return response.reasonPhrase.toString();
      }
    } catch (err) {
      return "Error!.Somethings wrong.Please try again.";
    }
  }

  bool get getLight1 {
    return _light1;
  }

  bool get getLight2 {
    return _light2;
  }

  bool get getSub {
    return _sub;
  }

  bool get getCeiling {
    return _ceiling;
  }

  bool get getTable {
    return _table;
  }

  bool get getFan {
    return _fan;
  }

  int get getSpeed {
    return _speed;
  }
}
