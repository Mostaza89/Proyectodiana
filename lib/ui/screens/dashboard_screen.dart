import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../services/habitacion_service.dart';
import '../../services/reserva_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitacionesAsync = ref.watch(habitacionesProvider);
    final reservasAsync = ref.watch(reservasActivasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control Diario', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            habitacionesAsync.when(
              data: (habitaciones) {
                final disponibles = habitaciones.where((h) => h.estado == 'Disponible').length;
                final ocupadas = habitaciones.where((h) => h.estado == 'Ocupada').length;
                final mantenimiento = habitaciones.where((h) => h.estado == 'Mantenimiento').length;

                return Row(
                  children: [
                    _buildStatCard('Disponibles', disponibles.toString(), AppTheme.statusAvailable),
                    const SizedBox(width: 16),
                    _buildStatCard('Ocupadas', ocupadas.toString(), AppTheme.statusOccupied),
                    const SizedBox(width: 16),
                    _buildStatCard('Mantenimiento', mantenimiento.toString(), AppTheme.statusMaintenance),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error al cargar estadísticas: $err'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Reservas Activas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Table
            Expanded(
              child: Card(
                child: reservasAsync.when(
                  data: (reservas) {
                    if (reservas.isEmpty) {
                      return const Center(child: Text('No hay reservas activas en este momento.'));
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Habitación', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Huésped', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Entrada', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Salida', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusAvailable.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.statusAvailable),
                                  ),
                                  child: Text(
                                    r['estadoreserva'],
                                    style: const TextStyle(color: AppTheme.statusAvailable, fontWeight: FontWeight.bold),
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
                  error: (err, stack) => Center(child: Text('Error al cargar reservas: $err')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
