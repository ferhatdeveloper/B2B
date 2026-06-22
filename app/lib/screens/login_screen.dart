import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController(text: 'demo');
  final _password = TextEditingController(text: '1234');
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await context.read<AppState>().login(_username.text.trim(), _password.text);
      if (!ok && mounted) {
        setState(() => _error = 'Kullanıcı adı veya parola hatalı.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Bağlantı hatası: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          if (!wide) {
            return SafeArea(child: _buildForm(compactBrand: true));
          }
          return Row(
            children: [
              Expanded(flex: 5, child: _buildBrand()),
              Expanded(flex: 4, child: _buildForm()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.storefront, color: Colors.white, size: 34),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text('EXFIN B2B',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Bayi & pazaryeri portalı',
                style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, height: 1.1),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ürün kataloğu, hızlı sipariş, kampanyalar ve cari takibi tek modern uygulamada.',
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _Feature(icon: Icons.bolt, label: 'Hızlı sipariş'),
                  _Feature(icon: Icons.local_offer, label: 'Kampanyalar'),
                  _Feature(icon: Icons.account_balance_wallet, label: 'Cari takip'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm({bool compactBrand = false}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (compactBrand) ...[
                Row(
                  children: const [
                    Icon(Icons.storefront, color: AppColors.brand, size: 30),
                    SizedBox(width: 10),
                    Text('EXFIN B2B', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              if (context.read<AppState>().appMode == AppMode.storefront)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextButton.icon(
                    onPressed: () => context.read<AppState>().backToStorefront(),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Mağazaya dön'),
                  ),
                ),
              const Text('Bayi Girişi',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Bayi paneline devam etmek için giriş yapın', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 28),
              TextField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı adı',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _password,
                obscureText: _obscure,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Parola',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Giriş Yap'),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Demo: demo / 1234',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
