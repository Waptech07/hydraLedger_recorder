class CreateUserResponse {
  Data? data;
  String? mnemonic;

  CreateUserResponse({
    this.data,
    this.mnemonic,
  });

  CreateUserResponse.fromJson(Map<String, dynamic> json) {
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
    mnemonic = json["mnemonic"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.toJson();
    data['mnemonic'] = mnemonic;
    return data;
  }
}

class Data {
  String? id;
  String? hydVault;
  String? morpheusVault;
  String? wallet;
  String? did;

  Data({
    this.id,
    this.hydVault,
    this.morpheusVault,
    this.wallet,
    this.did,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    hydVault = json["hyd_vault"];
    morpheusVault = json["morpheus_vault"];
    wallet = json["wallet"];
    did = json["did"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['hyd_vault'] = hydVault;
    data['morpheus_vault'] = morpheusVault;
    data['wallet'] = wallet;
    data['did'] = did;
    return data;
  }
}
