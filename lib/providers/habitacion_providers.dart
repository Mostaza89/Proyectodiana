import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_provider.dart';
import '../models/habitacion.dart';
import '../services/habitacion_service.dart';

/// Provider del servicio de habitaciones.
final habitacionServiceProvider = Provider<HabitacionService>((ref) {
  return HabitacionService(ref.watch(supabaseClientProvider));
});

/// Provider que obtiene todas las habitaciones.
final habitacionesProvider = FutureProvider<List<Habitacion>>((ref) async {
  final service = ref.watch(habitacionServiceProvider);
  return service.getHabitaciones();
});

/// Provider que obtiene solo habitaciones disponibles (para reservas).
final habitacionesDisponiblesProvider = FutureProvider<List<Habitacion>>((ref) async {
  final service = ref.watch(habitacionServiceProvider);
  return service.getHabitacionesDisponibles();
});
