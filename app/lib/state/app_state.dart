import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/b2b_service.dart';
import '../utils/session_store.dart';

class AppState extends ChangeNotifier {
  AppState({B2bService? service}) : _service = service ?? B2bService() {
    _restore();
  }

  final B2bService _service;
  B2bService get service => _service;

  SessionUser? _user;
  SessionUser? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Restores a persisted session synchronously from localStorage (web) so a
  /// full-page Stripe redirect returns the user logged in.
  void _restore() {
    try {
      final raw = readSession();
      if (raw != null && raw.isNotEmpty) {
        _user = SessionUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // Stay logged out on any restore failure.
    }
  }

  void _persist() {
    if (_user == null) {
      clearSession();
    } else {
      writeSession(jsonEncode(_user!.toJson()));
    }
  }

  final List<CartLine> _cart = [];
  List<CartLine> get cart => List.unmodifiable(_cart);

  int get cartCount => _cart.fold(0, (sum, l) => sum + l.qty);
  double get cartSubtotal => _cart.fold(0.0, (sum, l) => sum + l.gross);
  double get cartTax => _cart.fold(0.0, (sum, l) => sum + l.tax);
  double get cartGrandTotal => _cart.fold(0.0, (sum, l) => sum + l.total);

  Future<bool> login(String username, String password) async {
    final user = await _service.login(username, password);
    if (user == null) return false;
    _user = user;
    _persist();
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    _cart.clear();
    notifyListeners();
    _persist();
  }

  void addToCart(Product product, {int qty = 1}) {
    final existing = _cart.where((l) => l.product.id == product.id).toList();
    if (existing.isNotEmpty) {
      existing.first.qty += qty;
    } else {
      _cart.add(CartLine(product: product, qty: qty));
    }
    notifyListeners();
  }

  void setQty(String productId, int qty) {
    final line = _cart.where((l) => l.product.id == productId).toList();
    if (line.isEmpty) return;
    if (qty <= 0) {
      _cart.removeWhere((l) => l.product.id == productId);
    } else {
      line.first.qty = qty;
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((l) => l.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<String> checkout({String? note}) async {
    final user = _user;
    if (user == null || user.customerId == null) {
      throw Exception('Oturum/cari bilgisi yok.');
    }
    if (_cart.isEmpty) throw Exception('Sepet boş.');
    final orderNo = await _service.createOrder(
      customerId: user.customerId!,
      lines: List.of(_cart),
      note: note,
    );
    _cart.clear();
    notifyListeners();
    return orderNo;
  }
}
