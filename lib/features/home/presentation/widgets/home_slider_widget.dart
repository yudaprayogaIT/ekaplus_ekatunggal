// lib/features/home/presentation/widgets/home_slider_widget.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class HomeSliderWidget extends StatelessWidget {
  final List<BannerSlider> banners;
  /// kalau false -> banner tidak merespon klik (mis. guest / loggedIn)
  final bool enableTap;

  const HomeSliderWidget({
    super.key,
    required this.banners,
    this.enableTap = true,
  });

  Future<void> _openLink(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // fallback: coba launch anyway
        await launchUrl(uri);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka link')),
      );
    }
  }

  void _onBannerTap(BuildContext context, BannerSlider banner) {
    if (!enableTap) return;

    if (banner.redirect != true) return;

    final type = banner.redirectType?.trim() ?? '';
    if (type == 'Link') {
      final link = banner.link?.trim() ?? '';
      if (link.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link tidak tersedia')),
        );
        return;
      }
      _openLink(context, link);
    } else if (type == 'Page') {
      final pageName = banner.pages?.trim() ?? '';
      if (pageName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman tujuan tidak tersedia')),
        );
        return;
      }
      // gunakan go_router; pastikan nama route terdaftar
      // contoh: context.pushNamed('promoDetail', params: {'id': '...'})
      try {
        context.pushNamed(pageName);
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Gagal navigasi ke halaman $pageName')),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = banners.where((b) => b.disabled == false).toList();

    if (visible.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          // borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Icon(Icons.image, size: 60, color: Colors.grey)),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 700),
        autoPlayCurve: Curves.easeInOut,
        // enlargeCenterPage: true,
        // aspectRatio: 16 / 6,
        // viewportFraction: 0.95,
        enlargeCenterPage: false,
        viewportFraction: 1,
      ),
      items: visible.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            final img = banner.img.trim();
            Widget imgWidget;

            if (img.startsWith('assets/')) {
              imgWidget = Image.asset(
                img,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              );
            } else {
              // treat as network url (or filename — adapt later)
              final src = img.startsWith('http') ? img : img;
              imgWidget = Image.network(
                src,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              );
            }

            return ClipRRect(
              // borderRadius: BorderRadius.circular(10.0),
              child: InkWell(
                onTap: () => _onBannerTap(context, banner),
                // jika tidak boleh diklik, InkWell tetap dipasang tapi onTap noop
                child: Stack(
                  children: [
                    SizedBox(width: double.infinity, child: imgWidget),
                    // Optional: overlay gradient agar teks terlihat jika nanti pakai caption
                    Positioned.fill(
                      child: IgnorePointer(
                        // ignore pointer supaya overlay tidak menangkap tap
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withOpacity(0.06)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // jika klik disabled, tampilkan indikator (opsional)
                    if (!enableTap)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Tamu', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
