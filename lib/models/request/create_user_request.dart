class CreateUserRequest {
  String? firstName;
  String? lastName;
  String? email;
  String? username;
  String? password;
  String? passwordHint;
  String? dob;
  String? address;
  String? city;
  String? zip;
  String? country;
  String? phoneNumber;

  CreateUserRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.password,
    this.passwordHint,
    this.dob,
    this.address,
    this.city,
    this.zip,
    this.country,
    this.phoneNumber,
  });

  CreateUserRequest.fromJson(Map<String, dynamic> json) {
    firstName = json["first_name"];
    lastName = json["last_name"];
    email = json["email"];
    username = json["username"];
    password = json["password"];
    passwordHint = json["password_hint"];
    dob = json["dob"];
    address = json["address"];
    city = json["city"];
    zip = json["zip"];
    country = json["country"];
    phoneNumber = json["phone_number"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['username'] = username;
    data['password'] = password;
    data['password_hint'] = passwordHint;
    data['dob'] = dob;
    data['address'] = address;
    data['city'] = city;
    data['zip'] = zip;
    data['country'] = country;
    data['phone_number'] = phoneNumber;
    return data;
  }
}
