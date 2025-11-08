import 'dart:convert';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class SectionWithProducts extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int showCount;

  const SectionWithProducts({
    Key? key,
    this.title = 'Yang Baru Dari Kami',
    this.subtitle,
    this.showCount = 6,
  }) : super(key: key);

  @override
  State<SectionWithProducts> createState() => _SectionWithProductsState();
}

class _SectionWithProductsState extends State<SectionWithProducts> {
  late Future<List<ProductModel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProductsFromAssets();
  }

  Future<List<ProductModel>> _loadProductsFromAssets() async {
    final body = await rootBundle.loadString('assets/data/products.json');
    final dynamic decoded = jsonDecode(body);
    final List<dynamic> list = decoded is List ? decoded : (decoded['data'] ?? []);
    return ProductModel.fromJsonList(list);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Gagal memuat produk: ${snapshot.error}'),
          );
        }

        final List<ProductModel> products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('Belum ada produk.'),
          );
        }

        final displayList = products.take(widget.showCount).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header: title + lihat semua
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: AppFonts.primaryFont),
                  ),
                  InkWell(
                    onTap: () {
                      // TODO: navigate to all products page
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(widget.subtitle!, style: const TextStyle(color: AppColors.grayColor, fontSize: 11, fontWeight: FontWeight.w500)),
              ],

              const SizedBox(height: 12),

              // Beri padding vertikal supaya shadow kartu tidak kepotong
              SizedBox(
                height: 260, // sedikit lebih besar untuk mengakomodasi shadow
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final p = displayList[index];
                    return ProductCard(
                      product: p,
                      width: 176,
                      onTap: () {
                        // TODO: buka detail product
                        // Navigator.pushNamed(context, '/productDetail', arguments: p.id.toString());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
