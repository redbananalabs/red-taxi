import 'package:uuid/uuid.dart';

class AddressSessionManager {
  String? _token;
  final _uuid = const Uuid();

  String getToken() {
    _token ??= _uuid.v4();
    return _token!;
  }

  void resetToken() {
    _token = null;
  }
}