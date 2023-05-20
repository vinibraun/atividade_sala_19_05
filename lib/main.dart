import 'package:atividade_sala_19_05/pontoDao.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'Ponto.dart';
import 'package:maps_launcher/maps_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Ponto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _pontos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Ponto'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextButton(
              child: Text('Registrar Ponto'),
              onPressed: () {
                _registerPoint(context);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _pontos.length,
              itemBuilder: (BuildContext context, int index) {
                final ponto = Ponto.fromMap(_pontos[index]);
                return ListTile(
                  title: Text('Latitude: ${ponto.latitude}'),
                  subtitle: Text('Longitude: ${ponto.longitude}'),
                  trailing: Text(ponto.dataHora),
                  onTap: () {
                    _openLocationInMap(ponto.latitude, ponto.longitude);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    List<Ponto> pontos = await PontoDao().listar();
    setState(() {
      _pontos = pontos.map((ponto) => ponto.toMap()).toList();
    });
  }

  Future<void> _registerPoint(BuildContext context) async {
    final PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus != PermissionStatus.granted) {
      return;
    }

    // Verificar permissões de localização
    final PermissionStatus locationPermissionStatus = await Permission.locationWhenInUse.request();
    if (locationPermissionStatus != PermissionStatus.granted) {
      _showPermissionDeniedDialog(context);
      return;
    }

    // Verificar permissões de GPS
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      _showGpsDisabledDialog(context);
      return;
    }


    Position currentPosition = await Geolocator.getCurrentPosition();
    String currentDateTime = DateTime.now().toString();

    Ponto ponto = Ponto(
      id: 0, // O ID será atribuído automaticamente pelo banco de dados
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
      dataHora: currentDateTime,
    );

    await PontoDao().salvar(ponto);

    setState(() {
      _pontos.add(ponto.toMap());
    });

    // Exibir um diálogo de sucesso
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ponto registrado'),
          content: Text('Seu ponto foi registrado com sucesso.'),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openLocationInMap(double latitude, double longitude) {
    MapsLauncher.launchCoordinates(latitude, longitude);
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permissão negada'),
          content: Text('Você precisa permitir o acesso à localização para registrar o ponto.'),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showGpsDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('GPS desativado'),
          content: Text('Ative o GPS para registrar o ponto.'),
          actions: [
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
