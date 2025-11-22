// lib/features/wishlist/presentation/widgets/wishlist_list_view.dart
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/product/presentation/bloc/product_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishlistListView extends StatefulWidget {
  final String userId;
  final List<dynamic> wishlistItems;

  const WishlistListView({
    Key? key,
    required this.userId,
    required this.wishlistItems,
  }) : super(key: key);

  @override
  State<WishlistListView> createState() => _WishlistListViewState();
}

class _WishlistListViewState extends State<WishlistListView> {
  // 🔥 Selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};

  // 🔥 Pagination state
  static const int _itemsPerPage = 10;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  // 🔥 Scroll controller
  late ScrollController _scrollController;

  int get _totalPages => (widget.wishlistItems.length / _itemsPerPage).ceil();

  List<dynamic> get _displayedItems {
    final endIndex = (_currentPage * _itemsPerPage).clamp(
      0,
      widget.wishlistItems.length,
    );
    return widget.wishlistItems.sublist(0, endIndex);
  }

  bool get _hasMoreItems => _currentPage < _totalPages;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreItems) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulasi delay loading (opsional, bisa dihapus)
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is! ProductLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final products = productState.products;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Header dengan tombol Pilih/Batal
            _buildHeader(),

            // 🔥 Bulk action bar (muncul saat selection mode)
            if (_isSelectionMode) _buildBulkActionBar(),

            // 🔥 List items
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _displayedItems.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  // 🔥 Loading indicator di bawah
                  if (index == _displayedItems.length && _isLoadingMore) {
                    return _buildLoadingIndicator();
                  }

                  final wishlistItem = _displayedItems[index];

                  try {
                    final product = products.firstWhere(
                      (p) => p.id.toString() == wishlistItem.productId,
                    );

                    return WishlistItemCard(
                      userId: widget.userId,
                      productId: product.id.toString(),
                      productName: product.name,
                      imagePath: _getProductImage(product),
                      isSelectionMode: _isSelectionMode,
                      isSelected: _selectedItems.contains(
                        product.id.toString(),
                      ),
                      onSelectionChanged: (isSelected) {
                        _toggleSelection(product.id.toString(), isSelected);
                      },
                    );
                  } catch (e) {
                    return WishlistItemCard(
                      userId: widget.userId,
                      productId: wishlistItem.productId,
                      productName: 'Product ID: ${wishlistItem.productId}',
                      imagePath: '',
                      isSelectionMode: _isSelectionMode,
                      isSelected: _selectedItems.contains(
                        wishlistItem.productId,
                      ),
                      onSelectionChanged: (isSelected) {
                        _toggleSelection(wishlistItem.productId, isSelected);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isSelectionMode ? '${_selectedItems.length} dipilih' : '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.primaryFont,
              color: Colors.grey[700],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (_isSelectionMode) {
                  // Keluar dari selection mode
                  _isSelectionMode = false;
                  _selectedItems.clear();
                } else {
                  // Masuk selection mode
                  _isSelectionMode = true;
                }
              });
            },
            child: Text(
              _isSelectionMode ? 'Batal' : 'Pilih',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.primaryFont,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Checkbox untuk pilih semua
          Checkbox(
            value: _selectedItems.length == widget.wishlistItems.length,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  // Pilih semua
                  _selectedItems.clear();
                  for (var item in widget.wishlistItems) {
                    _selectedItems.add(item.productId);
                  }
                } else {
                  // Hapus semua pilihan
                  _selectedItems.clear();
                }
              });
            },
            activeColor: AppColors.primaryColor,
          ),
          const Text(
            'Pilih Semua',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
          const Spacer(),
          // Tombol hapus
          ElevatedButton.icon(
            onPressed: _selectedItems.isEmpty
                ? null
                : () => _showBulkDeleteConfirmation(),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.whiteColor,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String productId, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(productId);
      } else {
        _selectedItems.remove(productId);
      }
    });
  }

  void _showBulkDeleteConfirmation() {
    final selectedCount = _selectedItems.length;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Hapus ${_selectedItems.length} Item?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: AppFonts.primaryFont,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin ingin menghapus item yang dipilih dari wishlist?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.primaryFont,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final itemsToDelete = _selectedItems.toList();

                        context.read<WishlistBloc>().add(
                          BulkDeleteWishlistItems(
                            userId: widget.userId,
                            productIds: itemsToDelete,
                          ),
                        );

                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$selectedCount item dihapus dari wishlist',
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Reset selection state SETELAH snackbar
                        setState(() {
                          _isSelectionMode = false;
                          _selectedItems.clear();
                          _currentPage = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProductImage(dynamic product) {
    try {
      if (product.variants != null && product.variants.isNotEmpty) {
        final variant = product.variants.first;
        final raw = (variant as dynamic).image ?? '';
        if (raw is String && raw.isNotEmpty) {
          return raw.replaceFirst(RegExp(r'^/+'), 'assets/');
        }
      }
    } catch (e) {
      print('⚠️ Error getting product image: $e');
    }
    return '';
  }
}