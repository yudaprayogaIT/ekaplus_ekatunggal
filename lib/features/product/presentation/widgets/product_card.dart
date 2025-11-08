import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:flutter/cupertino.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.width = 180,
  }) : super(key: key);

  String _firstVariantImage(Product p) {
    try {
      if (p.variants.isNotEmpty) {
        final v = p.variants.first;
        // Normalize JSON image path "/images/items/..." -> "assets/images/items/..."
        final raw = (v as dynamic).image ?? '';
        if (raw is String && raw.isNotEmpty) {
          return raw.replaceFirst(
            RegExp(r'^/+'),
            'assets/',
          ); // remove leading slash and prefix assets/
        }
      }
    } catch (_) {}
    return ''; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _firstVariantImage(product);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(50, 50, 93, 0.177),
                blurRadius: 5,
                spreadRadius: -1,
                offset: Offset(0, 2),
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.137),
                blurRadius: 3,
                spreadRadius: -1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge, // supaya child ikut rounded
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // image (square)
              AspectRatio(
                aspectRatio: 1, // square
                child: imagePath.isNotEmpty
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      )
                    : const Center(child: Icon(Icons.image, size: 36)),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    // kiri: nama + lihat
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lihat',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontFamily: AppFonts.secondaryFont,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // kanan: icon
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(CupertinoIcons.arrow_right, size: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
