import 'package:flutter/material.dart';
import 'package:kaloriku/model/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodsModel foodRes;
  final Function() onDismissed;
  final FoodResponse response; // Tambahkan response agar bisa digunakan

  const FoodCard({
    Key? key,
    required this.foodRes,
    required this.onDismissed,
    required this.response, // Gunakan response di sini
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(foodRes.id),
      onDismissed: (direction) {
        onDismissed();
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.lightBlue[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow('Nama', foodRes.name),
            _buildDataRow('Bahan', foodRes.ingredients),
            _buildDataRow('Deskripsi', foodRes.description),
            _buildDataRow('Kalori', '${foodRes.calories} kcal'),
            _buildDataRow('Kategori', foodRes.category),
            const SizedBox(height: 10),
            Text(
              'Response: ${response.message}', // Menampilkan response message
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ': $value',
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
