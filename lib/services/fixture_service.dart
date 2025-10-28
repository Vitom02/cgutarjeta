import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class FixtureService {
  static const String baseUrl = 'http://200.73.132.146:2026/api';

  Future<Map<String, dynamic>> getFixtureData(String club) async {
    try {
      final encodedClub = Uri.encodeComponent(club);
      final url = Uri.parse('$baseUrl/fixture/$encodedClub');
      
      print('Llamando a API: $url');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Respuesta exitosa de la API');
        return _parseFixtureResponse(data);
      } else {
        throw Exception('Error al obtener datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en FixtureService: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlayerData(String matricula) async {
    try {
      final url = Uri.parse('$baseUrl/handicap/whs/$matricula');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePlayerResponse(data, matricula);
      } else {
        throw Exception('Error al obtener datos del jugador: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener datos del jugador: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String matricula, String password) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/dondejugamos');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseLoginResponse(data, matricula, password);
      } else {
        throw Exception('Error al obtener usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _parseFixtureResponse(Map<String, dynamic> data) {
    final fixtureReport = data['fixtureReport'];
    final fixtures = fixtureReport['fixtures'] as List<dynamic>;

    if (fixtures.isEmpty) {
      throw Exception('No hay torneos disponibles');
    }

    // Obtener el primer fixture (o práctica libre)
    final firstFixture = fixtures[0];
    final bochasData = firstFixture['bochas'] as List<dynamic>;

    // Convertir las bochas al formato de nuestro modelo
    List<Bocha> bochas = bochasData.map((bochaJson) {
      return Bocha(
        idBocha: bochaJson['idBocha'],
        sexo: bochaJson['sexo'],
        color: bochaJson['color'],
        hoyos: _parseHoyos(bochaJson['hoyos']),
      );
    }).toList();

    // Preparar la lista de fixtures para selección
    List<Map<String, dynamic>> fixturesList = fixtures.map((fixture) {
      return {
        'idTorneo': fixture['idTorneo'],
        'nombre': fixture['nombre'],
        'fechaInicio': fixture['fechaInicio'],
        'tipo': fixture['tipo'],
        'descripcion': fixture['descripcion'],
      };
    }).toList();

    return {
      'club': fixtureReport['club'],
      'tournamentName': firstFixture['nombre'],
      'bochas': bochas,
      'fixtures': fixturesList,
      'idTorneo': firstFixture['idTorneo'],
    };
  }

  List<Hoyo> _parseHoyos(List<dynamic> hoyosData) {
    // Agrupar hoyos por número para evitar duplicados
    Map<int, Hoyo> hoyosMap = {};
    
    for (var hoyoJson in hoyosData) {
      int numeroHoyo = hoyoJson['numeroHoyo'];
      
      // Solo tomar el primer hoyo de cada número (evitar duplicados)
      if (!hoyosMap.containsKey(numeroHoyo)) {
        hoyosMap[numeroHoyo] = Hoyo(
          numeroHoyo: numeroHoyo,
          par: hoyoJson['par'],
          handicap: hoyoJson['handicap'] ?? 0,
        );
      }
    }

    // Ordenar por número de hoyo y retornar lista
    List<Hoyo> hoyos = hoyosMap.values.toList();
    hoyos.sort((a, b) => a.numeroHoyo.compareTo(b.numeroHoyo));
    
    // Asegurarse de tener exactamente 18 hoyos
    if (hoyos.length > 18) {
      return hoyos.sublist(0, 18);
    }
    
    return hoyos;
  }

  Map<String, dynamic> _parsePlayerResponse(Map<String, dynamic> data, String matricula) {
    // La respuesta tiene la estructura: {campo1: "807", campo2: "5,0", campo3: "KUMEC , CARLOS HUGO", ...}
    if (data.containsKey('campo1') && data.containsKey('campo2') && data.containsKey('campo3')) {
      // Convertir el handicap de string a double (campo2: "5,0" -> 5.0)
      String handicapStr = data['campo2'] ?? '0';
      double handicap = double.tryParse(handicapStr.replaceAll(',', '.')) ?? 0.0;
      
      return {
        'nombre': data['campo3'] ?? '', // Campo 3 es el nombre completo
        'handicap': handicap, // Campo 2 es el handicap
        'club': data['clubOpcion'] ?? '',
      };
    }
    
    return {
      'nombre': '',
      'handicap': 0.0,
      'club': '',
    };
  }

  Map<String, dynamic> _parseLoginResponse(List<dynamic> data, String matricula, String password) {
    // Buscar el usuario por matrícula comparando contra campo1
    for (var usuario in data) {
      if (usuario['campo1'] == matricula) {
        // Verificar que la contraseña sea la misma matrícula
        if (password == matricula) {
          return {
            'success': true,
            'usuario': {
              'id': usuario['id'],
              'nombreUsuario': usuario['campo1'], // Usar campo1 como nombreUsuario
              'nombre': usuario['campo3'], // Campo2 es el nombre completo
              'apellido': '', // No hay apellido separado
              'club': usuario['club'],
              'mail': usuario['mail'],
              'celular': usuario['celular'],
              'handicap': usuario['campo3'], // Campo3 es el handicap
            }
          };
        } else {
          return {
            'success': false,
            'error': 'La contraseña debe ser la misma matrícula'
          };
        }
      }
    }
    
    return {
      'success': false,
      'error': 'Usuario no encontrado'
    };
  }

  Future<double?> calculateHandicap(int idBocha, double hcpIndex, String club) async {
    try {
      // Aquí irá tu lógica de cálculo de handicap
      // Por ahora retornamos un cálculo simple
      double courseHandicap = hcpIndex * 0.9;
      return courseHandicap;
    } catch (e) {
      print('Error calculando handicap: $e');
      return null;
    }
  }

  Future<void> saveTarjeta({
    required int? idTorneo,
    required int idJugador,
    required String idClub,
    required String matriculaCompanion,
    required String matriculaMy,
    required List<int> scoresTarjeta1,
    required List<int> scoresTarjeta2,
    required int totalFairway,
    required int totalGreen,
    required int totalPutts,
  }) async {
    // Método para construir los datos de la tarjeta utilizando lista única de 18 hoyos
    Map<String, dynamic> buildTarjetaData(String matricula, List<int> scores, {int? putts, int? fir, int? gir}) {
      final ida = scores.sublist(0, 9); // Primeros 9 hoyos
      final vuelta = scores.sublist(9, 18); // Últimos 9 hoyos
      print('URL de la solicitud POST para saveTarjeta: ${Uri.parse('$baseUrl/tarjetas-ur/$idClub/$idTorneo')}');

      return {
        'idTorneo': idTorneo,
        'IdJugador': idJugador,
        'Matricula': matricula,
        ...List.generate(9, (index) => {'Hoyo${index + 1}': ida[index]})
            .reduce((a, b) => a..addAll(b)),
        ...List.generate(9, (index) => {'Hoyo${index + 10}': vuelta[index]})
            .reduce((a, b) => a..addAll(b)),
        'IDA': ida.reduce((a, b) => a + b),
        'VUELTA': vuelta.reduce((a, b) => a + b),
        'Gross': scores.reduce((a, b) => a + b),
        // Total Gross calculado de todos los hoyos
        if (putts != null) 'Putts': putts,
        if (fir != null) 'FIR': fir,
        if (gir != null) 'GIR': gir,
        'MatriculaCarga': matriculaMy,
      };
    }

    // Crear los datos para cada tarjeta
    final tarjeta1Data = buildTarjetaData(
      matriculaMy,
      scoresTarjeta1,
      putts: totalPutts,
      fir: totalFairway,
      gir: totalGreen,
    );
    final tarjeta2Data = buildTarjetaData(matriculaCompanion, scoresTarjeta2);

    // Preparar el JSON para la solicitud
    final tarjetasJson = {
      'TarjetaPropia': tarjeta1Data,
      'TarjetaCompanero': tarjeta2Data,
    };

    // Imprimir datos de las tarjetas para depuración
    print('Datos de la tarjeta para envío: ${jsonEncode(tarjetasJson)}');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tarjetas-ur/$idClub/$idTorneo'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode(tarjetasJson),
      );

      if (response.statusCode == 200) {
        print('Datos de las tarjetas guardados correctamente.');
      } else {
        print('Error al guardar los datos de las tarjetas: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
    }
  }
}

