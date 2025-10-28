import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../models/score.dart';

class HiveConfig {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(HoyoAdapter());
    Hive.registerAdapter(BochaAdapter());
    Hive.registerAdapter(ClubAdapter());
    Hive.registerAdapter(UsuarioAdapter());
    Hive.registerAdapter(TarjetaAdapter());
    Hive.registerAdapter(TarjetaScoresAdapter());
  }

  static Future<void> openBoxes() async {
    await Hive.openBox<Hoyo>('hoyos');
    await Hive.openBox<Bocha>('bochas');
    await Hive.openBox<Club>('clubs');
    await Hive.openBox<Usuario>('usuarios');
    await Hive.openBox<Tarjeta>('tarjetas');
    await Hive.openBox<TarjetaScores>('scores');
  }

  static Future<void> closeBoxes() async {
    await Hive.box<Hoyo>('hoyos').close();
    await Hive.box<Bocha>('bochas').close();
    await Hive.box<Club>('clubs').close();
    await Hive.box<Usuario>('usuarios').close();
    await Hive.box<Tarjeta>('tarjetas').close();
    await Hive.box<TarjetaScores>('scores').close();
  }

  static Future<void> clearAll() async {
    await Hive.box<Hoyo>('hoyos').clear();
    await Hive.box<Bocha>('bochas').clear();
    await Hive.box<Club>('clubs').clear();
    await Hive.box<Usuario>('usuarios').clear();
    await Hive.box<Tarjeta>('tarjetas').clear();
    await Hive.box<TarjetaScores>('scores').clear();
  }
}

