import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/reserva_providers.dart';
import '../../providers/habitacion_providers.dart';
import '../../ui/widgets/empty_state.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservasAsync = ref.watch(reservasActivasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-out de Huéspedes', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(reservasActivasProvider),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reservas Activas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: reservasAsync.when(
                  data: (reservas) {
                    if (reservas.isEmpty) {
                      return const EmptyState(
                        icon: Icons.check_circle_outline,
                        message: 'No hay reservas activas.',
                        subtitle: 'Todas las habitaciones están libres.',
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Habitación', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Huésped', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Entrada', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Salida', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Acción', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: reservas.map((r) {
                            final habitacion = r['habitacion'];
                            final huesped = r['huesped'];
                            final fechaE = DateTime.parse(r['fechaentrada']);
                            final fechaS = DateTime.parse(r['fechasalida']);

                            return DataRow(cells: [
                              DataCell(Text(habitacion != null ? habitacion['numerohabitacion'] : 'N/A')),
                              DataCell(Text(huesped != null ? '${huesped['nombre']} ${huesped['apellido']}' : 'N/A')),
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(fechaE))),
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(fechaS))),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () => _realizarCheckout(context, ref, r['idreserva'], r['idhabitacion']),
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('Realizar Check-out'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryNavy,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _realizarCheckout(BuildContext context, WidgetRef ref, int idReserva, int idHabitacion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Check-out'),
        content: const Text('¿Está seguro de realizar el check-out? La habitación pasará a estado Disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final service = ref.read(reservaServiceProvider);
        await service.finalizarReserva(idReserva, idHabitacion);
        
        ref.invalidate(reservasActivasProvider);
        ref.invalidate(habitacionesProvider);
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-out realizado exitosamente.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al realizar check-out: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
