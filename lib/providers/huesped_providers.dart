import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_provider.dart';
import '../models/huesped.dart';
import '../services/huesped_service.dart';

/// Provider del servicio de huéspedes.
final huespedServiceProvider = Provider<HuespedService>((ref) {
  return HuespedService(ref.watch(supabaseClientProvider));
});

/// Provider que obtiene todos los huéspedes.
final huespedesProvider = FutureProvider<List<Huesped>>((ref) async {
  final service = ref.watch(huespedServiceProvider);
  return service.getHuespedes();
});

/// Notifier para el query de búsqueda de huéspedes.
class SearchGuestQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

/// Provider del query de búsqueda.
final searchGuestQueryProvider =
    NotifierProvider<SearchGuestQueryNotifier, String>(
  SearchGuestQueryNotifier.new,
);

/// Provider que obtiene huéspedes filtrados por búsqueda.
final searchGuestsProvider = FutureProvider<List<Huesped>>((ref) async {
  final query = ref.watch(searchGuestQueryProvider);
  final service = ref.watch(huespedServiceProvider);
  return service.searchHuespedes(query);
});
