class Habitacion {
  final int? idHabitacion;
  final String numeroHabitacion;
  final String tipo;
  final double precioPorNoche;
  final String estado;

  Habitacion({
    this.idHabitacion,
    required this.numeroHabitacion,
    required this.tipo,
    required this.precioPorNoche,
    required this.estado,
  });

  factory Habitacion.fromJson(Map<String, dynamic> json) {
    return Habitacion(
      idHabitacion: json['idhabitacion'] as int?,
      numeroHabitacion: json['numerohabitacion'] as String,
      tipo: json['tipo'] as String,
      precioPorNoche: (json['preciopornoche'] as num).toDouble(),
      estado: json['estado'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idHabitacion != null) 'idhabitacion': idHabitacion,
      'numerohabitacion': numeroHabitacion,
      'tipo': tipo,
      'preciopornoche': precioPorNoche,
      'estado': estado,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habitacion &&
          runtimeType == other.runtimeType &&
          idHabitacion == other.idHabitacion;

  @override
  int get hashCode => idHabitacion.hashCode;
}
