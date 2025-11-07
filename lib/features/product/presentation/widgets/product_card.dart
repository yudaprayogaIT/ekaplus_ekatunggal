import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.width = 150,
  }) : super(key: key);

  String _firstVariantImage(Product p) {
    try {
      if (p.variants.isNotEmpty) {
        final v = p.variants.first;
        // Normalize JSON image path "/images/items/..." -> "assets/images/items/..."
        final raw = (v as dynamic).image ?? '';
        if (raw is String && raw.isNotEmpty) {
          return raw.replaceFirst(RegExp(r'^/+'), 'assets/'); // remove leading slash and prefix assets/
        }
      }
    } catch (_) {}
    return ''; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _firstVariantImage(product);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // card image
            Container(
              height: width, // square image like desain
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported)),
                    )
                  : const Center(child: Icon(Icons.image, size: 36)),
            ),

            const SizedBox(height: 8),

            // product title (use product.name; keep short)
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            // action row (Lihat)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lihat',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
