import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Material\nSpringbed', 'icon': Icons.bed},
      {'label': 'Material\nSofa', 'icon': Icons.chair},
      {'label': 'Material\nSpringbed 2', 'icon': Icons.layers},
      {'label': 'Mesin &\nSparepart', 'icon': Icons.precision_manufacturing},
      {'label': 'Furniture', 'icon': Icons.weekend},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final item = categories[idx];
          return Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)],
                ),
                child: Icon(item['icon'] as IconData, size: 32, color: Colors.red),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 78,
                child: Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
