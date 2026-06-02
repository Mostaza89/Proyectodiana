class Huesped {
  final int? idHuesped;
  final String nombre;
  final String apellido;
  final String documentoIdentidad;
  final String telefono;
  final String email;
  final String direccion;

  Huesped({
    this.idHuesped,
    required this.nombre,
    required this.apellido,
    required this.documentoIdentidad,
    required this.telefono,
    required this.email,
    required this.direccion,
  });

  factory Huesped.fromJson(Map<String, dynamic> json) {
    return Huesped(
      idHuesped: json['idhuesped'] as int?,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      documentoIdentidad: json['documentoidentidad'] as String,
      telefono: json['telefono'] as String,
      email: json['email'] as String,
      direccion: json['direccion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idHuesped != null) 'idhuesped': idHuesped,
      'nombre': nombre,
      'apellido': apellido,
      'documentoidentidad': documentoIdentidad,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Huesped &&
          runtimeType == other.runtimeType &&
          idHuesped == other.idHuesped;

  @override
  int get hashCode => idHuesped.hashCode;
}
