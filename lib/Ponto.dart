class Ponto {
  static const nomeTabela = 'ponto';
  static const campoId = 'id';
  static const campoLatitude = 'latitude';
  static const campoLongitude = 'longitude';
  static const campoDataHora = 'dataHora';

  int id;
  double latitude;
  double longitude;
  String dataHora;

  Ponto({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() => {
    campoId: id,
    campoLatitude: latitude,
    campoLongitude: longitude,
    campoDataHora: dataHora,
  };

  factory Ponto.fromMap(Map<String, dynamic> map) => Ponto(
    id: map[campoId] is int ? map[campoId] : null,
    latitude: map[campoLatitude] is double ? map[campoLatitude] : '',
    longitude: map[campoLongitude] is double ? map[campoLongitude] : '',
    dataHora: map[campoDataHora] is String ? map[campoDataHora] : '',
  );
}