// lib/features/search/presentation/pages/search_page.dart
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/search/presentation/bloc/search_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const SearchEventInitial());

    _searchController.addListener(() {
      setState(() {}); // supaya suffixIcon update
    });

    // Auto focus pada search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<SearchBloc>().add(SearchEventQueryChanged(query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchEventClearQuery());
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withOpacity(0.05),
              //       blurRadius: 4,
              //       offset: const Offset(0, 2),
              //     ),
              //   ],
              // ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.arrowLeft,
                      size: 20,
                      color: AppColors.grayColor,
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),

                  // Search TextField
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color.fromARGB(28, 0, 0, 0),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 15,
                            spreadRadius: -3,
                            offset: Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 6,
                            spreadRadius: -2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Cari produk',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.grayColor,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 14,
                            color: AppColors.grayColor,
                            fontWeight: FontWeight.w500,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 20,
                                    color: AppColors.grayColor,
                                  ),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SearchStateError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SearchStateInitial) {
                    return _buildInitialContent(state);
                  }

                  if (state is SearchStateLoaded) {
                    return _buildSearchResults(state);
                  }

                  if (state is SearchStateEmpty) {
                    return _buildEmptyState(state.query);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialContent(SearchStateInitial state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hot Deals Section
          if (state.hotDeals.isNotEmpty) ...[
            Text(
              'Produk paling dicari',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.hotDeals.map((product) {
                return _buildHotDealChip(product.name);
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Categories Section
          if (state.categories.isNotEmpty) ...[
            Text(
              'Eksplore dari produk yang tersedia',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.83,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: state.categories.length > 9
                  ? 9
                  : state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return _buildCategoryItem(category);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHotDealChip(String text) {
    return InkWell(
      onTap: () {
        _searchController.text = text;
        _onSearchChanged(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(category) {
    return InkWell(
      onTap: () {
        // Navigate to product page with category filter
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(),
            settings: RouteSettings(arguments: category),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            // ClipRRect agar isi (gambar) ikut membulatkan sudut
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildCategoryIcon(category),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(category) {
    final String? iconPath = category.icon;

    if (iconPath == null || iconPath.isEmpty) {
      // Tampilan fallback (ikon) tetap berada di tengah dan memenuhi kotak
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: const Icon(Icons.category, size: 32, color: Colors.black54),
      );
    }

    // Network image -> pakai CachedNetworkImage dengan BoxFit.cover
    if (iconPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: iconPath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const SizedBox(
          width: 24,
          height: 24,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image, size: 32, color: Colors.black54),
      );
    }

    if (!iconPath.toLowerCase().endsWith('.svg')) {
      return Image.asset(
        iconPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.category, size: 32, color: Colors.black54),
      );
    }

    return const Icon(Icons.image, size: 80, color: Colors.black54);
  }

  Widget _buildSearchResults(SearchStateLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Ditemukan ${state.results.length} produk',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final product = state.results[index];
              return ProductCard(
                product: product,
                onTap: () {
                  context.pushNamed(
                    'productDetail',
                    pathParameters: {'id': product.id.toString()},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil untuk "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci lain atau eksplore kategori di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
