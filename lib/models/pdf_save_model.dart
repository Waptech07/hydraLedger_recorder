// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PDFSaveModel {
  String? userName;
  String? fileName;
  String? email;
  String? description;
  String? hash;
  String? bcExplorer;
  String? transactionID;
  String? timeStamp;
  String? registeredContent;
  String? uri;
  String? bcProof; // New field

  static const tableName = 'PdfSave';
  static const userNameKey = 'userName';
  static const fileNameKey = 'fileName';
  static const emailKey = 'email';
  static const descriptionKey = 'description';
  static const hashKey = 'hash';
  static const bcExplorerKey = 'bcExplorer';
  static const transactionIDKey = 'transactionID';
  static const timeStampKey = 'timeStamp';
  static const registeredContentKey = 'registeredContent';
  static const uriKey = 'uri';
  static const bcProofKey = 'bcProof'; // New key

  static const createTable =
      'CREATE TABLE IF NOT EXISTS $tableName ($timeStampKey TEXT PRIMARY KEY, $userNameKey TEXT, $fileNameKey TEXT, $emailKey TEXT, $descriptionKey TEXT, $hashKey TEXT, $bcExplorerKey TEXT, $transactionIDKey TEXT, $registeredContentKey TEXT, $uriKey TEXT, $bcProofKey TEXT)';

  PDFSaveModel({
    this.userName,
    this.fileName,
    this.email,
    this.description,
    this.hash,
    this.bcExplorer,
    this.transactionID,
    this.timeStamp,
    this.registeredContent,
    this.uri,
    this.bcProof, // New parameter
  });

  PDFSaveModel copyWith({
    String? userName,
    String? fileName,
    String? email,
    String? description,
    String? hash,
    String? bcExplorer,
    String? transactionID,
    String? timeStamp,
    String? registeredContent,
    String? uri,
    String? bcProof, // New parameter
  }) {
    return PDFSaveModel(
      userName: userName ?? this.userName,
      fileName: fileName ?? this.fileName,
      email: email ?? this.email,
      description: description ?? this.description,
      hash: hash ?? this.hash,
      bcExplorer: bcExplorer ?? this.bcExplorer,
      transactionID: transactionID ?? this.transactionID,
      timeStamp: timeStamp ?? this.timeStamp,
      registeredContent: registeredContent ?? this.registeredContent,
      uri: uri ?? this.uri,
      bcProof: bcProof ?? this.bcProof, // New field
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'fileName': fileName,
      'email': email,
      'description': description,
      'hash': hash,
      'bcExplorer': bcExplorer,
      'transactionID': transactionID,
      'timeStamp': timeStamp,
      'registeredContent': registeredContent,
      'uri': uri,
      'bcProof': bcProof, // New field
    };
  }

  factory PDFSaveModel.fromMap(Map<String, dynamic> map) {
    return PDFSaveModel(
      userName: map['userName'] != null ? map['userName'] as String : null,
      fileName: map['fileName'] != null ? map['fileName'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      hash: map['hash'] != null ? map['hash'] as String : null,
      bcExplorer:
          map['bcExplorer'] != null ? map['bcExplorer'] as String : null,
      transactionID:
          map['transactionID'] != null ? map['transactionID'] as String : null,
      timeStamp: map['timeStamp'] != null ? map['timeStamp'] as String : null,
      registeredContent: map['registeredContent'] != null
          ? map['registeredContent'] as String
          : null,
      uri: map['uri'] != null ? map['uri'] as String : null,
      bcProof:
          map['bcProof'] != null ? map['bcProof'] as String : null, // New field
    );
  }

  String toJson() => json.encode(toMap());

  factory PDFSaveModel.fromJson(String source) =>
      PDFSaveModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PDFSaveModel(userName: $userName, fileName: $fileName, email: $email, description: $description, hash: $hash, bcExplorer: $bcExplorer, transactionID: $transactionID, timeStamp: $timeStamp, registeredContent: $registeredContent, uri: $uri, bcProof: $bcProof)';
  }

  @override
  bool operator ==(covariant PDFSaveModel other) {
    if (identical(this, other)) return true;

    return other.userName == userName &&
        other.fileName == fileName &&
        other.email == email &&
        other.description == description &&
        other.hash == hash &&
        other.bcExplorer == bcExplorer &&
        other.transactionID == transactionID &&
        other.timeStamp == timeStamp &&
        other.registeredContent == registeredContent &&
        other.uri == uri &&
        other.bcProof == bcProof; // New field
  }

  @override
  int get hashCode {
    return userName.hashCode ^
        fileName.hashCode ^
        email.hashCode ^
        description.hashCode ^
        hash.hashCode ^
        bcExplorer.hashCode ^
        transactionID.hashCode ^
        timeStamp.hashCode ^
        registeredContent.hashCode ^
        uri.hashCode ^
        bcProof.hashCode; // New field
  }
}
