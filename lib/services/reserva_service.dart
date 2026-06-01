import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reserva.dart';
import 'huesped_service.dart';

final reservaServiceProvider = Provider<ReservaService>((ref) {
  return ReservaService(ref.watch(supabaseClientProvider));
});

final reservasActivasProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(reservaServiceProvider);
  return service.getReservasActivasConDetalles();
});

class ReservaService {
  final SupabaseClient _client;

  ReservaService(this._client);

  Future<List<Reserva>> getReservas() async {
    final response = await _client.from('reserva').select().order('fechaentrada', ascending: false);
    return (response as List).map((e) => Reserva.fromJson(e)).toList();
  }

  // Traer reservas activas junto con datos de Huesped y Habitacion
  Future<List<Map<String, dynamic>>> getReservasActivasConDetalles() async {
    final response = await _client
        .from('reserva')
        .select('*, huesped(*), habitacion(*)')
        .eq('estadoreserva', 'Activa')
        .order('fechaentrada', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> createReserva(Reserva reserva) async {
    // Insertar la reserva
    await _client.from('reserva').insert(reserva.toJson());
    // Actualizar el estado de la habitación a Ocupada
    await _client
        .from('habitacion')
        .update({'estado': 'Ocupada'})
        .eq('idhabitacion', reserva.idHabitacion);
  }

  Future<void> finalizarReserva(int idReserva, int idHabitacion) async {
    // Actualizar la reserva a Finalizada
    await _client
        .from('reserva')
        .update({'estadoreserva': 'Finalizada'})
        .eq('idreserva', idReserva);
    // Liberar la habitación
    await _client
        .from('habitacion')
        .update({'estado': 'Disponible'})
        .eq('idhabitacion', idHabitacion);
  }
}
