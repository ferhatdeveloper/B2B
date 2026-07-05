import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_client.dart';
import '../../services/b2b_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final b2bServiceProvider = Provider<B2bService>((ref) {
  return B2bService(client: ref.watch(apiClientProvider));
});
