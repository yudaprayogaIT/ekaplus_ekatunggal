// import 'package:flutter/material.dart';
// import 'product_card.dart';

// class SectionWithProducts extends StatelessWidget {
//   final String title;
//   final List<String> chips;
//   const SectionWithProducts({super.key, required this.title, required this.chips});

//   @override
//   Widget build(BuildContext context) {
//     // mock products
//     final products = List.generate(6, (i) => {
//       'title': 'Lemari UPC',
//       'subtitle': 'Lihat',
//       'img': 'https://picsum.photos/seed/${i+10}/400/400',
//     });

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
//             TextButton(onPressed: () {}, child: const Text('Lihat Semua'))
//           ],
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 36,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: chips.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 8),
//             itemBuilder: (context, idx) {
//               return Chip(label: Text(chips[idx]));
//             },
//           ),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 220,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: products.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 12),
//             itemBuilder: (context, idx) {
//               final p = products[idx];
//               return ProductCard(
//                 title: p['title'] as String,
//                 subtitle: p['subtitle'] as String,
//                 imageUrl: p['img'] as String,
//                 onTap: () {},
//               );
//             },
//           ),
//         )
//       ],
//     );
//   }
// }
