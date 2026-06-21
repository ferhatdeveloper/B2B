import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/product.dart';

class OrderDraftLine extends Equatable {
  const OrderDraftLine({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final double quantity;

  double get grossTotal => product.price * quantity;
  double get taxTotal => grossTotal * (product.taxRate / 100);
  double get grandTotal => grossTotal + taxTotal;

  OrderDraftLine copyWith({double? quantity}) {
    return OrderDraftLine(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, Object?> toPostgrest(String orderId) {
    return {
      'order_id': orderId,
      'product_id': product.id,
      'sku': product.sku,
      'product_name': product.name,
      'qty': quantity,
      'unit_price': product.price,
      'discount_pct': 0,
      'tax_rate': product.taxRate,
      'line_total': grandTotal,
    };
  }

  @override
  List<Object?> get props => [product.id, quantity];
}

class OrderDraft extends Equatable {
  const OrderDraft({
    this.customerId,
    this.lines = const [],
    this.note,
  });

  final String? customerId;
  final List<OrderDraftLine> lines;
  final String? note;

  double get subtotal => lines.fold(0, (sum, line) => sum + line.grossTotal);
  double get taxTotal => lines.fold(0, (sum, line) => sum + line.taxTotal);
  double get grandTotal => lines.fold(0, (sum, line) => sum + line.grandTotal);

  OrderDraft copyWith({
    String? customerId,
    List<OrderDraftLine>? lines,
    String? note,
  }) {
    return OrderDraft(
      customerId: customerId ?? this.customerId,
      lines: lines ?? this.lines,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [customerId, lines, note];
}
