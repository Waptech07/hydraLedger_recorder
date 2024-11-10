class MorpheusSignStatementRequest {
  String? vault;
  String? password;
  Statement? statement;

  MorpheusSignStatementRequest({
    this.vault,
    this.password,
    this.statement,
  });

  factory MorpheusSignStatementRequest.fromJson(Map<String, dynamic> json) =>
      MorpheusSignStatementRequest(
        vault: json["vault"],
        password: json["password"],
        statement: json["statement"] == null
            ? null
            : Statement.fromJson(json["statement"]),
      );

  Map<String, dynamic> toJson() => {
        "vault": vault,
        "password": password,
        "statement": statement?.toJson(),
      };
}

class Statement {
  Claim? claim;
  String? processId;
  Constraints? constraints;
  String? nonce;

  Statement({
    this.claim,
    this.processId,
    this.constraints,
    this.nonce,
  });

  factory Statement.fromJson(Map<String, dynamic> json) => Statement(
        claim: json["claim"] == null ? null : Claim.fromJson(json["claim"]),
        processId: json["processId"],
        constraints: json["constraints"] == null
            ? null
            : Constraints.fromJson(json["constraints"]),
        nonce: json["nonce"],
      );

  Map<String, dynamic> toJson() => {
        "claim": claim?.toJson(),
        "processId": processId,
        "constraints": constraints?.toJson(),
        "nonce": nonce,
      };
}

class Claim {
  String? subject;
  Content? content;

  Claim({
    this.subject,
    this.content,
  });

  factory Claim.fromJson(Map<String, dynamic> json) => Claim(
        subject: json["subject"],
        content:
            json["content"] == null ? null : Content.fromJson(json["content"]),
      );

  Map<String, dynamic> toJson() => {
        "subject": subject,
        "content": content?.toJson(),
      };
}

class Content {
  String? userId;
  BirthDate? fullName;
  BirthDate? birthDate;
  Address? address;

  Content({
    this.userId,
    this.fullName,
    this.birthDate,
    this.address,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        userId: json["userId"],
        fullName: json["fullName"] == null
            ? null
            : BirthDate.fromJson(json["fullName"]),
        birthDate: json["birthDate"] == null
            ? null
            : BirthDate.fromJson(json["birthDate"]),
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "fullName": fullName?.toJson(),
        "birthDate": birthDate?.toJson(),
        "address": address?.toJson(),
      };
}

class Address {
  String? nonce;
  Value? value;

  Address({
    this.nonce,
    this.value,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        nonce: json["nonce"],
        value: json["value"] == null ? null : Value.fromJson(json["value"]),
      );

  Map<String, dynamic> toJson() => {
        "nonce": nonce,
        "value": value?.toJson(),
      };
}

class Value {
  BirthDate? country;
  BirthDate? city;
  BirthDate? street;
  BirthDate? zipcode;

  Value({
    this.country,
    this.city,
    this.street,
    this.zipcode,
  });

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        country: json["country"] == null
            ? null
            : BirthDate.fromJson(json["country"]),
        city: json["city"] == null ? null : BirthDate.fromJson(json["city"]),
        street:
            json["street"] == null ? null : BirthDate.fromJson(json["street"]),
        zipcode: json["zipcode"] == null
            ? null
            : BirthDate.fromJson(json["zipcode"]),
      );

  Map<String, dynamic> toJson() => {
        "country": country?.toJson(),
        "city": city?.toJson(),
        "street": street?.toJson(),
        "zipcode": zipcode?.toJson(),
      };
}

class BirthDate {
  String? nonce;
  String? value;

  BirthDate({
    this.nonce,
    this.value,
  });

  factory BirthDate.fromJson(Map<String, dynamic> json) => BirthDate(
        nonce: json["nonce"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "nonce": nonce,
        "value": value,
      };
}

class Constraints {
  String? authority;
  String? witness;
  dynamic content;

  Constraints({
    this.authority,
    this.witness,
    this.content,
  });

  factory Constraints.fromJson(Map<String, dynamic> json) => Constraints(
        authority: json["authority"],
        witness: json["witness"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "authority": authority,
        "witness": witness,
        "content": content,
      };
}
