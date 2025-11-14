import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/constant.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Tentang Ekatunggal'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner / gambar besar
            SizedBox(
              width: double.infinity,
              height: 316,
              child: Builder(
                builder: (_) {
                  const asset = 'assets/images/account/about.png';
                  return Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        size: 72,
                        color: Colors.black26,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Konten
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title merah
                  Text(
                    'EKATUNGGAL',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      color: AppColors.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Paragraph ringkasan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TEKS (rata kiri-kanan)
                      Expanded(
                        child: Text(
                          'Perusahaan distributor bahan baku material springbed dan sofa dan furniture. '
                          'Didirikan oleh Alm. Bapak Gapo Suseno pada tahun 1997. Ekatunggal berkomitmen untuk menghadirkan produk dan layanan berkualitas tinggi yang memenuhi kebutuhan masyarakat Indonesia.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: AppFonts.secondaryFont,
                            fontSize: 14,
                            color: Color(0xFF667085),
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // GARIS KUNING
                      Container(
                        width: 4,
                        height: 100,
                        color: AppColors.secondaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Subheading center bold
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'LEBIH DARI 2 DEKADE BERDIRI',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Paragraph panjang
                  Text(
                    'Ekatunggal terus berinovasi untuk memberikan solusi terbaik bagi pelanggan, sekaligus membangun hubungan jangka panjang berdasarkan kepercayaan, integritas, dan profesionalisme. Didukung oleh tim yang berpengalaman dan jaringan yang luas, Ekatunggal siap menjadi mitra terpercaya untuk masa depan yang lebih baik.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: AppFonts.secondaryFont,
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
