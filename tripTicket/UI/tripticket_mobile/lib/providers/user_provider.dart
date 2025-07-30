import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tripticket_mobile/providers/base_provider.dart';
import 'package:tripticket_mobile/models/user_model.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    var url = "${BaseProvider.baseUrl}User/login";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var body = jsonEncode({"username": username, "password": password});

    var response = await http.post(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Login failed: ${response.statusCode}");
    }
  }
}
