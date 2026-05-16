class AddressModel {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  AddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory AddressModel.fromMap(Map<String, dynamic> data) {
    return AddressModel(
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'street': street, 'city': city, 'state': state, 'zipCode': zipCode};
  }

  bool get isEmpty => street.isEmpty && city.isEmpty;
}
