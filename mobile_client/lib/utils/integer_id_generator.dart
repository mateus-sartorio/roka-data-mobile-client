import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

int generateIntegerId() {
  var uuid = const Uuid().v4();
  var uuidWithoutDashes = utf8.encode(uuid);
  var digest = sha256.convert(uuidWithoutDashes);
  var hashString = digest.toString();
  return int.parse(hashString.substring(0, 15), radix: 16);
}
