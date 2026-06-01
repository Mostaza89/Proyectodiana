import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/habitacion.dart';
import '../../services/habitacion_service.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitacionesAsync = ref.watch(habitacionesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matriz de Habitaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(habitacionesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoNuevaHabitacion(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Habitación'),
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: habitacionesAsync.when(
          data: (habitaciones) {
            if (habitaciones.isEmpty) {
              return const Center(child: Text('No hay habitaciones.'));
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: habitaciones.length,
              itemBuilder: (context, index) {
                final h = habitaciones[index];
                Color statusColor;
                switch (h.estado) {
                  case 'Disponible':
                    statusColor = AppTheme.statusAvailable;
                    break;
                  case 'Ocupada':
                    statusColor = AppTheme.statusOccupied;
                    break;
                  case 'Mantenimiento':
                    statusColor = AppTheme.statusMaintenance;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              h.numeroHabitacion,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                h.estado,
                                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        Text('Tipo: ${h.tipo}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('\$${h.precioPorNoche.toStringAsFixed(2)} / noche', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _mostrarDialogoEstado(context, ref, h.idHabitacion!, h.estado),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primaryGold),
                              foregroundColor: AppTheme.primaryGold,
                            ),
                            child: const Text('Actualizar Estado'),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoEstado(BuildContext context, WidgetRef ref, int idHabitacion, String estadoActual) async {
    String? nuevoEstado = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Seleccionar Estado'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, 'Disponible'),
              child: const Text('Disponible', style: TextStyle(color: AppTheme.statusAvailable, fontWeight: FontWeight.bold)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, 'Ocupada'),
              child: const Text('Ocupada', style: TextStyle(color: AppTheme.statusOccupied, fontWeight: FontWeight.bold)),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, 'Mantenimiento'),
              child: const Text('Mantenimiento', style: TextStyle(color: AppTheme.statusMaintenance, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (nuevoEstado != null && nuevoEstado != estadoActual) {
      try {
        final service = ref.read(habitacionServiceProvider);
        await service.updateEstadoHabitacion(idHabitacion, nuevoEstado);
        ref.invalidate(habitacionesProvider);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado.')));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _mostrarDialogoNuevaHabitacion(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => _NuevaHabitacionDialog(ref: ref),
    );
  }
}

class _NuevaHabitacionDialog extends StatefulWidget {
  final WidgetRef ref;
  const _NuevaHabitacionDialog({required this.ref});

  @override
  State<_NuevaHabitacionDialog> createState() => _NuevaHabitacionDialogState();
}

class _NuevaHabitacionDialogState extends State<_NuevaHabitacionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String _tipo = 'Sencilla';
  bool _isSaving = false;

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final nuevaHabitacion = Habitacion(
        numeroHabitacion: _numeroCtrl.text,
        tipo: _tipo,
        precioPorNoche: double.parse(_precioCtrl.text),
        estado: 'Disponible',
      );

      final service = widget.ref.read(habitacionServiceProvider);
      await service.createHabitacion(nuevaHabitacion);

      widget.ref.invalidate(habitacionesProvider);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habitación agregada exitosamente.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Habitación', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _numeroCtrl,
                decoration: const InputDecoration(labelText: 'Número de Habitación (ej. 101)'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo'),
                initialValue: _tipo,
                items: const [
                  DropdownMenuItem(value: 'Sencilla', child: Text('Sencilla')),
                  DropdownMenuItem(value: 'Doble', child: Text('Doble')),
                  DropdownMenuItem(value: 'Suite', child: Text('Suite')),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio por Noche'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Debe ser numérico';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _guardar,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

