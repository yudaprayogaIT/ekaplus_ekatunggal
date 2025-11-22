import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ekaplus_ekatunggal/constant.dart'; // AppFonts, dsb

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final headerColor = const Color(0xFFB71C1C);
    final primaryYellow = AppColors.secondaryColor;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(title: 'Akun',
      onLeadingPressed: () => context.goNamed('home'),),
      body: Column(
        children: [
          // Header merah dengan back button + title
          // Container(
          //   width: double.infinity,
          //   color: headerColor,
          //   child: SafeArea(
          //     bottom: false,
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(
          //         vertical: 12.0,
          //         horizontal: 12,
          //       ),
          //       child: Row(
          //         children: [
          //           GestureDetector(
          //             onTap: () => Navigator.maybePop(context),
          //             child: const Icon(Icons.arrow_back, color: Colors.white),
          //           ),
          //           const SizedBox(width: 12),
          //           Text(
          //             'Akun',
          //             style: TextStyle(
          //               fontFamily: AppFonts.primaryFont,
          //               fontSize: 16,
          //               fontWeight: FontWeight.w700,
          //               color: AppColors.whiteColor,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // Card area (ilustrasi, teks, tombol MASUK/DAFTAR)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            color: AppColors.whiteColor,
            child: Column(
              children: [
                Stack(
                  clipBehavior:
                      Clip.none, // Memungkinkan elemen keluar dari batas Stack
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 205, // Lebar gambar
                        height: 135, // Tinggi gambar
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Builder(
                            builder: (ctx) {
                              const path = 'assets/images/account/account.png';
                              return Image.asset(
                                path,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Colors.black26,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 45,
                      right: 0,
                      child: SizedBox(
                        width: 240,
                        child: Text(
                          'Mulai jelajahi ribuan produk dari Ekatunggal',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tombol MASUK & DAFTAR
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.pushNamed('login'),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pushNamed('register'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: AppColors.whiteColor,
                        ),
                        child: Text(
                          'DAFTAR',
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontWeight: FontWeight.w800,
                            color: primaryYellow,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Divider horizontal
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          // List "Lainnya"
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Text(
                  'Lainnya',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Tentang Ekatunggal
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 36,
                    height: 36,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Builder(
                        builder: (_) {
                          const asset = 'assets/images/account/logoETM.png';
                          return Image.asset(
                            asset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.info, size: 28),
                          );
                        },
                      ),
                    ),
                  ),
                  title: Text(
                    'Tentang Ekatunggal',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => context.pushNamed('about'), // route example
                ),

                const Divider(height: 1),

                // Tanya Vika
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 36,
                    height: 36,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Builder(
                        builder: (_) {
                          const asset = 'assets/images/account/tanyaVika.png';
                          return Image.asset(
                            asset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.chat, size: 28),
                          );
                        },
                      ),
                    ),
                  ),
                  title: Text(
                    'Tanya Vika',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // onTap: () => context.pushNamed('tanyaVika'), // route example
                ),

                const Divider(height: 1),

                // (Tambahkan item lain jika perlu)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
