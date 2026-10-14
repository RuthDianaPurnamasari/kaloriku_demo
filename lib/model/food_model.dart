import 'package:flutter/material.dart';

class FoodsModel {
  final String id;
  final String name;
  final String ingredients;
  final String description;
  final int calories; // Menggunakan double agar fleksibel
  final String category;

  FoodsModel({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.description,
    required this.calories,
    required this.category,
  });

   // Ubah dari JSON
  factory FoodsModel.fromJson(Map<String, dynamic> json) {
    return FoodsModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      ingredients: json['ingredients'] ?? '',
      description: json['description'] ?? '',
      calories: _parseCalories(json['calories']), // ✅ Gunakan helper
      category: json['category'] ?? '',
    );
  }

  // Fungsi helper untuk menangani berbagai tipe data calories
  static int _parseCalories(dynamic value) {
    if (value is int) return value; // Jika sudah int, langsung return
    if (value is String) return int.tryParse(value) ?? 0; // Jika String, konversi ke int
    if (value is double) return value.toInt(); // Jika double, konversi ke int
    return 0; // Default jika null atau tipe lain
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "ingredients": ingredients,
        "description": description,
        "calories": calories, // Pastikan tetap dalam int
        "category": category,
      };
  // Getter untuk format "gram kcal"
  String get formattedCalories => '${calories.toStringAsFixed(1)} kcal';
}


// ✅ Model untuk form input makanan
class FoodInput {
  final String name;
  final String ingredients;
  final String description;
  final double calories;
  final String category;

  FoodInput({
    required this.name,
    required this.ingredients,
    required this.description,
    required this.calories,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "ingredients": ingredients,
        "description": description,
        "calories": calories,
        "category": category,
      };
}

// ✅ Model untuk response dari API
class FoodResponse {
  final String? insertedId;
  final String message;
  final int status;

  FoodResponse({
    this.insertedId,
    required this.message,
    required this.status,
  });

  factory FoodResponse.fromJson(Map<String, dynamic> json) => FoodResponse(
        insertedId: json["inserted_id"],
        message: json["message"],
        status: json["status"],
      );
}
