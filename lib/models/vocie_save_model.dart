// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/services.dart';

class VoiceSaveModel {
  String? name;
  String? path;
  String? playPath;
  String? duration;
  DateTime? date;
  String? consumableID;
  Uint8List? hashBytes;
  bool? hasCreatedProof;
  String? deviceId;
  String? mediaHash;
  String? txId;
  String? bcProof;
  String? eventDescription;

  static const tableName = 'VoicesSave';
  static const nameKey = 'name';
  static const pathKey = 'path';
  static const playPathKey = 'playPath';
  static const durationTimeKey = 'duration';
  static const recordDateKey = 'date';
  static const consumableIDKey = 'consumableID';
  static const hashBytesKey = 'hashBytes';
  static const hasCreatedProofKey = 'hasCreatedProof';
  static const deviceIdKey = 'deviceId';
  static const mediaHashKey = 'mediaHash';
  static const txIdKey = 'txId';
  static const bcProofKey = 'bcProof';
  static const eventDescriptionKey = 'eventDescription';

  static const createTable =
      'CREATE TABLE IF NOT EXISTS $tableName ($nameKey TEXT PRIMARY KEY, $pathKey TEXT, $durationTimeKey TEXT, $recordDateKey TEXT, $playPathKey TEXT, $consumableIDKey TEXT, $hashBytesKey TEXT, $hasCreatedProofKey INTEGER, $deviceIdKey TEXT, $mediaHashKey TEXT, $txIdKey TEXT, $bcProofKey TEXT, $eventDescriptionKey TEXT)';

  VoiceSaveModel(
      {this.name,
      this.path,
      this.playPath,
      this.duration,
      this.date,
      this.consumableID,
      this.hashBytes,
      this.hasCreatedProof,
      this.deviceId,
      this.mediaHash,
      this.txId,
      this.bcProof,
      this.eventDescription});

  VoiceSaveModel copyWith({
    String? name,
    String? path,
    String? playPath,
    String? duration,
    DateTime? date,
    String? consumableID,
    Uint8List? hashBytes,
    // bool? hasCreatedProof,
  }) {
    return VoiceSaveModel(
      name: name ?? this.name,
      path: path ?? this.path,
      playPath: playPath ?? this.playPath,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      consumableID: consumableID ?? this.consumableID,
      hashBytes: hashBytes ?? this.hashBytes,
      // hasCreatedProof: hasCreatedProof ?? this.hasCreatedProof,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'playPath': playPath,
      'duration': duration,
      'date': date.toString(),
      'consumableID': consumableID,
      'hashBytes': hashBytes?.toList(),
      // 'hashBytes': hashBytes,
      'hasCreatedProof': hasCreatedProof,
      'deviceId': deviceId,
      'mediaHash': mediaHash,
      'txId': txId,
      'bcProof': bcProof,
      'eventDescription': eventDescription,
    };
  }

  factory VoiceSaveModel.fromMap(Map<String, dynamic> map) {
    return VoiceSaveModel(
      name: map['name'] as String,
      path: map['path'] as String,
      playPath: map['playPath'] as String,
      duration: map['duration'] as String,
      date: DateTime.parse(map['date']),
      consumableID:
          map['consumableID'] != null ? map['consumableID'] as String : null,
      hashBytes: map['hashBytes'] != null
          ? Uint8List.fromList(List<int>.from(map['hashBytes']))
          : null,

      // hashBytes: map['hashBytes'] as Uint8List,
      hasCreatedProof: map['hasCreatedProof'] == 1,
      deviceId: map['deviceId'],
      mediaHash: map['mediaHash'],
      txId: map['txId'],
      bcProof: map['bcProof'],
      eventDescription: map['eventDescription'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VoiceSaveModel.fromJson(String source) =>
      VoiceSaveModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'VoiceSaveModel(name: $name, path: $path, playPath: $playPath, duration: $duration, date: $date, consumableID: $consumableID, hashBytes: $hashBytes,)';
  }

  @override
  bool operator ==(covariant VoiceSaveModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.path == path &&
        other.playPath == playPath &&
        other.duration == duration &&
        other.date == date &&
        other.consumableID == consumableID &&
        other.hashBytes == hashBytes;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        path.hashCode ^
        playPath.hashCode ^
        duration.hashCode ^
        date.hashCode ^
        consumableID.hashCode ^
        hashBytes.hashCode;
  }
}
