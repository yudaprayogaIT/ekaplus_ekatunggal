import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/widgets/product_card.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

final GetIt myinjection = GetIt.instance;

class ProductsPage extends StatefulWidget {
  final bool hotDealsOnly;
  final String title;
  final String headerTitle;
  final String headerSubTitle;

  const ProductsPage({
    Key? key,
    this.hotDealsOnly = false,
    this.headerTitle = '',
    this.title = 'Products',
    this.headerSubTitle = 'Products',
  }) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late ProductBloc _bloc;
  List<Product> _allProducts = [];
  List<Product> _displayProducts = [];
  List<_CategoryItem> _categories = [];
  int? _selectedCategoryId;

  // 🔄 Fitur Load More: Variabel State
  late ScrollController _scrollController;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true; // Asumsikan ada data awal

  // ⚠️ PENTING: Tentukan ukuran halaman per request
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _bloc = myinjection<ProductBloc>();

    // 🔄 Fitur Load More: Inisialisasi ScrollController
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Dispatch initial event
    if (widget.hotDealsOnly) {
      _bloc.add(ProductEventGetHotDeals());
    } else {
      _bloc.add(ProductEventGetAllProducts(_currentPage));
    }
  }

  // 🔄 Fitur Load More: Scroll Listener
  void _onScroll() {
    // Pastikan ScrollController terpasang dan posisi sudah terdeteksi
    if (!_scrollController.hasClients) return;

    // Tambahkan buffer untuk memuat sebelum mencapai akhir (misal 85%)
    final triggerFetchMoreSize =
        _scrollController.position.maxScrollExtent * 0.85;

    if (_scrollController.position.pixels >= triggerFetchMoreSize &&
        !_isLoadingMore &&
        !widget.hotDealsOnly &&
        _hasMoreData && // ✅ PENTING: Hanya load jika masih ada data
        _selectedCategoryId == null) {
      _loadNextPage();
    }
  }

  // 🔄 Fitur Load More: Memuat Halaman Berikutnya
  void _loadNextPage() {
    // Agar tidak memicu berkali-kali
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });
    _currentPage++;
    _bloc.add(ProductEventGetAllProducts(_currentPage));
  }

  // [Kode _buildCategoriesFromProducts, _applyCategoryFilter, _onCategoryTap, _buildCategoryChips dihilangkan untuk fokus pada perbaikan]

  void _buildCategoriesFromProducts() {
    final Map<int, String> map = {};
    for (var p in _allProducts) {
      final cat = p.category;
      if (cat != null) map.putIfAbsent(cat.id, () => cat.name);
    }
    _categories = map.entries
        .map((e) => _CategoryItem(id: e.key, name: e.value))
        .toList();
  }

  void _applyCategoryFilter() {
    List<Product> results = List<Product>.from(_allProducts);

    // Filter dan sort berdasarkan tipe halaman
    if (widget.hotDealsOnly) {
      results = results.where((p) => p.isHotDeals == true).toList();
      results.sort((a, b) => a.id.compareTo(b.id));
    } else {
      results.sort((a, b) => b.id.compareTo(a.id));
    }

    // Apply category filter
    if (_selectedCategoryId != null) {
      results = results
          .where((p) => p.category?.id == _selectedCategoryId)
          .toList();
    }

    _displayProducts = results;
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
      _applyCategoryFilter();
    });
  }

  Widget _buildCategoryChips() {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 30,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final selected = _selectedCategoryId == null;
            return _CategoryChip(
              label: 'Semua',
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedCategoryId = null;
                  _applyCategoryFilter();
                });
              },
            );
          }
          final c = _categories[index - 1];
          final selected = _selectedCategoryId == c.id;
          return _CategoryChip(
            label: c.name,
            selected: selected,
            onTap: () => _onCategoryTap(c.id),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 🔄 Refresh Logic
  Future<void> _refresh() async {
    _currentPage = 1;
    _hasMoreData = true;
    _allProducts = [];
    // _selectedCategoryId = null; // opsional

    if (widget.hotDealsOnly) {
      _bloc.add(ProductEventGetHotDeals());
    } else {
      _bloc.add(ProductEventGetAllProducts(_currentPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: CustomAppBar(title: widget.title),
        body: SafeArea(
          child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductStateLoadedHotDeals) {
                setState(() {
                  _allProducts = state.hotDeals;
                  _hasMoreData =
                      false; // Hot Deals biasanya tidak berpagination
                  _buildCategoriesFromProducts();
                  _applyCategoryFilter();
                });
              } else if (state is ProductStateLoadedAllProduct) {
                setState(() {
                  // 🔄 Load More: Gabungkan data baru
                  if (_currentPage == 1) {
                    _allProducts = state.allProduct;
                  } else {
                    // Hanya tambahkan data baru jika belum ada
                    _allProducts.addAll(state.allProduct);
                  }

                  // ✅ PERBAIKAN PENTING: Logika Penghentian Load More
                  // Jika data yang diterima kurang dari _pageSize (20), anggap sudah habis
                  _hasMoreData = state.allProduct.length == _pageSize;

                  _isLoadingMore = false;

                  _buildCategoriesFromProducts();
                  _applyCategoryFilter();
                });
              }

              if (state is ProductStateError && _isLoadingMore) {
                setState(() {
                  _isLoadingMore = false;
                  _currentPage--; // Mundurkan halaman
                });
              }

              // Jika error terjadi di halaman 1, _isLoadingMore adalah false
              if (state is ProductStateError && _currentPage == 1) {
                // Tidak perlu setstate karena error sudah ditangani di builder
                // (kecuali Anda ingin menampilkan snackbar)
              }
            },
            builder: (context, state) {
              // ⚙️ Tampilkan Loading Awal (halaman 1)
              if ((state is ProductStateLoading ||
                      state is ProductStateEmpty) &&
                  _currentPage == 1) {
                return const Center(child: CircularProgressIndicator());
              }

              // 🚫 Tampilkan Error (halaman 1)
              if (state is ProductStateError &&
                  _currentPage == 1 &&
                  _allProducts.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Text('Gagal memuat produk: ${state.message}'),
                      ),
                    ],
                  ),
                );
              }

              // 🧱 Struktur UI
              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // sejajarkan ke kiri
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.headerTitle,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.headerSubTitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.grayColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildCategoryChips(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _displayProducts.isEmpty
                            ? Center(
                                key: ValueKey(
                                  _selectedCategoryId ?? 'empty_list',
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    'Belum ada produk untuk kriteria ini.',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                key: ValueKey(
                                  _selectedCategoryId ?? 'product_grid',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.72,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                  itemCount: _displayProducts.length,
                                  itemBuilder: (context, index) {
                                    final p = _displayProducts[index];
                                    return ProductCard(
                                      product: p,
                                      width: double.infinity,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductDetailPage(
                                              productId: p.id.toString(),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),

                    // 🔄 Load More: Tampilkan Loading Indikator HANYA JIKA _isLoadingMore=true DAN _hasMoreData=true
                    if (_isLoadingMore &&
                        _hasMoreData) // Cek _hasMoreData untuk mencegah loop loading tak berujung
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20, top: 10),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),

                    // 🚫 Tampilkan Teks 'Semua Produk Sudah Dimuat' HANYA JIKA _hasMoreData=false DAN daftar tidak kosong
                    if (!_hasMoreData &&
                        _allProducts.isNotEmpty &&
                        !widget.hotDealsOnly)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 40, top: 20),
                          child: Center(
                            child: Text('Semua produk sudah dimuat.'),
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final int id;
  final String name;
  _CategoryItem({required this.id, required this.name});
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

        decoration: BoxDecoration(
          color: selected ? AppColors.secondaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.black87,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
