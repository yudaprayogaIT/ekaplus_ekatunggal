// lib/features/wishlist/presentation/bloc/wishlist_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/check_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/get_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/bulk_delete_wishlist.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlist getWishlist;
  final ToggleWishlist toggleWishlist;
  final CheckWishlist checkWishlist;
  final BulkDeleteWishlist bulkDeleteWishlist;

  WishlistBloc({
    required this.getWishlist,
    required this.toggleWishlist,
    required this.checkWishlist,
    required this.bulkDeleteWishlist,
  }) : super(WishlistInitial()) {
    on<LoadWishlist>(_onLoadWishlist);
    on<ToggleWishlistItem>(_onToggleWishlistItem);
    on<CheckWishlistStatus>(_onCheckWishlistStatus);
    on<BulkDeleteWishlistItems>(_onBulkDeleteWishlistItems);
  }

  Future<void> _onLoadWishlist(
    LoadWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());

    final result = await getWishlist(event.userId);

    result.fold(
      (failure) => emit(WishlistError(failure.message ?? '')),
      (items) {
        final statusMap = <String, bool>{};
        for (var item in items) {
          statusMap[item.productId] = true;
        }
        emit(WishlistLoaded(items: items, statusMap: statusMap));
      },
    );
  }

  Future<void> _onToggleWishlistItem(
    ToggleWishlistItem event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;

    final result = await toggleWishlist(event.userId, event.productId);

    result.fold(
      (failure) => emit(WishlistError(failure.message ?? '')),
      (isInWishlist) {
        if (currentState is WishlistLoaded) {
          final newStatusMap = Map<String, bool>.from(currentState.statusMap);
          newStatusMap[event.productId] = isInWishlist;
          emit(currentState.copyWith(statusMap: newStatusMap));
        }

        emit(WishlistToggled(
          isInWishlist: isInWishlist,
          productId: event.productId,
        ));

        add(LoadWishlist(event.userId));
      },
    );
  }

  Future<void> _onCheckWishlistStatus(
    CheckWishlistStatus event,
    Emitter<WishlistState> emit,
  ) async {
    final result = await checkWishlist(event.userId, event.productId);

    result.fold(
      (failure) {
        print('⚠️ Error checking wishlist status: ${failure.message}');
      },
      (isInWishlist) {
        final currentState = state;
        if (currentState is WishlistLoaded) {
          final newStatusMap = Map<String, bool>.from(currentState.statusMap);
          newStatusMap[event.productId] = isInWishlist;
          emit(currentState.copyWith(statusMap: newStatusMap));
        }
      },
    );
  }

  Future<void> _onBulkDeleteWishlistItems(
    BulkDeleteWishlistItems event,
    Emitter<WishlistState> emit,
  ) async {
    // Validasi: jika tidak ada item yang dipilih
    if (event.productIds.isEmpty) {
      emit(const WishlistError('Tidak ada item yang dipilih'));
      return;
    }

    emit(WishlistLoading());

    final result = await bulkDeleteWishlist(event.userId, event.productIds);

    result.fold(
      (failure) {
        emit(WishlistError(failure.message ?? 'Gagal menghapus item'));
      },
      (deletedCount) {
        print('✅ Successfully deleted $deletedCount items');
        
        // Reload wishlist
        add(LoadWishlist(event.userId));
      },
    );
  }
}