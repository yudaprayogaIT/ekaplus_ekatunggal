import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ekaplus_ekatunggal/features/type/data/models/type_model.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';

class TypeCategoryList extends StatelessWidget {
  final int page; // kalau mau paging di masa depan
  const TypeCategoryList({Key? key, this.page = 1}) : super(key: key);

  Future<List<Type>> _loadTypesFromAsset() async {
    final String body = await rootBundle.loadString('assets/data/itemType.json');
    final dynamic decoded = jsonDecode(body);
    final List<dynamic> data = decoded is List ? decoded : (decoded['data'] ?? []);
    return TypeModel.fromJsonList(data);
  }

  // Palet warna pastel untuk background ikon (sesuaikan jika mau)
  // static const List<Color> _bgColors = [
  //   Color(0xFFE8F7F5), // mint
  //   Color(0xFFFDEFF3), // pink
  //   Color(0xFFFFF6E0), // light yellow
  //   Color(0xFFEFF6FF), // light blue
  //   Color(0xFFF2FFF0), // light green
  // ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Type>>(
      future: _loadTypesFromAsset(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 120,
            child: Center(child: Text('Gagal memuat kategori', style: TextStyle(color: Colors.red.shade700))),
          );
        }

        final types = snapshot.data ?? [];

        // tampilkan maksimal 5 item (sama seperti gambar)
        final visible = types.length > 5 ? types.sublist(0, 5) : types;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final Type item = visible[index];
                    // final bg = _bgColors[index % _bgColors.length];

                    return GestureDetector(
                      onTap: () {
                        // TODO: navigasi ke halaman list produk untuk tipe ini
                        // Navigator.of(context).pushNamed('/products', arguments: item.id);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              // color: bg,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _buildTypeImage(item),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 88,
                            child: Text(
                              item.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // "Lihat Semua" link di tengah bawah
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // TODO: navigasi ke layar semua kategori / products
                  // Navigator.of(context).pushNamed('/all-types');
                },
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeImage(Type item) {
    final String? imgPath = item.image;
    if (imgPath != null && imgPath.isNotEmpty) {
      // jika asset path valid, tampilkan
      return Image.asset(
        imgPath,
        fit: BoxFit.contain,
        // jika gambar SVG, pastikan kamu punya flutter_svg dan gunakan SvgPicture.asset
      );
    }

    // fallback icon jika tidak ada gambar
    return const Icon(Icons.category, size: 36);
  }
}
