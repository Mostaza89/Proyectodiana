import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habitacion.dart';
import 'huesped_service.dart'; // Para reutilizar supabaseClientProvider

final habitacionServiceProvider = Provider<HabitacionService>((ref) {
  return HabitacionService(ref.watch(supabaseClientProvider));
});

final habitacionesProvider = FutureProvider<List<Habitacion>>((ref) async {
  final service = ref.watch(habitacionServiceProvider);
  return service.getHabitaciones();
});

class HabitacionService {
  final SupabaseClient _client;

  HabitacionService(this._client);

  Future<List<Habitacion>> getHabitaciones() async {
    final response = await _client.from('habitacion').select().order('numerohabitacion', ascending: true);
    return (response as List).map((e) => Habitacion.fromJson(e)).toList();
  }

  Future<List<Habitacion>> getHabitacionesDisponibles() async {
    final response = await _client
        .from('habitacion')
        .select()
        .eq('estado', 'Disponible')
        .order('numerohabitacion', ascending: true);
    return (response as List).map((e) => Habitacion.fromJson(e)).toList();
  }

  Future<void> updateEstadoHabitacion(int idHabitacion, String nuevoEstado) async {
    await _client
        .from('habitacion')
        .update({'estado': nuevoEstado})
        .eq('idhabitacion', idHabitacion);
  }

  Future<void> createHabitacion(Habitacion habitacion) async {
    await _client.from('habitacion').insert(habitacion.toJson());
  }
}
