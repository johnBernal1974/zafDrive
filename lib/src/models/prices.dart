

import 'dart:convert';

Price PriceFromJson(String str) => Price.fromJson(json.decode(str));

String PriceToJson(Price data) => json.encode(data.toJson());

class Price {
  String theCorreoConductores;
  String theCelularAtencionConductores;
  String theLinkCancelarCuenta;
  String theLinkPoliticasPrivacidad;
  String theVersionConductorAndroid;
  String theMantenimientoConductores;
  int  theComision;
  int theDistanciaTarifaMinima;
  int theNumeroCancelacionesConductor;
  int theRecargaInicial;
  int theTiempoDeBloqueo;
  int theTiempoDeEspera;
  double theDinamica;
  int theTarifaMinimaRegular;
  int theTarifaMinimaHotel;
  int theTarifaMinimaTurismo;
  double theRadioBusqueda;


  Price({
    required this.theCorreoConductores,
    required this.theCelularAtencionConductores,
    required this.theLinkCancelarCuenta,
    required this.theLinkPoliticasPrivacidad,
    required this.theVersionConductorAndroid,
    required this.theMantenimientoConductores,
    required this.theComision,
    required this.theDistanciaTarifaMinima,
    required this.theNumeroCancelacionesConductor,
    required this.theRecargaInicial,
    required this.theTiempoDeBloqueo,
    required this.theTiempoDeEspera,
    required this.theDinamica,
    required this.theTarifaMinimaRegular,
    required this.theTarifaMinimaHotel,
    required this.theTarifaMinimaTurismo,
    required this.theRadioBusqueda,


  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    theCorreoConductores: json["correo_conductores"]  ?? '',
    theCelularAtencionConductores: json["celular_atencion_conductores"]  ?? '',
    theLinkCancelarCuenta: json["link_cancelar_cuenta"]  ?? '',
    theLinkPoliticasPrivacidad: json["link_politicas_privacidad"]  ?? '',
    theVersionConductorAndroid: json["version_conductor_android"]  ?? '',
    theMantenimientoConductores: json["mantenimiento_conductores"]  ?? '',
    theComision: json["comision"]  ?? '',
    theDistanciaTarifaMinima: json["distancia_tarifa_minima"]  ?? '',
    theNumeroCancelacionesConductor: json["numero_cancelaciones_conductor"]  ?? '',
    theRecargaInicial: json["recarga_Inicial"]  ?? '',
    theTiempoDeBloqueo: json["tiempo_de_bloqueo"]  ?? '',
    theTiempoDeEspera: json["tiempo_de_espera"]  ?? '',
    theDinamica: json["dinamica"]?.toDouble() ?? "",
    theTarifaMinimaRegular: json["tarifa_minima_regular"] ?? "",
    theTarifaMinimaHotel: json["tarifa_minima_hotel"] ?? "",
    theTarifaMinimaTurismo: json["tarifa_minima_turismo"] ?? "",
    theRadioBusqueda: json["radio_de_busqueda"]?.toDouble() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Correo_conductores": theCorreoConductores,
    "celular_atencion_conductores": theCelularAtencionConductores,
    "link_cancelar_cuenta": theLinkCancelarCuenta,
    "link_politicas_privacidad": theLinkPoliticasPrivacidad,
    "version_conductor_android": theVersionConductorAndroid,
    "mantenimiento_conductores": theMantenimientoConductores,
    "comision": theComision,
    "distancia_tarifa_minima": theDistanciaTarifaMinima,
    "numero_cancelaciones_conductor": theNumeroCancelacionesConductor,
    "recarga_Inicial": theRecargaInicial,
    "tiempo_de_bloqueo": theTiempoDeBloqueo,
    "tiempo_de_espera": theTiempoDeEspera,
    "dinamica": theDinamica,
    "tarifa_minima_regular": theTarifaMinimaRegular,
    "tarifa_minima_hotel": theTarifaMinimaHotel,
    "tarifa_minima_turismo": theTarifaMinimaTurismo,
    "radio_de_busqueda": theRadioBusqueda,
  };
}
