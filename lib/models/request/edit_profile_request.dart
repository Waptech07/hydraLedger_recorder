class EditProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? zip;
  final String? city;
  final String? address;
  final String? country;
  final String? dob;
  final String? username;
  final String? phoneNumber;
  final String? image;
  final bool? zipChanged;
  final bool? cityChanged;
  final bool? countryChanged;
  final bool? homeAddressChanged;

  EditProfileRequest({
    this.firstName,
    this.lastName,
    this.zip,
    this.city,
    this.address,
    this.country,
    this.dob,
    this.username,
    this.phoneNumber,
    this.image,
    this.zipChanged,
    this.cityChanged,
    this.countryChanged,
    this.homeAddressChanged,
  });

  Map<String, dynamic> toJson() {
    return {
      "data": [
        if (firstName != null || lastName != null)
          {
            "name": {
              if (firstName != null && firstName!.isNotEmpty)
                "first_name": firstName,
              if (lastName != null && lastName!.isNotEmpty)
                "last_name": lastName,
            }
          },
        if (zipChanged ??
            false ||
                (cityChanged ?? false) ||
                (countryChanged ?? false) ||
                (homeAddressChanged ?? false))
          {
            "address": {
              "zip": zip,
              "city": city,
              "address": address,
              "country": country,
            }
          },
        if (dob != null && dob!.isNotEmpty)
          {
            "dob": dob,
          },
        if (username != null && username!.isNotEmpty)
          {
            "username": username,
          },
        if (phoneNumber != null && phoneNumber!.isNotEmpty)
          {
            "phone_number": phoneNumber,
          },
        if (image != null && image!.isNotEmpty)
          {
            "image": image,
          }
      ]
    };
  }
}
