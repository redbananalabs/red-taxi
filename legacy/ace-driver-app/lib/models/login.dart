class Login {
  String? fullName;
  String? regNo;
  int? userId;
  String? token;
  String? tokenExpiry;
  String? refreshToken;
  bool? isAdmin;
  int? roleId;
  dynamic type;
  bool? success;
  String? message; // ✅ API message
  dynamic error;
  dynamic value;

  Login({
    this.fullName,
    this.regNo,
    this.userId,
    this.token,
    this.tokenExpiry,
    this.refreshToken,
    this.isAdmin,
    this.roleId,
    this.type,
    this.success,
    this.message,
    this.error,
    this.value,
  });

  Login.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    regNo = json['regNo'];
    userId = json['userId'];
    token = json['token'];
    tokenExpiry = json['tokenExpiry'];
    refreshToken = json['refreshToken'];
    isAdmin = json['isAdmin'];
    roleId = json['roleId'];
    type = json['type'];
    success = json['success'];
    message = json['message']; // ✅ message
    error = json['error'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['regNo'] = regNo;
    data['userId'] = userId;
    data['token'] = token;
    data['tokenExpiry'] = tokenExpiry;
    data['refreshToken'] = refreshToken;
    data['isAdmin'] = isAdmin;
    data['roleId'] = roleId;
    data['type'] = type;
    data['success'] = success;
    data['message'] = message; // ✅ message
    data['error'] = error;
    data['value'] = value;
    return data;
  }
}
