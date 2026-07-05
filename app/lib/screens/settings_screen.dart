import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/app_providers.dart';
import '../storefront/widgets/store_theme_picker.dart';
import '../theme.dart';

/// Ayarlar — configure the Logo Object REST Service connection (and view other
/// integration settings) from inside the app. Secrets are stored server-side
/// and only their presence is reported back to the client.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _baseUrl = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _clientId = TextEditingController();
  final _clientSecret = TextEditingController();
  final _firmNo = TextEditingController();
  final _periodNo = TextEditingController();
  bool _useClientCreds = false;

  Map<String, dynamic>? _settings;
  bool _loading = true;
  bool _busy = false;
  String? _message;
  bool _messageOk = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_baseUrl, _username, _password, _clientId, _clientSecret, _firmNo, _periodNo]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await ref.read(b2bServiceProvider).getSettings();
      final logo = (s['logo'] as Map?) ?? {};
      _baseUrl.text = logo['baseUrl']?.toString() ?? '';
      _username.text = logo['username']?.toString() ?? '';
      _firmNo.text = (logo['firmNo'] ?? 1).toString();
      _periodNo.text = (logo['periodNo'] ?? 1).toString();
      _useClientCreds = logo['hasClientId'] == true;
      if (mounted) setState(() => _settings = s);
    } catch (e) {
      if (mounted) setState(() => _setMessage('Ayarlar yüklenemedi: $e', false));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setMessage(String m, bool ok) {
    _message = m;
    _messageOk = ok;
  }

  Map<String, dynamic> _payload() {
    final body = <String, dynamic>{
      'baseUrl': _baseUrl.text.trim(),
      'firmNo': int.tryParse(_firmNo.text.trim()) ?? 1,
      'periodNo': int.tryParse(_periodNo.text.trim()) ?? 1,
    };
    if (_useClientCreds) {
      if (_clientId.text.trim().isNotEmpty) body['clientId'] = _clientId.text.trim();
      if (_clientSecret.text.trim().isNotEmpty) body['clientSecret'] = _clientSecret.text.trim();
    } else {
      if (_username.text.trim().isNotEmpty) body['username'] = _username.text.trim();
      if (_password.text.trim().isNotEmpty) body['password'] = _password.text.trim();
    }
    return body;
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final s = await ref.read(b2bServiceProvider).saveLogoSettings(_payload());
      if (mounted) {
        setState(() {
          _settings = s;
          _setMessage('Ayarlar kaydedildi.', true);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _setMessage('$e', false));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _test() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final svc = ref.read(b2bServiceProvider);
    try {
      await svc.saveLogoSettings(_payload());
      final r = await svc.testLogo();
      if (mounted) setState(() => _setMessage('Bağlantı başarılı (${r['mode']}) · ${r['itemCount']} ürün bulundu.', true));
    } catch (e) {
      if (mounted) setState(() => _setMessage('Bağlantı başarısız: $e', false));
    } finally {
      if (mounted) {
        await _load();
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _sync() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final r = await ref.read(b2bServiceProvider).syncLogo();
      if (mounted) setState(() => _setMessage('Senkron tamam (${r['mode']}): ${r['products']} ürün, ${r['customers']} cari.', true));
    } catch (e) {
      if (mounted) setState(() => _setMessage('Senkron başarısız: $e', false));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final logo = (_settings?['logo'] as Map?) ?? {};
    final mode = logo['mode']?.toString() ?? 'mock';
    final stripeMode = ((_settings?['stripe'] as Map?)?['mode'])?.toString() ?? 'mock';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBanner(logoMode: mode, stripeMode: stripeMode),
              const SizedBox(height: 16),
              _AppearanceCard(),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.dns_outlined, color: AppColors.brand),
                          SizedBox(width: 10),
                          Text('Logo REST API Bağlantısı', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Boş bırakılırsa dahili mock Logo servisi kullanılır.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _baseUrl,
                        decoration: const InputDecoration(
                          labelText: 'LRS Taban URL',
                          hintText: 'http://sunucu:32001',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: false, label: Text('Kullanıcı / Parola'), icon: Icon(Icons.person)),
                          ButtonSegment(value: true, label: Text('ClientId / Secret'), icon: Icon(Icons.vpn_key)),
                        ],
                        selected: {_useClientCreds},
                        onSelectionChanged: (s) => setState(() => _useClientCreds = s.first),
                      ),
                      const SizedBox(height: 14),
                      if (_useClientCreds) ...[
                        TextField(controller: _clientId, decoration: const InputDecoration(labelText: 'Client Id', prefixIcon: Icon(Icons.badge_outlined))),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _clientSecret,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Client Secret',
                            prefixIcon: const Icon(Icons.lock_outline),
                            helperText: logo['hasClientSecret'] == true ? 'Kayıtlı (değiştirmek için yeni değer girin)' : null,
                          ),
                        ),
                      ] else ...[
                        TextField(controller: _username, decoration: const InputDecoration(labelText: 'Kullanıcı adı', prefixIcon: Icon(Icons.person_outline))),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Parola',
                            prefixIcon: const Icon(Icons.lock_outline),
                            helperText: logo['hasPassword'] == true ? 'Kayıtlı (değiştirmek için yeni değer girin)' : null,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _firmNo, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Firma No (firmNo)'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: _periodNo, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dönem No (periodNo)'))),
                        ],
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_messageOk ? AppColors.accent : AppColors.danger).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(_message!, style: TextStyle(color: _messageOk ? const Color(0xFF047857) : AppColors.danger, fontSize: 13)),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(onPressed: _busy ? null : _save, icon: const Icon(Icons.save), label: const Text('Kaydet')),
                          OutlinedButton.icon(onPressed: _busy ? null : _test, icon: const Icon(Icons.wifi_tethering), label: const Text('Bağlantıyı Test Et')),
                          OutlinedButton.icon(onPressed: _busy ? null : _sync, icon: const Icon(Icons.sync), label: const Text('Şimdi Senkronla')),
                          if (_busy) const Padding(padding: EdgeInsets.all(8), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Diğer Ayarlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      _kv('PostgREST API', _settings?['postgrestUrl']?.toString() ?? ApiConfig.baseUrl),
                      _kv('Entegrasyon Servisi', ApiConfig.integrationUrl),
                      _kv('Stripe Modu', stripeMode == 'live' ? 'Canlı' : 'Mock (test)'),
                      const SizedBox(height: 8),
                      const Text(
                        'Stripe anahtarları (STRIPE_SECRET_KEY vb.) güvenlik gereği entegrasyon servisinde ortam değişkeni / secret olarak tutulur.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 170, child: Text(k, style: const TextStyle(color: AppColors.textMuted))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}

class _AppearanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.devices_outlined, color: AppColors.brand),
                SizedBox(width: 10),
                Text('Site Görünümü', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Açılış modunu ve e-ticaret vitrini temasını seçin. Temalar Ella HTML Template ana sayfa düzenlerine dayanır.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            const Text('Varsayılan açılış', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<AppMode>(
              segments: const [
                ButtonSegment(value: AppMode.storefront, label: Text('E-Ticaret Sitesi'), icon: Icon(Icons.storefront)),
                ButtonSegment(value: AppMode.panel, label: Text('Bayi Paneli'), icon: Icon(Icons.dashboard)),
              ],
              selected: {settings.appMode},
              onSelectionChanged: (s) => ref.read(appSettingsProvider.notifier).setAppMode(s.first),
            ),
            const SizedBox(height: 18),
            const Text('E-ticaret vitrini teması', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text(
              'Kart önizlemeleri temanın header, hero ve ürün kartı görünümünü yansıtır (Ella Home 1–10).',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
            ),
            const SizedBox(height: 12),
            const StoreThemePicker(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.read(appSettingsProvider.notifier).previewStorefront(),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('E-ticaret sitesini önizle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.logoMode, required this.stripeMode});
  final String logoMode;
  final String stripeMode;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String mode) {
      final live = mode == 'live';
      final color = live ? AppColors.accent : AppColors.warn;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(live ? Icons.check_circle : Icons.science_outlined, color: color, size: 18),
            const SizedBox(width: 8),
            Text('$label: ${live ? 'Canlı' : 'Mock'}', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: [chip('Logo', logoMode), chip('Stripe', stripeMode)]);
  }
}
