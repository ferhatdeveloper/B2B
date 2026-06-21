import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/b2b_service.dart';

class AppState extends ChangeNotifier {
  AppState({B2bService? service}) : _service = service ?? B2bService();

  static const _sessionKey = 'zen_b2b_session';

  final B2bService _service;
  B2bService get service => _service;

  SessionUser? _user;
  SessionUser? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Restores a persisted session (so a full-page Stripe redirect returns the
  /// user logged in). Safe to call once at startup.
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_sessionKey);
      if (raw != null) {
        _user = SessionUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {
      // Ignore restore failures (e.g. unsupported platform); stay logged out.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user == null) {
        await prefs.remove(_sessionKey);
      } else {
        await prefs.setString(_sessionKey, jsonEncode(_user!.toJson()));
      }
    } catch (_) {
      // Persistence is best-effort.
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
    notifyListeners();
    await _persist();
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
