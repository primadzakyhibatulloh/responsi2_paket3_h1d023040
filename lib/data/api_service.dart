import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/book.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
        }, 
        body: {
          'name': name,
          'email': email,
          'password': password
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<List<Book>> getBooks() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> listJson = data['data'] ?? [];
      return listJson.map((item) => Book.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> addBook(Book book) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode(book.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateBook(int id, Book book) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode(book.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteBook(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },
    );
    return response.statusCode == 200;
  }
}