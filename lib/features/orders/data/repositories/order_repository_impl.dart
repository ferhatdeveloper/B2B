import '../../../../core/network/postgrest_client.dart';
import '../../domain/entities/order_draft.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._client);

  final PostgrestClient _client;

  @override
  Future<String> createOrder(OrderDraft draft) async {
    final customerId = draft.customerId;
    if (customerId == null || customerId.isEmpty) {
      throw Exception('Siparis icin musteri oturumu gerekli.');
    }
    if (draft.lines.isEmpty) {
      throw Exception('Siparis satiri bos olamaz.');
    }

    final orderNo = 'WEB-${DateTime.now().millisecondsSinceEpoch}';
    final rows = await _client.post('/orders', {
      'order_no': orderNo,
      'customer_id': customerId,
      'status': 'open',
      'subtotal': draft.subtotal,
      'discount_total': 0,
      'tax_total': draft.taxTotal,
      'grand_total': draft.grandTotal,
      'note': draft.note,
    });

    final orderId = rows.first['id'] as String?;
    if (orderId == null) throw Exception('Siparis olusturulamadi.');

    await _client.post(
      '/order_lines',
      draft.lines.map((line) => line.toPostgrest(orderId)).toList(),
      prefer: 'return=minimal',
    );

    return orderId;
  }
}
