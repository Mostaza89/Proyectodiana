import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/reserva.dart';
import '../../models/huesped.dart';
import '../../models/habitacion.dart';
import '../../providers/reserva_providers.dart';
import '../../providers/huesped_providers.dart';
import '../../providers/habitacion_providers.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Huesped? _selectedHuesped;
  Habitacion? _selectedHabitacion;
  DateTime? _fechaEntrada;
  DateTime? _fechaSalida;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Always fetch fresh guest list when entering this screen
    Future.microtask(() {
      ref.invalidate(huespedesProvider);
      ref.invalidate(habitacionesDisponiblesProvider);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isEntrada) async {
    final initialDate = isEntrada
        ? (_fechaEntrada ?? DateTime.now())
        : (_fechaSalida ?? (_fechaEntrada ?? DateTime.now()).add(const Duration(days: 1)));
    final firstDate = isEntrada
        ? DateTime.now()
        : (_fechaEntrada ?? DateTime.now()).add(const Duration(days: 1));
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isEntrada) {
          _fechaEntrada = picked;
          if (_fechaSalida != null && !_fechaSalida!.isAfter(_fechaEntrada!)) {
            _fechaSalida = null;
          }
        } else {
          _fechaSalida = picked;
        }
      });
    }
  }

  Future<void> _guardarReserva() async {
    if (_selectedHuesped == null ||
        _selectedHabitacion == null ||
        _fechaEntrada == null ||
        _fechaSalida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final reserva = Reserva(
        idHuesped: _selectedHuesped!.idHuesped!,
        idHabitacion: _selectedHabitacion!.idHabitacion!,
        fechaEntrada: _fechaEntrada!,
        fechaSalida: _fechaSalida!,
        estadoReserva: 'Activa',
      );

      final service = ref.read(reservaServiceProvider);
      await service.createReserva(reserva);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva creada exitosamente.')),
      );
      
      setState(() {
        _selectedHuesped = null;
        _selectedHabitacion = null;
        _fechaEntrada = null;
        _fechaSalida = null;
      });
      
      ref.invalidate(habitacionesDisponiblesProvider);
      ref.invalidate(habitacionesProvider);
      ref.invalidate(reservasActivasProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final huespedesAsync = ref.watch(huespedesProvider);
    final habitacionesDispAsync = ref.watch(habitacionesDisponiblesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reserva', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detalles de la Reserva', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  // Selección de Huésped
                  huespedesAsync.when(
                    data: (huespedes) {
                      // Reset selection if current selected huesped is not in the new list
                      if (_selectedHuesped != null &&
                          !huespedes.any((h) => h.idHuesped == _selectedHuesped!.idHuesped)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _selectedHuesped = null);
                        });
                      }
                      // Find matching huesped from fresh list to avoid reference mismatch
                      final currentSelection = _selectedHuesped == null
                          ? null
                          : huespedes.cast<Huesped?>().firstWhere(
                              (h) => h!.idHuesped == _selectedHuesped!.idHuesped,
                              orElse: () => null,
                            );
                      return DropdownButtonFormField<Huesped>(
                        decoration: const InputDecoration(labelText: 'Huésped'),
                        initialValue: currentSelection,
                        menuMaxHeight: 300,
                        isExpanded: true,
                        items: huespedes.map((h) => DropdownMenuItem(
                          value: h,
                          child: Text('${h.nombre} ${h.apellido} - ${h.documentoIdentidad}'),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedHuesped = val),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text('Error al cargar huéspedes: $err'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Selección de Habitación Disponible
                  habitacionesDispAsync.when(
                    data: (habitaciones) {
                      if (_selectedHabitacion != null &&
                          !habitaciones.any((h) => h.idHabitacion == _selectedHabitacion!.idHabitacion)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _selectedHabitacion = null);
                        });
                      }
                      final currentHabSelection = _selectedHabitacion == null
                          ? null
                          : habitaciones.cast<Habitacion?>().firstWhere(
                              (h) => h!.idHabitacion == _selectedHabitacion!.idHabitacion,
                              orElse: () => null,
                            );
                      return DropdownButtonFormField<Habitacion>(
                        decoration: const InputDecoration(labelText: 'Habitación (Solo Disponibles)'),
                        initialValue: currentHabSelection,
                        menuMaxHeight: 300,
                        isExpanded: true,
                        items: habitaciones.map((h) => DropdownMenuItem(
                          value: h,
                          child: Text('Habitación ${h.numeroHabitacion} - ${h.tipo} (\$${h.precioPorNoche})'),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedHabitacion = val),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, stack) => Text('Error al cargar habitaciones: $err'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Fechas
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Fecha de Entrada'),
                            child: Text(
                              _fechaEntrada == null
                                  ? 'Seleccionar'
                                  : DateFormat('dd/MM/yyyy').format(_fechaEntrada!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Fecha de Salida'),
                            child: Text(
                              _fechaSalida == null
                                  ? 'Seleccionar'
                                  : DateFormat('dd/MM/yyyy').format(_fechaSalida!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarReserva,
                      child: _isSaving 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Confirmar Reserva', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
