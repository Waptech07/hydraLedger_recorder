import 'dart:developer';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:voice_recorder/models/pdf_save_model.dart';

import '../models/vocie_save_model.dart';

class DbHelper extends ChangeNotifier {
  Database? _db;

  Future<Database?> get database async {
    var databasesPath = await getDatabasesPath();
    _db ??= await openDatabase(
      join(databasesPath, 'HYDRA'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          VoiceSaveModel.createTable,
        );
        await db.execute(
          PDFSaveModel.createTable,
        );
        await db.execute('''
         CREATE TABLE fs3_proofs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cid TEXT UNIQUE,
          has_created_proof INTEGER
          )
        ''');
        await db.execute('''
         CREATE TABLE fs3_media_details (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cid TEXT UNIQUE,
          event_description TEXT
          )
        ''');
      },
    );
    return _db;
  }

  DbHelper.internal();

  static DbHelper? instance;
  factory DbHelper() {
    instance ??= DbHelper.internal();
    return instance!;
  }

  void deleteTable() async {
    Database? db = await database;
    db!.delete(VoiceSaveModel.tableName);
  }

  Future<void> updateFs3ProofStatus(String cid, bool hasCreatedProof) async {
    final db = await database;
    await db!.insert(
      'fs3_proofs',
      {'cid': cid, 'has_created_proof': hasCreatedProof ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> getFs3ProofStatus(String cid) async {
    final db = await database;
    final result = await db!.query(
      'fs3_proofs',
      where: 'cid = ?',
      whereArgs: [cid],
    );
    return result.isNotEmpty && result.first['has_created_proof'] == 1;
  }

  Future<bool> updateFs3MediaDetails(
    String cid,
    String eventDescription,
  ) async {
    Database? db = await database;
    int result = await db!.insert(
      'fs3_media_details',
      {
        'cid': cid,
        'event_description': eventDescription,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
    return result > 0;
  }

  Future<Map<String, dynamic>?> getFs3MediaDetails(String cid) async {
    Database? db = await database;
    List<Map<String, dynamic>> results = await db!.query(
      'fs3_media_details',
      where: 'cid = ?',
      whereArgs: [cid],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> insertVoice(VoiceSaveModel voice) async {
    if (!Platform.isWindows) {
      Database? db = await database;
      int rowId = await db!.insert(VoiceSaveModel.tableName, voice.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      notifyListeners();
      return rowId > 0;
    } else {
      return Future.value(true);
    }
  }

  Future<bool> removeVoice(VoiceSaveModel voice) async {
    if (!Platform.isWindows) {
      Database? db = await database;
      int rowId = await db!.delete(VoiceSaveModel.tableName,
          where: '${VoiceSaveModel.nameKey} = ? ', whereArgs: [voice.name]);
      notifyListeners();
      return rowId > 0;
    } else {
      return Future.value(true);
    }
  }

  Future<bool> insertPDFDetails(PDFSaveModel pdfSaveModel) async {
    Database? db = await database;
    int rowId = await db!.insert(PDFSaveModel.tableName, pdfSaveModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
    return rowId > 0;
  }

  Future<List<PDFSaveModel>> getPDFsForFilename(String filename) async {
    Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query(PDFSaveModel.tableName,
        where: '${PDFSaveModel.fileNameKey} = ? ', whereArgs: [filename]);
    return maps.map((e) => PDFSaveModel.fromMap(e)).toList();
  }

  Future<bool> removePDFDetails(PDFSaveModel pdfSaveModel) async {
    Database? db = await database;
    int rowId = await db!.delete(PDFSaveModel.tableName,
        where: '${PDFSaveModel.fileNameKey} = ? ',
        whereArgs: [pdfSaveModel.fileName]);
    notifyListeners();
    return rowId > 0;
  }

  Future<bool> updateProduct(VoiceSaveModel prod) async {
    if (!Platform.isWindows) {
      Database? db = await database;
      int rowId = await db!.update(VoiceSaveModel.tableName, prod.toMap(),
          where: '${VoiceSaveModel.nameKey} = ? ', whereArgs: [prod.name]);
      notifyListeners();
      return rowId > 0;
    } else {
      return Future.value(true);
    }
  }

  Future<List<VoiceSaveModel>> fetchProducts() async {
    if (!Platform.isWindows) {
      var db = await database;
      var listOfMaps = await db!.query(VoiceSaveModel.tableName);

      List<VoiceSaveModel> list = listOfMaps.map((e) {
        return VoiceSaveModel.fromMap(e);
      }).toList();
      list.sort((a, b) => b.date!.compareTo(a.date ?? DateTime.now()));

      return list;
    } else {
      return Future.value([]);
    }
  }

  Future<List<PDFSaveModel>> fetchPDFDetails() async {
    try {
      log('wwqwwq');
      var db = await database;
      var listOfMaps = await db!.query(PDFSaveModel.tableName);

      log('wopw002o20');
      List<PDFSaveModel> listPDF = listOfMaps.map((e) {
        return PDFSaveModel.fromMap(e);
      }).toList();
      log('w-w--e');
      return listPDF.reversed.toList();
    } catch (e) {
      log('error while fetching: $e');
      return [];
    }
  }

  Future<bool> updateProofCreatedStatus(
      String name, bool hasCreatedProof) async {
    Database? db = await database;
    int result = await db!.update(VoiceSaveModel.tableName,
        {VoiceSaveModel.hasCreatedProofKey: hasCreatedProof ? 1 : 0},
        where: '${VoiceSaveModel.nameKey} = ?', whereArgs: [name]);
    notifyListeners();
    return result > 0;
  }

  Future<bool> updateVoiceProofDetails(
    String name,
    Map<String, dynamic> proofDetails, {
    String? eventDescription,
  }) async {
    Database? db = await database;
    int result = await db!.update(
        VoiceSaveModel.tableName,
        {
          'deviceId': proofDetails['device_id'],
          'mediaHash': proofDetails['media_hash'],
          'txId': proofDetails['tx_id'],
          'bcProof': proofDetails['bc_proof'],
          'eventDescription': eventDescription,
        },
        where: '${VoiceSaveModel.nameKey} = ?',
        whereArgs: [name]);
    notifyListeners();
    return result > 0;
  }
}
