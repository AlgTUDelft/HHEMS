import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;

class HemsBackendUtil {
  static final HemsBackendUtil _instance = HemsBackendUtil._();
  String? baseUrl;

  /// Returns the singleton instance for the class.
  factory HemsBackendUtil() {
    return _instance;
  }

  /// Initiliaze the [baseUrl] from the environment.
  ///
  /// This is a temporary constructor that initilizes this class from the HEMS_URL environment variable.
  /// It should be replaced with a different mechanism to get the hems server url in the future.
  HemsBackendUtil._()
    : baseUrl =
          const bool.hasEnvironment('HEMS_URL')
              ? const String.fromEnvironment('HEMS_URL')
              : null;

  /// Gets the given [path] as a JSON object from the HEMS server
  ///
  /// If the request is successful returns a Left containing the decoded result.
  /// Returns a Right containing an error message otherwise.
  Future<Either<dynamic, String>> getJson(String path) async {
    switch (baseUrl) {
      case String baseUrl?:
        try {
          final response = await http.get(Uri.parse("$baseUrl/$path"));
          return responseToJson(response);
        } catch (e) {
          return Right("$e");
        }
      default:
        return Right("Hems Core URL not set");
    }
  }

  /// Gets the given [path] as a plain string from the HEMS server.
  ///
  /// If the request is successful returns a Left containing the result.
  /// Returns a Right containing an error message otherwise.
  Future<Either<String, String>> getPlain(String path) async {
    switch (baseUrl) {
      case String baseUrl?:
        try {
          final response = await http.get(Uri.parse("$baseUrl/$path"));
          return responseToString(response);
        } catch (e) {
          return Right('$e');
        }
      default:
        return Right("Hems Core URL not set");
    }
  }

  /// Converts [response] to the revelant result.
  ///
  /// Returns a Left containing the decoded result if the request succeeds with a 200 OK
  /// and the response is valid JSON.
  /// Otherwsie returns a Right containg an error message.
  Either<dynamic, String> responseToJson(http.Response response) {
    if (response.statusCode != 200) {
      return Right('HTTP ${response.statusCode}: ${response.body}');
    }

    try {
      return Left(jsonDecode(response.body));
    } catch (_) {
      return Right("Server response is not valid JSON");
    }
  }

  /// Converts [response] to the revelant result.
  ///
  /// Returns a Left containing the result if the request succeeds with a 200 OK
  /// Otherwsie returns a Right containg an error message.
  Either<String, String> responseToString(http.Response response) {
    if (response.statusCode != 200) {
      return Right('HTTP ${response.statusCode}: ${response.body}');
    }

    return Left(response.body);
  }

  /// Posts to the given [path] using [json] as the body to the HEMS server.
  ///
  /// If the request is successful returns a Left containing a decoded result.
  /// Returns a Right containing an error message otherwise.
  Future<Either<dynamic, String>> postJSON(
    String path,
    Map<String, dynamic> json,
  ) async {
    switch (baseUrl) {
      case String baseUrl?:
        var headers = {'Content-Type': 'application/json'};
        try {
          final response = await http.post(
            Uri.parse("$baseUrl/$path"),
            headers: headers,
            body: jsonEncode(json),
          );
          return responseToJson(response);
        } catch (e) {
          return Right("$e");
        }
      default:
        return Right("Hems Core URL not set");
    }
  }

  /// Deletes entity present in the [path] from HEMS server.
  ///
  /// If the request is successful returns a Left containing a response message.
  /// Returns a Right containing an error message otherwise.
  Future<Either<String, String>> deletePlain(String path) async {
    switch (baseUrl) {
      case String baseUrl?:
        try {
          final response = await http.delete(Uri.parse("$baseUrl/$path"));
          return responseToString(response);
        } catch (e) {
          return Right("$e");
        }
      default:
        return Right("Hems Core URL not set");
    }
  }
}
