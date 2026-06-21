import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amount = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Geçerli bir tutar girin.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final app = context.read<AppState>();
      final url = await app.service.startPayment(customerId: app.user!.customerId!, amount: amount);
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault, webOnlyWindowName: '_blank');
      if (!ok) throw Exception('Ödeme sayfası açılamadı.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ödeme sayfası açıldı. İşlem sonrası "Ödemelerim"den kontrol edebilirsiniz.')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppState>().user!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lock, color: AppColors.accent),
                      SizedBox(width: 10),
                      Text('Güvenli Ödeme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Stripe ile kredi kartı ödemesi yapabilirsiniz.',
                      style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Text('Güncel Bakiye', style: TextStyle(color: AppColors.textMuted)),
                        const Spacer(),
                        Text(money(user.balance), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Ödenecek tutar (₺)',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _pay,
                      icon: _loading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.credit_card),
                      label: Text(_loading ? 'Yönlendiriliyor…' : 'Ödemeye Geç'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ödeme, güvenli Stripe sayfasında tamamlanır.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}