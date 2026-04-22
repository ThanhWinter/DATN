import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static int get zaloPayAppId =>
      int.tryParse(dotenv.env['ZALOPAY_APP_ID'] ?? '') ?? 553;

  static String get zaloPayKey1 => dotenv.env['ZALOPAY_KEY1'] ?? '';

  static String get zaloPayKey2 => dotenv.env['ZALOPAY_KEY2'] ?? '';
}
