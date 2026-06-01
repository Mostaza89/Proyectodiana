class Reserva {
  final int? idReserva;
  final int idHuesped;
  final int idHabitacion;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final String estadoReserva;

  Reserva({
    this.idReserva,
    required this.idHuesped,
    required this.idHabitacion,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.estadoReserva,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      idReserva: json['idreserva'] as int?,
      idHuesped: json['idhuesped'] as int,
      idHabitacion: json['idhabitacion'] as int,
      fechaEntrada: DateTime.parse(json['fechaentrada'] as String),
      fechaSalida: DateTime.parse(json['fechasalida'] as String),
      estadoReserva: json['estadoreserva'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idReserva != null) 'idreserva': idReserva,
      'idhuesped': idHuesped,
      'idhabitacion': idHabitacion,
      // Supabase expects YYYY-MM-DD
      'fechaentrada': fechaEntrada.toIso8601String().split('T')[0],
      'fechasalida': fechaSalida.toIso8601String().split('T')[0],
      'estadoreserva': estadoReserva,
    };
  }
}
