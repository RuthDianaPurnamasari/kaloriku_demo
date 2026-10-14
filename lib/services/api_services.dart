import 'package:dio/dio.dart';
import 'package:kaloriku/model/food_model.dart';
import 'package:kaloriku/model/login_model.dart';
import 'package:flutter/material.dart';

class ApiServices {
  final Dio dio = Dio();
  final String _baseUrl = 'https://ws-kaloriku-4cf736febaf0.herokuapp.com';

  Future<Iterable<FoodsModel>?> getAllMenuItem() async {
    try {
      var response = await dio.get('$_baseUrl/menu');

      debugPrint('Response API: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          // ✅ Jika response berupa List, lakukan mapping
          final foodList = (response.data as List)
              .map((food) => FoodsModel.fromJson(food))
              .toList();
          return foodList;
        } else if (response.data is Map<String, dynamic>) {
          // ✅ Jika hanya ada satu objek, langsung ubah ke List
          return [FoodsModel.fromJson(response.data)];
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode != 200) {
        debugPrint('❌ Client error - the request cannot be fulfilled');
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  final String token = 'your_token_here'; // Define your token here

  Future<FoodResponse?> postMenu(FoodInput food, double calories, String trim, String s) async {
    try {
      final response = await dio.post(
        '$_baseUrl/insertMenu',
        data: food.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return FoodResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('❌ Error posting menu: $e');
    }
    return null;
  }

  Future<FoodsModel?> getSingleFood(String id) async {
    try {
      var response = await dio.get('$_baseUrl/menu/$id');

      print("📡 Response dari API: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        return FoodsModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode != 200) {
        debugPrint('Client error - the request cannot be fulfilled');
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<FoodResponse?> putMenu(String id, FoodInput food, double calories, String trim, String s) async {
    try {
      final response = await dio.put(
        '$_baseUrl/updateMenu/$id',
        data: food.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return FoodResponse.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('❌ Error updating menu: $e');
    }
    return null;
  }

  Future<FoodResponse?> deleteFood(String id) async {
  try {
    final response = await dio.delete(
      '$_baseUrl/deleteMenu/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Menu berhasil dihapus!');

      // Jika API mengembalikan response, parsing ke model
      if (response.data is Map<String, dynamic>) {
        return FoodResponse.fromJson(response.data);
      }
    }
  } catch (e) {
    debugPrint('❌ Error deleting menu: $e');
  }
  return null;
}


  Future<LoginResponse?> login(LoginInput login) async {
    try {
      final String url = '$_baseUrl/login';
  
      debugPrint('🔍 Request ke: $url');

      final response = await dio.post(
        url,
        data: login.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('✅ Response: ${response.data}');

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            '🚨 Login error: ${e.response!.statusCode} - ${e.response!.data}');

        if (e.response!.statusCode == 404) {
          debugPrint('⚠️ Endpoint /login tidak ditemukan! Cek API backend.');
        } else if (e.response!.statusCode == 401) {
          debugPrint('⚠️ Unauthorized! Pastikan username & password benar.');
        }

        return null;
      } else {
        debugPrint('🚨 Request error: ${e.message}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Unexpected error: $e');
      return null;
    }
  }

  Future<void> deleteMenu(String id) async {}
}
