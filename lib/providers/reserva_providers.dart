import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_provider.dart';
import '../services/reserva_service.dart';

/// Provider del servicio de reservas.
final reservaServiceProvider = Provider<ReservaService>((ref) {
  return ReservaService(ref.watch(supabaseClientProvider));
});

/// Provider que obtiene reservas activas con detalles de huésped y habitación.
final reservasActivasProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(reservaServiceProvider);
  return service.getReservasActivasConDetalles();
});
