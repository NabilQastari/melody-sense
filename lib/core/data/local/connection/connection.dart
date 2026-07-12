import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Membuka (atau membuat) file melody_sense.sqlite di direktori dokumen app.
QueryExecutor connect() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'melody_sense.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
