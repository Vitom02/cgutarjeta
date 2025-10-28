import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/models.dart';
import '../services/fixture_service.dart';
import '../services/user_service.dart';

class TarjetaScreen extends StatefulWidget {
  final bool isTorneo;
  const TarjetaScreen({Key? key, required this.isTorneo}) : super(key: key);
  
  @override
  _TarjetaScreenState createState() => _TarjetaScreenState();
}

class _TarjetaScreenState extends State<TarjetaScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _matriculaMyController = TextEditingController();
  final TextEditingController _matriculaCompanionController = TextEditingController();
  int _selectedTarjeta = 1;
  
  // Lista única para 18 hoyos para cada tarjeta
  List<int> _tarjeta1 = List.filled(18, 0);
  List<int> _tarjeta2 = List.filled(18, 0);
  int? _selectedHole;
  
  String _tournamentName = '';
  late Box tarjetaBox;
  String _myName = '';
  String _companionName = '';
  double _totalGrossT1 = 0.0;
  double _totalGrossT2 = 0.0;
  double _handicapT1 = 0.0;
  double _handicapT2 = 0.0;
  double _totalNetoT1 = 0.0;
  double _totalNetoT2 = 0.0;
  List<Bocha> bochas = [];
  Bocha? _selectedBocha1;
  Bocha? _selectedBocha2;
  List<Hoyo> _hoyosTarjeta1 = [];
  List<Hoyo> _hoyosTarjeta2 = [];
  ScrollController _scrollController = ScrollController();
  GlobalKey _selectedHoleKey = GlobalKey();
  bool _autoMoveEnabled = true;
  int? _selectedTournamentId;
  bool _isLoadingData = true;
  String? _errorMessage;
  final FixtureService _fixtureService = FixtureService();
  
  // Variables para estadísticas
  int _totalFairway = 0;
  int _totalGreen = 0;
  int _totalPutts = 0;
  
  // Variables para reconocimiento de voz
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _speechText = '';
  
  // Mapa para convertir palabras de números a enteros
  final Map<String, int> _wordToNumber = {
    'cero': 0,
    'uno': 1,
    'dos': 2,
    'do': 2,
    'tres': 3,
    'tre': 3,
    'cuatro': 4,
    'cinco': 5,
    'seis': 6,
    'sei': 6,
    'siete': 7,
    'ocho': 8,
    'nueve': 9,
    'diez': 10,
    'die': 10,
    'once': 11,
    'doce': 12,
    'trece': 13,
    'catorce': 14,
    'quince': 15,
    'dieciséis': 16,
    'diecisiete': 17,
    'dieciocho': 18,
    'diecinueve': 19,
    'veinte': 20,
    'veintiuno': 21,
    'veintidós': 22,
    'veintitrés': 23,
    'veinticuatro': 24,
    'veinticinco': 25,
    'veintiséis': 26,
    'veintisiete': 27,
    'veintiocho': 28,
    'veintinueve': 29,
    'treinta': 30,
  };

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _initializeSpeech();
    _pageController = PageController();
    _scrollController = ScrollController();
    _loadMockData();
    _loadLoggedUserData();
  }

  void _initializeHive() async {
    tarjetaBox = await Hive.openBox('tarjetaBox4');
    _loadData();
  }

  void _initializeSpeech() async {
    try {
      _speech = stt.SpeechToText();
      bool available = await _speech.initialize();
      if (!available) {
        throw Exception("Speech recognition not available");
      }
    } catch (e) {
      print("Error initializing speech recognition: $e");
    }
  }

  void _loadLoggedUserData() async {
    try {
      final userMatricula = await UserService.getUserMatricula();
      if (userMatricula.isNotEmpty) {
        setState(() {
          // Siempre asignar la matrícula del usuario logueado
          _matriculaMyController.text = userMatricula;
        });
        // Cargar datos del jugador logueado
        _loadPlayerData(userMatricula, true);
      }
    } catch (e) {
      print('Error al cargar datos del usuario logueado: $e');
    }
  }

  void _loadMockData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      // Llamar a la API real
      final data = await _fixtureService.getFixtureData('C. GOLF DEL URUGUAY');
      
      if (mounted) {
        setState(() {
          _tournamentName = data['tournamentName'];
          bochas = data['bochas'];
          _selectedTournamentId = data['idTorneo'];
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar datos: $e';
          _isLoadingData = false;
          // Cargar datos de respaldo en caso de error
          bochas = _generateFallbackBochas();
          _tournamentName = widget.isTorneo ? 'Torneo (sin conexión)' : 'Práctica Libre';
        });
      }
    }
  }

  List<Bocha> _generateFallbackBochas() {
    return [
      Bocha(
        idBocha: 1,
        color: 'Blanca',
        sexo: 'Damas',
        hoyos: _generateFallbackHoyos(),
      ),
      Bocha(
        idBocha: 2,
        color: 'Roja',
        sexo: 'Damas',
        hoyos: _generateFallbackHoyos(),
      ),
      Bocha(
        idBocha: 3,
        color: 'Amarilla',
        sexo: 'Caballeros',
        hoyos: _generateFallbackHoyos(),
      ),
      Bocha(
        idBocha: 4,
        color: 'Azul',
        sexo: 'Caballeros',
        hoyos: _generateFallbackHoyos(),
      ),
    ];
  }

  List<Hoyo> _generateFallbackHoyos() {
    return List.generate(18, (index) {
      return Hoyo(
        numeroHoyo: index + 1,
        par: (index % 3 == 0) ? 5 : (index % 2 == 0) ? 3 : 4,
        handicap: index + 1,
      );
    });
  }

  void _loadData() async {
    try {
      String key = 'mock_user_tarjeta';
      var tarjeta = tarjetaBox.get(key) as Tarjeta?;

      if (tarjeta != null) {
        if (mounted) {
          setState(() {
            _tarjeta1.setAll(0, tarjeta.tarjetaScores?.scores1 ?? List.filled(18, 0));
            _tarjeta2.setAll(0, tarjeta.tarjetaScores?.scores2 ?? List.filled(18, 0));
            _selectedBocha1 = tarjeta.bochaSeleccionada1;
            _selectedBocha2 = tarjeta.bochaSeleccionada2;
            // NO sobrescribir la matrícula del usuario logueado
            // _matriculaMyController.text = tarjeta.matricula; // Comentado
            _matriculaCompanionController.text = tarjeta.matriculaCompanion;
            _tournamentName = tarjeta.nombreTorneo;
          });
          
          // Cargar datos de jugadores cuando se cargan las matrículas guardadas
          // Solo cargar datos del compañero, el usuario principal ya se carga en _loadLoggedUserData
          if (tarjeta.matriculaCompanion.isNotEmpty) {
            _loadPlayerData(tarjeta.matriculaCompanion, false);
          }
        }
        _updateGrossTotals();
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  String _cleanPlayerName(String name) {
    if (name.isEmpty) return '';
    
    // Limpiar comas y espacios extra
    String cleanedName = name
        .replaceAll(RegExp(r'\s*,\s*'), ' ') // Reemplazar comas con espacios
        .replaceAll(RegExp(r'\s+'), ' ') // Reemplazar múltiples espacios con uno
        .trim(); // Quitar espacios al inicio y final
    
    // Capitalizar cada palabra
    List<String> words = cleanedName.split(' ');
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();
    
    return capitalizedWords.join(' ');
  }

  void _loadPlayerData(String matricula, bool isMainPlayer) async {
    if (matricula.isEmpty) return;
    
    try {
      final playerData = await _fixtureService.getPlayerData(matricula);
      
      if (mounted) {
        setState(() {
          if (isMainPlayer) {
            _myName = _cleanPlayerName(playerData['nombre'] ?? '');
            _handicapT1 = playerData['handicap'] ?? 0.0;
          } else {
            _companionName = _cleanPlayerName(playerData['nombre'] ?? '');
            _handicapT2 = playerData['handicap'] ?? 0.0;
          }
        });
        _updateNetTotals();
        _saveData();
      }
    } catch (e) {
      print('Error al cargar datos del jugador: $e');
    }
  }

  void _saveData() async {
    try {
      String key = 'mock_user_tarjeta';

      var tarjetaScores = TarjetaScores(
        scores1: List.from(_tarjeta1),
        scores2: List.from(_tarjeta2),
      );

      // Obtener la matrícula del usuario logueado
      final userMatricula = await UserService.getUserMatricula();

      var tarjeta = Tarjeta(
        nombreTorneo: _tournamentName,
        matricula: userMatricula.isNotEmpty ? userMatricula : _matriculaMyController.text,
        matriculaCompanion: _matriculaCompanionController.text,
        nombreJugador: _myName,
        bochaSeleccionada1: _selectedBocha1,
        bochaSeleccionada2: _selectedBocha2,
        tarjetaScores: tarjetaScores,
      );

      tarjetaBox.put(key, tarjeta);
      print('Datos guardados correctamente');
    } catch (e) {
      print('Error al guardar en Hive: $e');
    }
  }

  void _updateScore(int holeIndex, int tarjetaIndex, int newScore) {
    if (holeIndex < 0 || holeIndex >= (_tarjeta1.length) || (tarjetaIndex != 1 && tarjetaIndex != 2)) {
      print('Índice de hoyo o tarjeta inválido');
      return;
    }

    if (newScore < 0) {
      print('Puntaje inválido');
      return;
    }

    setState(() {
      if (tarjetaIndex == 1) {
        _tarjeta1[holeIndex] = newScore;
      } else {
        _tarjeta2[holeIndex] = newScore;
      }
      _updateGrossTotals();
      
      Future.delayed(Duration(seconds: 1), () {
        _selectNextHole(holeIndex, tarjetaIndex);
      });
    });

    _saveData();
  }

  void _updateGrossTotals() {
    _totalGrossT1 = _calculateTotal(_tarjeta1).toDouble();
    _totalGrossT2 = _calculateTotal(_tarjeta2).toDouble();
    _updateNetTotals();
  }

  void _updateNetTotals() {
    _totalNetoT1 = _totalGrossT1 - _handicapT1;
    _totalNetoT2 = _totalGrossT2 - _handicapT2;
  }

  int _calculateTotal(List<int> list) {
    return list.reduce((value, element) => value + element);
  }

  void _clearTarjeta() async {
    try {
      String key = 'mock_user_tarjeta';
      await tarjetaBox.delete(key);
      
      if (mounted) {
        setState(() {
          _tarjeta1.fillRange(0, _tarjeta1.length, 0);
          _tarjeta2.fillRange(0, _tarjeta2.length, 0);
          _matriculaCompanionController.clear();
          _selectedBocha1 = null;
          _selectedBocha2 = null;
          _companionName = '';
          _totalGrossT1 = 0.0;
          _totalGrossT2 = 0.0;
          _totalNetoT1 = 0.0;
          _totalNetoT2 = 0.0;
          _handicapT1 = 0.0;
          _handicapT2 = 0.0;
          _updateGrossTotals();
        });
      }
    } catch (e) {
      print('Error al borrar los datos: $e');
    }
  }

  int? _getParForHoyo(int hoyoNumero) {
    Hoyo? hoyo1 = _hoyosTarjeta1.firstWhere(
      (h) => h.numeroHoyo == hoyoNumero,
      orElse: () => Hoyo(numeroHoyo: hoyoNumero, handicap: 0, par: 0),
    );

    Hoyo? hoyo2 = _hoyosTarjeta2.firstWhere(
      (h) => h.numeroHoyo == hoyoNumero,
      orElse: () => Hoyo(numeroHoyo: hoyoNumero, handicap: 0, par: 0),
    );

    return hoyo1.par ?? hoyo2.par ?? 0;
  }

  void _selectNextHole(int currentHoleIndex, int tarjetaIndex) {
    if (_autoMoveEnabled) {
      if (tarjetaIndex == 1) {
        if (_tarjeta2.isNotEmpty && _tarjeta2[currentHoleIndex] == 0) {
          setState(() {
            _selectedHole = currentHoleIndex;
            _selectedTarjeta = 2;
          });
        } else {
          int nextHoleIndex = currentHoleIndex + 1;
          if (nextHoleIndex < _tarjeta1.length) {
            setState(() {
              _selectedHole = nextHoleIndex;
              _selectedTarjeta = 1;
            });
          }
        }
      } else if (tarjetaIndex == 2) {
        if (_tarjeta1.isNotEmpty && _tarjeta1[currentHoleIndex] == 0) {
          setState(() {
            _selectedHole = currentHoleIndex;
            _selectedTarjeta = 1;
          });
        } else {
          int nextHoleIndex = currentHoleIndex + 1;
          if (nextHoleIndex < _tarjeta2.length) {
            setState(() {
              _selectedHole = nextHoleIndex;
              _selectedTarjeta = 2;
            });
          }
        }
      }
      _scrollToSelectedHole();
    }
  }

  void _scrollToSelectedHole() {
    if (_selectedHole != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Scroll logic aquí
      });
    }
  }

  void _filterHoyosByBocha(Bocha? bochaSeleccionada, List<Bocha> bochas) {
    if (bochaSeleccionada == null) return;

    Bocha? selectedBocha = bochas.firstWhere(
      (bocha) => bocha.idBocha == bochaSeleccionada.idBocha,
      orElse: () => Bocha(idBocha: -1, color: 'N/A', sexo: 'N/A', hoyos: []),
    );

    if (selectedBocha.idBocha == -1) return;

    setState(() {
      if (bochaSeleccionada == _selectedBocha1) {
        _hoyosTarjeta1 = selectedBocha.hoyos;
      } else if (bochaSeleccionada == _selectedBocha2) {
        _hoyosTarjeta2 = selectedBocha.hoyos;
      }
    });
  }

  int? _getHandicapForHoyo(int hoyoNumero) {
    Hoyo? hoyo1 = _hoyosTarjeta1.firstWhere(
      (h) => h.numeroHoyo == hoyoNumero,
      orElse: () => Hoyo(numeroHoyo: hoyoNumero, handicap: 0, par: 0),
    );

    Hoyo? hoyo2 = _hoyosTarjeta2.firstWhere(
      (h) => h.numeroHoyo == hoyoNumero,
      orElse: () => Hoyo(numeroHoyo: hoyoNumero, handicap: 0, par: 0),
    );

    return hoyo1.handicap ?? hoyo2.handicap ?? 0;
  }

  int _sumFirstNineHoles(int tarjetaIndex) {
    List<int> tarjeta = tarjetaIndex == 1 ? _tarjeta1 : _tarjeta2;
    return tarjeta.sublist(0, 9).reduce((a, b) => a + b);
  }

  int _sumSecondNineHoles(int tarjetaIndex) {
    List<int> tarjeta = tarjetaIndex == 1 ? _tarjeta1 : _tarjeta2;
    return tarjeta.sublist(9, 18).reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras carga datos
    if (_isLoadingData) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 20),
              Text('Cargando datos del torneo...'),
            ],
          ),
        ),
      );
    }

    // Mostrar error si hay
    if (_errorMessage != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              Text(
                'Usando datos locales',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _loadMockData();
                },
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      appBar: _buildAppBar(),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_tournamentName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            _buildMatriculaInputRow(),
                            SizedBox(height: 12),
                            _buildBochaSelectionRow(bochas),
                            SizedBox(height: 10),
                            _buildGolfCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SafeArea(
                      bottom: true,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildFooter(),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children: [
                  _buildHorizontalGolfCard(_tournamentName, _myName, _companionName, isTarjeta2: false, tarjeta: _tarjeta1),
                  _buildHorizontalGolfCard(_tournamentName, _myName, _companionName, isTarjeta2: true, tarjeta: _tarjeta2),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Tarjeta de Golf'),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'limpiar') {
              _showConfirmationDialog(
                context,
                '¿Estás seguro de que quieres limpiar la tarjeta?',
                _clearTarjeta,
              );
            } else if (value == 'enviar') {
              _showConfirmationDialog(
                context,
                '¿Estás seguro de que quieres enviar la tarjeta?',
                _sendTarjeta,
              );
            } else if (value == 'autoMove') {
              setState(() {
                _autoMoveEnabled = !_autoMoveEnabled;
              });
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'limpiar',
                child: Text('Limpiar Tarjeta'),
              ),
              PopupMenuItem<String>(
                value: 'enviar',
                child: Text('Enviar Tarjeta'),
              ),
              PopupMenuItem<String>(
                value: 'autoMove',
                child: Text(_autoMoveEnabled ? 'Desactivar auto foco' : 'Activar auto foco'),
              ),
            ];
          },
        ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String message, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatriculaInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _matriculaMyController,
            decoration: InputDecoration(
              labelText: 'Matrícula Marcador',
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            readOnly: true,
            enabled: false,
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _matriculaCompanionController,
            decoration: InputDecoration(labelText: 'Matricula compañero'),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (value) {
              _saveData();
              if (value.isNotEmpty) {
                _loadPlayerData(value, false);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBochaSelectionRow(List<Bocha>? bochas) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: DropdownButton<Bocha>(
            value: _selectedBocha1,
            hint: Text('Bocha 1'),
            isExpanded: true,
            onChanged: (Bocha? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBocha1 = newValue;
                  _saveData();
                  _filterHoyosByBocha(newValue, bochas ?? []);
                });
              }
            },
            items: bochas?.map<DropdownMenuItem<Bocha>>((Bocha option) {
              return DropdownMenuItem<Bocha>(
                value: option,
                child: Text('${option.sexo} - ${option.color}'),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: DropdownButton<Bocha>(
            value: _selectedBocha2,
            hint: Text('Bocha 2'),
            isExpanded: true,
            onChanged: (Bocha? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBocha2 = newValue;
                  _saveData();
                  _filterHoyosByBocha(newValue, bochas ?? []);
                });
              }
            },
            items: bochas?.map<DropdownMenuItem<Bocha>>((Bocha option) {
              return DropdownMenuItem<Bocha>(
                value: option,
                child: Text('${option.sexo} - ${option.color}'),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGolfCard() {
    return Column(
      children: [
        _buildGolfCardHeader(),
        SizedBox(height: 8.0),
        _buildGolfCardTable(),
      ],
    );
  }

  Widget _buildGolfCardHeader() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(40),
        3: FlexColumnWidth(),
      },
      children: [
        TableRow(
          children: [
            _buildHeaderCell('H'),
            _buildPlayerHeaderCell(_myName, _handicapT1),
            _buildHeaderCell('H'),
            _buildPlayerHeaderCell(_companionName, _handicapT2),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeaderCell(String playerName, double handicap) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              playerName.split(' ').isNotEmpty ? playerName.split(' ').first : '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'HCP: ${handicap.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGolfCardTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(40),
        3: FlexColumnWidth(),
      },
      children: [
        for (int i = 0; i < 9; i++)
          TableRow(
            children: [
              _buildHoleCell(i, 1),
              _buildScoreCell(i, 1),
              _buildHoleCell(i, 2),
              _buildScoreCell(i, 2),
            ],
          ),
        TableRow(
          children: [
            _buildTextCell("I"),
            _buildSumCell(_sumFirstNineHoles(1)),
            _buildTextCell("I"),
            _buildSumCell(_sumFirstNineHoles(2)),
          ],
        ),
        for (int i = 9; i < 18; i++)
          TableRow(
            children: [
              _buildHoleCell(i, 1),
              _buildScoreCell(i, 1),
              _buildHoleCell(i, 2),
              _buildScoreCell(i, 2),
            ],
          ),
        TableRow(
          children: [
            _buildTextCell("V"),
            _buildSumCell(_sumSecondNineHoles(1)),
            _buildTextCell("V"),
            _buildSumCell(_sumSecondNineHoles(2)),
          ],
        ),
      ],
    );
  }

  TableCell _buildSumCell(int sum) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          sum.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTextCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  TableCell _buildHoleCell(int index, int tarjetaIndex) {
    int hoyoNumero = index + 1;
    int? handicap = _getHandicapForHoyo(hoyoNumero);

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              '$hoyoNumero',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              handicap != null ? '($handicap)' : '()',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  TableCell _buildScoreCell(int index, int tarjetaIndex) {
    int score = tarjetaIndex == 1 ? _tarjeta1[index] : _tarjeta2[index];
    bool isSelected = _selectedHole == index && _selectedTarjeta == tarjetaIndex;

    return TableCell(
      child: GestureDetector(
        key: isSelected ? _selectedHoleKey : null,
        onTap: () {
          if (_selectedBocha1 == null) {
            _showAssignBochaAlert();
          } else {
            setState(() {
              _selectedHole = index;
              _selectedTarjeta = tarjetaIndex;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelectedHole();
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.lightGreenAccent : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.red : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  void _showAssignBochaAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso'),
          content: Text('Usted debe primero asignar una bocha.'),
          actions: [
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    int? parValue = _selectedHole != null ? _getParForHoyo(_selectedHole! + 1) : 0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1.0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScoreRow('GROSS', _totalGrossT1, _totalGrossT2),
          SizedBox(height: 5),
          _buildScoreRow('HCP', _handicapT1, _handicapT2),
          SizedBox(height: 5),
          _buildScoreRow('NETO', _totalNetoT1, _totalNetoT2, isBold: true),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1.0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKeyboardButton('', () {
                  if (_selectedHole != null && _selectedTarjeta != null) {
                    int currentScore = _selectedTarjeta == 1 ? _tarjeta1[_selectedHole!] : _tarjeta2[_selectedHole!];
                    _updateScore(_selectedHole!, _selectedTarjeta!, (currentScore == 0 ? parValue! - 1 : currentScore - 1));
                  }
                }, icon: Icons.remove),
                _buildKeyboardButton('PAR ($parValue)', () {
                  if (_selectedHole != null && _selectedTarjeta != null) {
                    _updateScore(_selectedHole!, _selectedTarjeta!, parValue!);
                  }
                }),
                _buildKeyboardButton('', () {
                  if (_selectedHole != null && _selectedTarjeta != null) {
                    int currentScore = _selectedTarjeta == 1 ? _tarjeta1[_selectedHole!] : _tarjeta2[_selectedHole!];
                    _updateScore(_selectedHole!, _selectedTarjeta!, (currentScore == 0 ? parValue! + 1 : currentScore + 1));
                  }
                }, icon: Icons.add),
                GestureDetector(
                  onLongPress: () {
                    _startListening(); // Iniciar el reconocimiento de voz
                  },
                  onLongPressUp: () {
                    _stopListening(); // Detener el reconocimiento de voz
                  },
                  child: Container(
                    padding: EdgeInsets.all(13.0),
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.green : Colors.blue, // Cambiar color al escuchar
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardButton(String label, VoidCallback onPressed, {IconData? icon}) {
    return SizedBox(
      width: 70,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.blue, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0),
        ),
        child: icon == null
            ? Text(label, style: TextStyle(fontSize: 14))
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.black),
                  if (label.isNotEmpty) ...[
                    SizedBox(width: 8),
                    Text(label, style: TextStyle(fontSize: 14)),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score1, double score2, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ${score1.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.black87,
          ),
        ),
        Text(
          '$label: ${score2.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Modo horizontal (landscape)
  Widget _buildHorizontalGolfCard(
      String tournamentName, String myName, String companionName,
      {required List<int> tarjeta, bool isTarjeta2 = false}) {
    String displayedName = isTarjeta2 ? companionName : myName;

    return Container(
      padding: EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tarjeta para $displayedName', style: TextStyle(fontSize: 16)),
          Text('Torneo: $tournamentName', style: TextStyle(fontSize: 14)),
          SizedBox(height: 4),
          Expanded(child: SingleChildScrollView(child: _buildCompactGolfCard(tarjeta, isTarjeta2: isTarjeta2))),
        ],
      ),
    );
  }

  Widget _buildCompactGolfCard(List<int> tarjeta, {bool isTarjeta2 = false}) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: {
        0: FixedColumnWidth(40),
        for (int i = 1; i < 20; i++) i: FixedColumnWidth(30),
      },
      children: _buildCompactGolfCardRows(tarjeta, isTarjeta2),
    );
  }

  List<TableRow> _buildCompactGolfCardRows(List<int> tarjeta, bool isTarjeta2) {
    List<TableRow> rows = [_buildTableHeader()];

    List<int> pars = _hoyosTarjeta1.map((hoyo) => hoyo.par ?? 0).toList();
    if (pars.isEmpty) pars = List.filled(18, 4);

    String totalGross = isTarjeta2 ? _totalGrossT2.toString() : _totalGrossT1.toString();
    
    rows.addAll([
      _buildDynamicRow('PAR', pars, isTarjeta2: isTarjeta2, totalGross: totalGross),
      _buildDynamicRowHCP('HCP', _hoyosTarjeta1.map((hoyo) => hoyo.handicap ?? 0).toList(), isTarjeta2),
      _buildDynamicRow('GLPS', tarjeta, sumValues: true, isTarjeta2: isTarjeta2, totalGross: totalGross),
    ]);

    return rows;
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        _buildStyledHeaderCell('HOYO'),
        for (int i = 1; i <= 9; i++) _buildStyledHeaderCell('$i'),
        _buildStyledHeaderCell('IDA'),
        for (int i = 10; i <= 18; i++) _buildStyledHeaderCell('$i'),
        _buildStyledHeaderCell('VUELTA'),
      ],
    );
  }

  Widget _buildStyledHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.all(4.0),
      color: Colors.green.shade900,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 8,
          ),
        ),
      ),
    );
  }

  TableRow _buildDynamicRow(String label, List<int> valores, {bool sumValues = false, required bool isTarjeta2, String? totalGross}) {
    valores = valores.length < 18
        ? List<int>.from(valores) + List<int>.filled(18 - valores.length, 0)
        : valores;
    int idaTotal = sumValues ? valores.sublist(0, 9).fold(0, (sum, value) => sum + value) : 0;
    int vueltaTotal = sumValues ? valores.sublist(9, 18).fold(0, (sum, value) => sum + value) : 0;

    return TableRow(
      children: [
        _buildTableCell(label),
        for (int i = 0; i < 9; i++) _buildTableCell(valores[i].toString()),
        _buildTableCell(sumValues ? idaTotal.toString() : ''),
        for (int i = 9; i < 18; i++) _buildTableCell(valores[i].toString()),
        _buildTableCell(sumValues ? vueltaTotal.toString() : ''),
      ],
    );
  }

  TableRow _buildDynamicRowHCP(String label, List<int> valores, bool isTarjeta2) {
    String handicap = isTarjeta2 ? _handicapT2.toString() : _handicapT1.toString();
    String gross = isTarjeta2 ? _totalGrossT2.toString() : _totalGrossT1.toString();
    String neto = isTarjeta2 ? _totalNetoT2.toString() : _totalNetoT1.toString();

    return TableRow(
      children: [
        _buildTableCell(label),
        for (int i = 0; i < 9; i++) _buildTableCell(i < valores.length ? valores[i].toString() : ''),
        _buildTableCell(''),
        for (int i = 9; i < 18; i++) _buildTableCell(i < valores.length ? valores[i].toString() : ''),
        _buildTableCell('$handicap/$gross/$neto'),
      ],
    );
  }

  TableCell _buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          text.isEmpty ? '' : text,
          style: TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Función para iniciar el reconocimiento de voz
  void _startListening() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (val) => print("Estado: $val"),
      );

      if (available) {
        setState(() {
          _isListening = true;  // Actualiza el estado a "escuchando"
        });
        print("Reconocimiento de voz iniciado");

        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              _processSpeechCommand(val.recognizedWords); // Procesar el comando de voz
            } else {
              // Esto permite ver las palabras en proceso antes de que se finalicen
              print("Reconociendo: ${val.recognizedWords}");
            }
          },
          listenFor: Duration(seconds: 30), // Cambia esto a la duración deseada
          partialResults: true, // Permite resultados parciales
          localeId: "es-ES", // Cambia esto al idioma deseado
          onSoundLevelChange: (level) {
            print("Nivel de sonido: $level");
          },
        );
      } else {
        print("El reconocimiento de voz no está disponible");
      }
    } catch (e) {
      print("Error al iniciar el reconocimiento de voz: $e");
    }
  }

  // Función para detener el reconocimiento de voz
  void _stopListening() async {
    try {
      setState(() {
        _isListening = false;
      });
      await _speech.stop();
      print("Reconocimiento de voz detenido");
    } catch (e) {
      print("Error al detener el reconocimiento de voz: $e");
    }
  }

  // Procesa el comando de voz
  void _processSpeechCommand(String command) {
    print("Procesando comando: $command");

    // Convertir palabras numéricas a dígitos
    command = command.toLowerCase();
    if (_wordToNumber.containsKey(command)) {
      command = _wordToNumber[command]!.toString();
    } else {
      command = command.replaceAll(RegExp(r'\D'), '');
    }

    print("Comando limpiado: $command");

    int value = int.tryParse(command) ?? -1;
    print("Valor procesado: $value");

    if (_selectedHole != null && _selectedTarjeta != null && value >= 0) {
      setState(() {
        _updateScore(_selectedHole!, _selectedTarjeta!, value);
        _selectedHole = null;
        _selectedTarjeta = 0;
        _stopListening();
      });
    } else {
      print("Comando inválido o ningún hoyo seleccionado");
      _stopListening();
    }
  }

  void _sendTarjeta() async {
    // Obtener datos del usuario logueado
    final userMatricula = await UserService.getUserMatricula();
    if (userMatricula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay usuario logueado'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_myName.trim().isEmpty || _companionName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se puede enviar la tarjeta sin matrículas válidas para ambos jugadores.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // Obtener los datos de ambas tarjetas
    List<int> scoresTarjeta1 = List.from(_tarjeta1);
    List<int> scoresTarjeta2 = List.from(_tarjeta2);

    try {
      // Llamar al servicio para guardar las tarjetas
      await _fixtureService.saveTarjeta(
        idTorneo: _selectedTournamentId,
        idJugador: int.parse(userMatricula), // Convertir matrícula a int
        idClub: 'C. GOLF DEL URUGUAY', // TODO: Obtener club real
        matriculaCompanion: _matriculaCompanionController.text,
        matriculaMy: _matriculaMyController.text,
        scoresTarjeta1: scoresTarjeta1,
        scoresTarjeta2: scoresTarjeta2,
        totalFairway: _totalFairway,
        totalGreen: _totalGreen,
        totalPutts: _totalPutts,
      );

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarjeta guardada con éxito.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error al guardar las tarjetas: $e');
      // Muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la tarjeta.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _matriculaMyController.dispose();
    _matriculaCompanionController.dispose();
    super.dispose();
  }
}

