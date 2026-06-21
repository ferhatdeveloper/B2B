import '../entities/order_draft.dart';

abstract interface class OrderRepository {
  Future<String> createOrder(OrderDraft draft);
}
