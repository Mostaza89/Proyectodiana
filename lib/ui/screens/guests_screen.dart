import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/huesped.dart';
import '../../providers/huesped_providers.dart';
import '../../ui/widgets/empty_state.dart';

class GuestsScreen extends ConsumerStatefulWidget {
  const GuestsScreen({super.key});

  @override
  ConsumerState<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends ConsumerState<GuestsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _docIdentidadCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _docIdentidadCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarHuesped() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final nuevoHuesped = Huesped(
        nombre: _nombreCtrl.text,
        apellido: _apellidoCtrl.text,
        documentoIdentidad: _docIdentidadCtrl.text,
        telefono: _telefonoCtrl.text,
        email: _emailCtrl.text,
        direccion: _direccionCtrl.text,
      );

      final service = ref.read(huespedServiceProvider);
      await service.createHuesped(nuevoHuesped);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Huésped registrado exitosamente.')),
      );

      _formKey.currentState!.reset();
      _nombreCtrl.clear();
      _apellidoCtrl.clear();
      _docIdentidadCtrl.clear();
      _telefonoCtrl.clear();
      _emailCtrl.clear();
      _direccionCtrl.clear();
      
      // Refrescar lista de búsqueda y lista general (usada en reservas)
      ref.invalidate(searchGuestsProvider);
      ref.invalidate(huespedesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchGuestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Huéspedes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulario de nuevo huésped
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nuevo Registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nombreCtrl,
                              decoration: const InputDecoration(labelText: 'Nombre'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _apellidoCtrl,
                              decoration: const InputDecoration(labelText: 'Apellido'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _docIdentidadCtrl,
                              decoration: const InputDecoration(labelText: 'Doc. Identidad'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _telefonoCtrl,
                              decoration: const InputDecoration(labelText: 'Teléfono'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(labelText: 'Email'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _direccionCtrl,
                              decoration: const InputDecoration(labelText: 'Dirección'),
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _guardarHuesped,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(_isSaving ? 'Guardando...' : 'Guardar Huésped'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Buscador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Directorio de Huéspedes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      ref.read(searchGuestQueryProvider.notifier).updateQuery(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tabla
            Expanded(
              child: Card(
                child: searchAsync.when(
                  data: (huespedes) {
                    if (huespedes.isEmpty) {
                      return const EmptyState(
                        icon: Icons.people_outline,
                        message: 'No hay huéspedes registrados.',
                        subtitle: 'Registra un huésped usando el formulario de arriba.',
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Doc. Identidad', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Apellido', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: huespedes.map((h) {
                            return DataRow(cells: [
                              DataCell(Text(h.documentoIdentidad)),
                              DataCell(Text(h.nombre)),
                              DataCell(Text(h.apellido)),
                              DataCell(Text(h.telefono)),
                              DataCell(Text(h.email)),
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
}
