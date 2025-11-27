import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/cubit/auth_session_state.dart';
import 'package:ekaplus_ekatunggal/features/home/presentation/widgets/home_slider_widget.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/products_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/profile_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/typeCategory_list.dart';
import '../../../banner/domain/entities/bannerslider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
          builder: (context, authState) {
            final bool isLoggedIn = authState is AuthSessionAuthenticated;
            final bool isMember =
                authState is AuthSessionAuthenticated &&
                authState.status == UserStatus.member;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header profil
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  child: const ProfileHeader(),
                ),

                // Konten utama
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner + overlay searchbar
                        SizedBox(
                          height: 240,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: HomeSliderWidget(
                                  banners: banners,
                                  enableTap: isLoggedIn,
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: -2,
                                child: Column(
                                  children: const [
                                    HomeSearchBar(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Type Categories
                        TypeCategoryList(),

                        Container(
                          height: 10,
                          color: const Color.fromARGB(255, 233, 233, 233),
                        ),

                        // 🔥 ProductsSection uses GLOBAL ProductBloc (Singleton)
                        ProductsSection(
                          title: 'Yang Baru Dari Kami 🔥',
                          subtitle: 'Yang baru - baru, dijamin menarik !!!',
                          hotDealsOnly: false,
                          showCount: 6,
                          isLoggedIn: isLoggedIn,
                        ),

                        Container(
                          height: 10,
                          color: const Color.fromARGB(255, 233, 233, 233),
                        ),

                        ProductsSection(
                          title: 'Jangan Kehabisan Produk Terlaris 🤩',
                          subtitle: 'Siapa cepat, dia dapat, sikaaat ...',
                          hotDealsOnly: true,
                          showCount: 6,
                          isLoggedIn: isLoggedIn,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}