import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:tripticket_desktop/providers/auth_provider.dart';

class UserProvider {
  UserProvider() {}

  Future<dynamic> login(String username, String password) async {
    print("$username:$password");
    var url = "http://localhost:5255/User/login";
    var uri = Uri.parse(url);

    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', ...createHeaders()},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Login failed: ${response.statusCode}");
    }
  }

  bool isValidResponse(Response response) {
    print(response.statusCode);
    if (response.statusCode < 299)
      return true;
    else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      throw new Exception("Something went wrong, please try again");
    }
  }

  Map<String, String> createHeaders() {
    String username = AuthProvider.username!;
    String password = AuthProvider.password!;

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    return {"Content-Type": "application/json", "Authorization": basicAuth};
  }
}
