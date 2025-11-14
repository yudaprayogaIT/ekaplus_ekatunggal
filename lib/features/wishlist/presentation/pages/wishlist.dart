import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/constant.dart';

class WishlistPage extends StatelessWidget {
  /// Jika kamu sudah punya mekanisme auth, pass [isLoggedIn] = true untuk
  /// menampilkan wishlist sebenarnya. Default false (tampil locked state).
  final bool isLoggedIn;

  const WishlistPage({Key? key, this.isLoggedIn = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerColor = AppColors.primaryColor;
    final primaryYellow = AppColors.secondaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header merah dengan judul
          Container(
            width: double.infinity,
            color: headerColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  'Wishlist',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Konten utama
          Expanded(
            child: isLoggedIn
                ? _buildEmptyWishlist(context)
                : _buildLockedState(context, primaryYellow),
          ),

          // Jika kamu pakai BottomNav global di app, kamu bisa hilangkan bagian ini.
        ],
      ),
    );
  }

  Widget _buildLockedState(BuildContext context, Color primaryYellow) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              width: 140,
              height: 140,
              child: Center(
                child: Builder(
                  builder: (ctx) {
                    const assetPath = 'assets/images/wishlistIcon.png';
                    try {
                      return Image.asset(assetPath, fit: BoxFit.contain);
                    } catch (_) {
                      return const Icon(Icons.favorite_border, size: 120);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 28),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text:
                        'Wishlist hanya bisa diakses oleh pengguna yang sudah masuk.\nSilahkan ',
                  ),
                  TextSpan(
                    text: 'masuk atau daftar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: ' untuk menyimpan produk favorit Anda.'),
                ],
              ),
            ),

            const Spacer(),

            // Tombol Daftar + Masuk
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // ganti nama route jika berbeda (contoh: 'register')
                      context.pushNamed('register');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'DAFTAR',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontWeight: FontWeight.w700,
                        color: const Color(
                          0xFFF6B500,
                        ), // kuning tipis di screenshot
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ganti nama route jika berbeda (contoh: 'login')
                      context.pushNamed('login');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: primaryYellow,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'MASUK',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Text(
        'Belum ada produk di wishlist',
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 15,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
