import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/huesped.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final huespedServiceProvider = Provider<HuespedService>((ref) {
  return HuespedService(ref.watch(supabaseClientProvider));
});

final huespedesProvider = FutureProvider<List<Huesped>>((ref) async {
  final service = ref.watch(huespedServiceProvider);
  return service.getHuespedes();
});

class HuespedService {
  final SupabaseClient _client;

  HuespedService(this._client);

  Future<List<Huesped>> getHuespedes() async {
    final response = await _client.from('huesped').select().order('idhuesped', ascending: false);
    return (response as List).map((e) => Huesped.fromJson(e)).toList();
  }

  Future<void> createHuesped(Huesped huesped) async {
    await _client.from('huesped').insert(huesped.toJson());
  }

  Future<List<Huesped>> searchHuespedes(String query) async {
    if (query.isEmpty) return getHuespedes();
    final response = await _client
        .from('huesped')
        .select()
        .or('nombre.ilike.%$query%,apellido.ilike.%$query%,documentoidentidad.ilike.%$query%');
    return (response as List).map((e) => Huesped.fromJson(e)).toList();
  }
}
