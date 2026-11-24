import 'dart:io';

import 'package:crypto/crypto.dart';

Future<bool> verifyFileSha256(File file, String expectedHexDigest) async {
  final normalizedExpected = expectedHexDigest.trim().toLowerCase();

  if (normalizedExpected.isEmpty) {
    return true;
  }

  final digest = await sha256.bind(file.openRead()).first;

  return digest.toString().toLowerCase() == normalizedExpected;
}
