class Profile {
  String? fullName;
  String? regNo;
  String? phone;
  String? email;
  String? vehicleMake;
  String? vehicleModel;
  String? vehicleRegNo;
  String? vehicleColor;
  bool? success;
  String? message;

  Profile({
    this.fullName,
    this.regNo,
    this.phone,
    this.email,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleRegNo,
    this.vehicleColor,
    this.success,
    this.message,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      fullName: json['fullname'] ?? "",
      phone: json['telephone'] ?? "",
      email: json['email'] ?? "",
      vehicleMake: json['vehicleMake'] ?? "",
      vehicleModel: json['vehicleModel'] ?? "",
      vehicleRegNo: json['vehicleReg'] ?? "",
      vehicleColor: json['vehicleColour'] ?? "",
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullName,
      'telephone': phone,
      'email': email,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleReg': vehicleRegNo,
      'vehicleColour': vehicleColor,
      'success': success,
      'message': message,
    };
  }
}
