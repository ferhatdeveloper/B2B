import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_draft.dart';
import '../../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(postgrestClientProvider));
});

class OrderDraftNotifier extends Notifier<OrderDraft> {
  @override
  OrderDraft build() {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    return OrderDraft(customerId: user?.customerId);
  }

  void addProduct(Product product) {
    final lines = [...state.lines];
    final index = lines.indexWhere((line) => line.product.id == product.id);
    if (index >= 0) {
      lines[index] = lines[index].copyWith(quantity: lines[index].quantity + 1);
    } else {
      lines.add(OrderDraftLine(product: product, quantity: 1));
    }
    state = state.copyWith(lines: lines);
  }

  void removeProduct(Product product) {
    state = state.copyWith(
      lines: state.lines.where((line) => line.product.id != product.id).toList(),
    );
  }

  void clear() {
    state = OrderDraft(customerId: state.customerId);
  }
}

final orderDraftProvider =
    NotifierProvider<OrderDraftNotifier, OrderDraft>(OrderDraftNotifier.new);

class SubmitOrderNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> submit() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final orderId = await ref.read(orderRepositoryProvider).createOrder(
            ref.read(orderDraftProvider),
          );
      ref.read(orderDraftProvider.notifier).clear();
      return orderId;
    });
  }
}

final submitOrderProvider =
    AsyncNotifierProvider<SubmitOrderNotifier, String?>(SubmitOrderNotifier.new);
