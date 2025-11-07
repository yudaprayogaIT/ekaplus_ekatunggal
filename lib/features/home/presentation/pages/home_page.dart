import 'package:ekaplus_ekatunggal/features/home/presentation/widgets/home_slider_widget.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/section_with_product.dart';
import 'package:flutter/material.dart';
import '../../../../core/shared_widgets/profile_header.dart';
// import '../../../../core/shared_widgets/bottom_nav.dart'; // tidak dipakai di sini, tapi tetap disertakan untuk struktur
import '../widgets/search_bar.dart';
import '../widgets/location_card.dart';
import '../widgets/typeCategory_list.dart';
import '../../../banner/domain/entities/bannerslider.dart';
// import 'package:ekaplus_ekatunggal/features/type/presentation/widgets/type_category_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMember = true;

    final List<BannerSlider> banners = [
      BannerSlider(
        name: 'Banner ',
        img: 'assets/images/banner/banner.png',
        redirect: true,
        redirectType: 'Page',
        pages: 'promoDetail',
        link: null,
        disabled: false,
      ),
      BannerSlider(
        name: 'Banner 1',
        img: 'assets/images/banner/banner1.png',
        redirect: true,
        redirectType: 'Page',
        pages: 'promoDetail',
        link: null,
        disabled: false,
      ),
      BannerSlider(
        name: 'Banner 2',
        img: 'assets/images/banner/banner2.png',
        redirect: false,
        redirectType: 'Link',
        pages: null,
        link: 'https://example.com/promo-123',
        disabled: false,
      ),
      BannerSlider(
        name: 'Banner 3',
        img: 'assets/images/banner/banner3.png',
        redirect: false,
        disabled: false,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header profil
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: ProfileHeader(name: isMember ? 'Development' : null),
            ),

            // Konten utama
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------
                    // Bagian banner + overlay searchbar
                    // -------------------------
                    // Gunakan SizedBox dengan tinggi yang sesuai banner/slider-mu.
                    // Sesuaikan height dan bottom untuk menyesuaikan tampilan.
                    SizedBox(
                      height: 240, // sesuaikan tinggi banner jika diperlukan
                      child: Stack(
                        clipBehavior:
                            Clip.none, // biarkan child yang overflow terlihat
                        children: [
                          // Layer banner/slider (mengisi seluruh area)
                          Positioned.fill(
                            child: HomeSliderWidget(
                              banners: banners,
                              enableTap: isMember,
                            ),
                          ),

                          // Layer overlay: searchbar dan location card
                          // bottom negatif agar "melayang" keluar dari batas banner
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom:
                                -78, // atur nilai ini (negatif) untuk efek menonjol
                            child: Column(
                              children: const [
                                HomeSearchBar(),
                                SizedBox(height: 8),
                                LocationCard(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Beri ruang kompensasi agar konten selanjutnya tidak tertutup oleh overlay
                    const SizedBox(height: 85),

                    // -------------------------
                    // Sisa konten halaman
                    // -------------------------
                    // const SizedBox(height: 10),
                    TypeCategoryList(),
                    SectionWithProducts(title: 'Yang Baru Dari Kami 🔥'),
                    SectionWithProducts(title: 'Jangan Kehabisan Produk Terlaris 🤩'),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
