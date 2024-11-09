import 'dart:convert';

Driver driverFromJson(String str) => Driver.fromJson(json.decode(str));

String driverToJson(Driver data) => json.encode(data.toJson());

class Driver {
  String id;
  String rol;
  String the01Nombres;
  String the02Apellidos;
  String the03NumeroDocumento;
  String the04TipoDocumento;
  String the05FechaExpedicionDocumento;
  String the06Email;
  String the07Celular;
  String the08FechaNacimiento;
  String the09Genero;
  String the10FechaRegistro;
  bool the11EstaActivado;
  String the12FechaActivacion;
  String the13NombreActivador;
  String the14TipoVehiculo;
  String the15Marca;
  String the16Color;
  String the17Modelo;
  String the18Placa;
  String the19TipoServicio;
  String the20NumeroSoat;
  String the21VigenciaSoat;
  String the22NumeroTecno;
  String the23VigenciaTecno;
  String the24NumeroTarjetaPropiedad;
  String the25CedulaDelanteraFoto;
  String the26CedulaTraseraFoto;
  String the27TarjetaPropiedadDelanteraFoto;
  String the28TarjetaPropiedadTraseraFoto;
  String the29FotoPerfil;
  int the30NumeroViajes;
  double the31Calificacion;
  int the321SaldoAnteriorInfo;
  int the32SaldoRecarga;
  String the33FechaUltimaRecarga;
  int the34NuevaRecarga;
  String the35NuevaRecargaInfo;
  String the36FechaNuevaRecarga;
  int the37RecargaRedimir;
  bool the38EstaBloqueado;
  bool the39EstaConectado;
  bool the00_is_working;
  bool the00_is_active;
  int the40NumeroCancelaciones;
  bool the41SuspendidoPorCancelaciones;
  String token;
  String image;
  String fotoCedulaDelantera;
  String fotoCedulaTrasera;
  String verificacionStatus;
  String fotoTarjetaPropiedadDelantera;
  String fotoTarjetaPropiedadTrasera;
  String the00_ultimo_cliente;
  bool ceduladelanteraTomada;
  bool cedulatraseraTomada;
  bool tarjetadelanteraTomada;
  bool tarjetatraseraTomada;
  String licenciaCategoria;
  String licenciaVigencia;
  bool fotoPerfilTomada;
  bool info_permisos;

  Driver({
    required this.id,
    required this.rol,
    required this.the01Nombres,
    required this.the02Apellidos,
    required this.the03NumeroDocumento,
    required this.the04TipoDocumento,
    required this.the05FechaExpedicionDocumento,
    required this.the06Email,
    required this.the07Celular,
    required this.the08FechaNacimiento,
    required this.the09Genero,
    required this.the10FechaRegistro,
    required this.the11EstaActivado,
    required this.the12FechaActivacion,
    required this.the13NombreActivador,
    required this.the14TipoVehiculo,
    required this.the15Marca,
    required this.the16Color,
    required this.the17Modelo,
    required this.the18Placa,
    required this.the19TipoServicio,
    required this.the20NumeroSoat,
    required this.the21VigenciaSoat,
    required this.the22NumeroTecno,
    required this.the23VigenciaTecno,
    required this.the24NumeroTarjetaPropiedad,
    required this.the25CedulaDelanteraFoto,
    required this.the26CedulaTraseraFoto,
    required this.the27TarjetaPropiedadDelanteraFoto,
    required this.the28TarjetaPropiedadTraseraFoto,
    required this.the29FotoPerfil,
    required this.the30NumeroViajes,
    required this.the31Calificacion,
    required this.the321SaldoAnteriorInfo,
    required this.the32SaldoRecarga,
    required this.the33FechaUltimaRecarga,
    required this.the34NuevaRecarga,
    required this.the35NuevaRecargaInfo,
    required this.the36FechaNuevaRecarga,
    required this.the37RecargaRedimir,
    required this.the38EstaBloqueado,
    required this.the39EstaConectado,
    required this.the40NumeroCancelaciones,
    required this.the41SuspendidoPorCancelaciones,
    required this.token,
    required this.image,
    required this.fotoCedulaDelantera,
    required this.fotoCedulaTrasera,
    required this.verificacionStatus,
    required this.fotoTarjetaPropiedadDelantera,
    required this.fotoTarjetaPropiedadTrasera,
    required this.the00_is_active,
    required this.the00_is_working,
    required this.the00_ultimo_cliente,
    required this.ceduladelanteraTomada,
    required this.cedulatraseraTomada,
    required this.tarjetadelanteraTomada,
    required this.tarjetatraseraTomada,
    required this.licenciaCategoria,
    required this.licenciaVigencia,
    required this.fotoPerfilTomada,
    required this.info_permisos,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    rol: json["rol"],
    the01Nombres: json["01_Nombres"],
    the02Apellidos: json["02_Apellidos"],
    the03NumeroDocumento: json["03_Numero_Documento"],
    the04TipoDocumento: json["04_Tipo_Documento"],
    the05FechaExpedicionDocumento: json["05_Fecha_Expedicion_Documento"],
    the06Email: json["06_Email"],
    the07Celular: json["07_Celular"],
    the08FechaNacimiento: json["08_Fecha_Nacimiento"],
    the09Genero: json["09_Genero"],
    the10FechaRegistro: json["10_Fecha_Registro"],
    the11EstaActivado: json["11_Esta_activado"],
    the12FechaActivacion: json["12_Fecha_Activacion"],
    the13NombreActivador: json["13_Nombre_Activador"],
    the14TipoVehiculo: json["14_Tipo_Vehiculo"],
    the15Marca: json["15_Marca"],
    the16Color: json["16_Color"],
    the17Modelo: json["17_Modelo"],
    the18Placa: json["18_Placa"],
    the19TipoServicio: json["19_Tipo_Servicio"],
    the20NumeroSoat: json["20_Numero_Soat"],
    the21VigenciaSoat: json["21_Vigencia_Soat"],
    the22NumeroTecno: json["22_Numero_Tecno"],
    the23VigenciaTecno: json["23_Vigencia_Tecno"],
    the24NumeroTarjetaPropiedad: json["24_Numero_Tarjeta_Propiedad"],
    the25CedulaDelanteraFoto: json["25_Cedula_Delantera_foto"],
    the26CedulaTraseraFoto: json["26_Cedula_Trasera_foto"],
    the27TarjetaPropiedadDelanteraFoto: json["27_Tarjeta_Propiedad_Delantera_foto"],
    the28TarjetaPropiedadTraseraFoto: json["28_Tarjeta_Propiedad_Trasera_foto"],
    the29FotoPerfil: json["29_Foto_perfil"],
    the30NumeroViajes: json["30_Numero_viajes"],
    the31Calificacion: json["31_Calificacion"]?.toDouble(),
    the321SaldoAnteriorInfo: json["321_Saldo_Anterior_Info"],
    the32SaldoRecarga: json["32_Saldo_Recarga"],
    the33FechaUltimaRecarga: json["33_Fecha_Ultima_Recarga"],
    the34NuevaRecarga: json["34_Nueva_Recarga"],
    the35NuevaRecargaInfo: json["35_Nueva_Recarga_Info"],
    the36FechaNuevaRecarga: json["36_Fecha_Nueva_Recarga"],
    the37RecargaRedimir: json["37_Recarga_Redimir"],
    the38EstaBloqueado: json["38_Esta_bloqueado"],
    the39EstaConectado: json["39_Esta_conectado"],
    the40NumeroCancelaciones: json["40_Numero_Cancelaciones"],
    the41SuspendidoPorCancelaciones: json["41_Suspendido_Por_Cancelaciones"],
    token: json["token"],
    image: json["image"],
    fotoCedulaDelantera: json["foto_cedula_delantera"]  ?? '',
    fotoCedulaTrasera: json["foto_cedula_trasera"]  ?? '',
    verificacionStatus: json["Verificacion_Status"]  ?? '',
    fotoTarjetaPropiedadDelantera: json["foto_tarjeta_propiedad_delantera"]  ?? '',
    fotoTarjetaPropiedadTrasera: json["foto_tarjeta_propiedad_trasera"]  ?? '',
    the00_is_active: json["00_is_active"]  ?? '',
    the00_is_working: json["00_is_working"]  ?? '',
    the00_ultimo_cliente: json["00_ultimo_cliente"]  ?? '',
    ceduladelanteraTomada: json["cedula_delantera_tomada"]  ?? '',
    cedulatraseraTomada: json["cedula_trasera_tomada"]  ?? '',
    tarjetadelanteraTomada: json["tarjeta_delantera_tomada"]  ?? '',
    tarjetatraseraTomada: json["tarjeta_trasera_tomada"]  ?? '',
    licenciaCategoria: json["licencia_categoria"]  ?? '',
    licenciaVigencia: json["licencia_vigencia"]  ?? '',
    fotoPerfilTomada: json["foto_perfil_tomada"]  ?? '',
    info_permisos: json["info_permisos"]  ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rol": rol,
    "01_Nombres": the01Nombres,
    "02_Apellidos": the02Apellidos,
    "03_Numero_Documento": the03NumeroDocumento,
    "04_Tipo_Documento": the04TipoDocumento,
    "05_Fecha_Expedicion_Documento": the05FechaExpedicionDocumento,
    "06_Email": the06Email,
    "07_Celular": the07Celular,
    "08_Fecha_Nacimiento": the08FechaNacimiento,
    "09_Genero": the09Genero,
    "10_Fecha_Registro": the10FechaRegistro,
    "11_Esta_activado": the11EstaActivado,
    "12_Fecha_Activacion": the12FechaActivacion,
    "13_Nombre_Activador": the13NombreActivador,
    "14_Tipo_Vehiculo": the14TipoVehiculo,
    "15_Marca": the15Marca,
    "16_Color": the16Color,
    "17_Modelo": the17Modelo,
    "18_Placa": the18Placa,
    "19_Tipo_Servicio": the19TipoServicio,
    "20_Numero_Soat": the20NumeroSoat,
    "21_Vigencia_Soat": the21VigenciaSoat,
    "22_Numero_Tecno": the22NumeroTecno,
    "23_Vigencia_Tecno": the23VigenciaTecno,
    "24_Numero_Tarjeta_Propiedad": the24NumeroTarjetaPropiedad,
    "25_Cedula_Delantera_foto": the25CedulaDelanteraFoto,
    "26_Cedula_Trasera_foto": the26CedulaTraseraFoto,
    "27_Tarjeta_Propiedad_Delantera_foto": the27TarjetaPropiedadDelanteraFoto,
    "28_Tarjeta_Propiedad_Trasera_foto": the28TarjetaPropiedadTraseraFoto,
    "29_Foto_perfil": the29FotoPerfil,
    "30_Numero_viajes": the30NumeroViajes,
    "31_Calificacion": the31Calificacion,
    "321_Saldo_Anterior_Info": the321SaldoAnteriorInfo,
    "32_Saldo_Recarga": the32SaldoRecarga,
    "33_Fecha_Ultima_Recarga": the33FechaUltimaRecarga,
    "34_Nueva_Recarga": the34NuevaRecarga,
    "35_Nueva_Recarga_Info": the35NuevaRecargaInfo,
    "36_Fecha_Nueva_Recarga": the36FechaNuevaRecarga,
    "37_Recarga_Redimir": the37RecargaRedimir,
    "38_Esta_bloqueado": the38EstaBloqueado,
    "39_Esta_conectado": the39EstaConectado,
    "40_Numero_Cancelaciones": the40NumeroCancelaciones,
    "41_Suspendido_Por_Cancelaciones": the41SuspendidoPorCancelaciones,
    "token": token,
    "image": image,
    "foto_cedula_delantera": fotoCedulaDelantera,
    "foto_cedula_trasera": fotoCedulaTrasera,
    "Verificacion_Status": verificacionStatus,
    "foto_tarjeta_propiedad_delantera": fotoTarjetaPropiedadDelantera,
    "foto_tarjeta_propiedad_trasera": fotoTarjetaPropiedadTrasera,
    "00_is_active": the00_is_active,
    "00_is_working": the00_is_working,
    "00_ultimo_cliente": the00_ultimo_cliente,
    "cedula_delantera_tomada": ceduladelanteraTomada,
    "cedula_trasera_tomada": cedulatraseraTomada,
    "tarjeta_delantera_tomada": tarjetadelanteraTomada,
    "tarjeta_trasera_tomada": tarjetatraseraTomada,
    "licencia_categoria": licenciaCategoria,
    "licencia_vigencia": licenciaVigencia,
    "foto_perfil_tomada": fotoPerfilTomada,
    "info_permisos": info_permisos,
  };
}