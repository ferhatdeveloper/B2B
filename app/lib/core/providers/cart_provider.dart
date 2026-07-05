import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../../services/b2b_service.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(CartNotifier.new);

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, line) => sum + line.qty);
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, line) => sum + line.gross);
});

final cartTaxProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, line) => sum + line.tax);
});

final cartGrandTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, line) => sum + line.total);
});

class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => [];

  B2bService get _service => ref.read(b2bServiceProvider);

  void addToCart(Product product, {int qty = 1}) {
    final cart = [...state];
    final index = cart.indexWhere((line) => line.product.id == product.id);
    if (index >= 0) {
      cart[index].qty += qty;
    } else {
      cart.add(CartLine(product: product, qty: qty));
    }
    state = cart;
  }

  void setQty(String productId, int qty) {
    if (qty <= 0) {
      state = state.where((line) => line.product.id != productId).toList();
      return;
    }
    state = [
      for (final line in state)
        if (line.product.id == productId) CartLine(product: line.product, qty: qty) else line,
    ];
  }

  void removeFromCart(String productId) {
    state = state.where((line) => line.product.id != productId).toList();
  }

  void clear() => state = [];

  Future<String> checkout({String? note}) async {
    final user = ref.read(authProvider);
    if (user == null || user.customerId == null) {
      throw Exception('Oturum/cari bilgisi yok.');
    }
    if (state.isEmpty) throw Exception('Sepet boş.');
    final orderNo = await _service.createOrder(
      customerId: user.customerId!,
      lines: List.of(state),
      note: note,
    );
    clear();
    return orderNo;
  }

  Future<String> checkoutGuest({required String name, required String email}) async {
    if (state.isEmpty) throw Exception('Sepet boş.');
    final retailId = await _service.retailCustomerId();
    if (retailId == null) throw Exception('Perakende cari bulunamadı.');
    final orderNo = await _service.createOrder(
      customerId: retailId,
      lines: List.of(state),
      channel: 'storefront',
      buyerName: name,
      buyerEmail: email,
      note: 'Misafir sipariş · $name <$email>',
    );
    clear();
    return orderNo;
  }
}
