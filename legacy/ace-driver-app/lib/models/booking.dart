// import 'dart:convert';

// class Bookings {
//   String? regNo;
//   dynamic backgroundColorRGB;
//   dynamic fullname;
//   int? bookingId;
//   int? userId;
//   dynamic suggestedUserId;
//   bool? cancelledOnArrival;
//   String? cellText;
//   String? hasDetails;
//   int? status;
//   String? endTime;
//   String? dateCreated;
//   String? bookedByName;
//   bool? cancelled;
//   String? details;
//   String? email;
//   int? durationMinutes;
//   bool? isAllDay;
//   String? passengerName;
//   int? passengers;
//   int? paymentStatus;
//   int? confirmationStatus;
//   int? scope;
//   String? phoneNumber;
//   String? pickupAddress;
//   String? pickupDateTime;
//   String? arriveBy;
//   String? pickupPostCode;
//   String? destinationAddress;
//   String? destinationPostCode;
//   List<dynamic>? vias;
//   dynamic recurrenceException;
//   dynamic recurrenceID;
//   dynamic recurrenceRule;
//   String? updatedByName;
//   String? cancelledByName;
//   double? price;
//   bool? manuallyPriced;
//   double? priceDiscount;
//   double? priceAccount;
//   double? mileage;
//   String? mileageText;
//   String? durationText;
//   bool? chargeFromBase;
//   int? actionByUserId;
//   int? accountNumber;
//   double? parkingCharge;
//   int? waitingTimeMinutes;
//   dynamic paymentLinkSentOn;
//   dynamic paymentLinkSentBy;
//   bool? isASAP;
//   int? navId;

//   Bookings({
//     this.regNo,
//     this.backgroundColorRGB,
//     this.fullname,
//     this.bookingId,
//     this.userId,
//     this.suggestedUserId,
//     this.cancelledOnArrival,
//     this.cellText,
//     this.hasDetails,
//     this.status,
//     this.endTime,
//     this.dateCreated,
//     this.bookedByName,
//     this.cancelled,
//     this.details,
//     this.email,
//     this.durationMinutes,
//     this.isAllDay,
//     this.passengerName,
//     this.passengers,
//     this.paymentStatus,
//     this.confirmationStatus,
//     this.scope,
//     this.phoneNumber,
//     this.pickupAddress,
//     this.pickupDateTime,
//     this.arriveBy,
//     this.pickupPostCode,
//     this.destinationAddress,
//     this.destinationPostCode,
//     this.vias,
//     this.recurrenceException,
//     this.recurrenceID,
//     this.recurrenceRule,
//     this.updatedByName,
//     this.cancelledByName,
//     this.price,
//     this.manuallyPriced,
//     this.priceDiscount,
//     this.priceAccount,
//     this.mileage,
//     this.mileageText,
//     this.durationText,
//     this.chargeFromBase,
//     this.actionByUserId,
//     this.accountNumber,
//     this.parkingCharge,
//     this.waitingTimeMinutes,
//     this.paymentLinkSentOn,
//     this.paymentLinkSentBy,
//     this.isASAP,
//     this.navId,
//   });

//   // =================================================================
//   // SAFE TYPE CONVERTERS
//   // =================================================================
//   static int? _toInt(dynamic value) {
//     if (value == null) return null;
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value);
//     return null;
//   }

//   static double? _toDouble(dynamic value) {
//     if (value == null) return null;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value);
//     return null;
//   }

//   static bool? _toBool(dynamic value) {
//     if (value == null) return null;
//     if (value is bool) return value;
//     if (value is int) return value == 1;
//     if (value is String) {
//       final lower = value.toLowerCase();
//       return lower == 'true' || lower == '1' || lower == 'yes';
//     }
//     return null;
//   }

//   static String? _toString(dynamic value) {
//     if (value == null) return null;
//     return value.toString();
//   }

//   // =================================================================
//   // FACTORY: fromJson — NOW 100% SAFE FOR YOUR API
//   // =================================================================
//   factory Bookings.fromJson(Map<String, dynamic> json) {
//     return Bookings(
//       regNo: _toString(json['regNo']),
//       backgroundColorRGB: json['backgroundColorRGB'],
//       fullname: json['fullname'],
//       bookingId: _toInt(json['bookingId']),
//       userId: _toInt(json['userId']),
//       suggestedUserId: json['suggestedUserId'],
//       cancelledOnArrival: _toBool(json['cancelledOnArrival']),
//       cellText: _toString(json['cellText']),
//       hasDetails: _toString(json['hasDetails']),
//       status: _toInt(json['status']),
//       endTime: _toString(json['endTime']),
//       dateCreated: _toString(json['dateCreated']),
//       bookedByName: _toString(json['bookedByName']),
//       cancelled: _toBool(json['cancelled']),
//       details: _toString(json['details']),
//       email: _toString(json['email']),
//       durationMinutes: _toInt(json['durationMinutes']),
//       isAllDay: _toBool(json['isAllDay']),
//       passengerName: _toString(json['passengerName']),
//       passengers: _toInt(json['passengers']),
//       paymentStatus: _toInt(json['paymentStatus']),
//       confirmationStatus: _toInt(json['confirmationStatus']),
//       scope: _toInt(json['scope']),
//       phoneNumber: _toString(json['phoneNumber']),
//       pickupAddress: _toString(json['pickupAddress']),
//       pickupDateTime: _toString(json['pickupDateTime']),
//       arriveBy: _toString(json['arriveBy']), // ← This was dynamic before → crash!
//       pickupPostCode: _toString(json['pickupPostCode']),
//       destinationAddress: _toString(json['destinationAddress']),
//       destinationPostCode: _toString(json['destinationPostCode']),
//       vias: json['vias'] is List ? json['vias'] : null,
//       recurrenceException: json['recurrenceException'],
//       recurrenceID: json['recurrenceID'],
//       recurrenceRule: json['recurrenceRule'],
//       updatedByName: _toString(json['updatedByName']),
//       cancelledByName: _toString(json['cancelledByName']),
//       price: _toDouble(json['price']),
//       manuallyPriced: _toBool(json['manuallyPriced']),
//       priceDiscount: _toDouble(json['priceDiscount']),
//       priceAccount: _toDouble(json['priceAccount']),
//       mileage: _toDouble(json['mileage']),
//       mileageText: _toString(json['mileageText']),
//       durationText: _toString(json['durationText']),
//       chargeFromBase: _toBool(json['chargeFromBase']),
//       actionByUserId: _toInt(json['actionByUserId']),
//       accountNumber: _toInt(json['accountNumber']),
//       parkingCharge: _toDouble(json['parkingCharge']),
//       waitingTimeMinutes: _toInt(json['waitingTimeMinutes']),
//       paymentLinkSentOn: json['paymentLinkSentOn'],
//       paymentLinkSentBy: json['paymentLinkSentBy'],
//       isASAP: _toBool(json['isASAP']),
//       navId: _toInt(json['navId'] ?? json['NavId']),
//     );
//   }

//   // =================================================================
//   // toJson — For sending back to server if needed
//   // =================================================================
//   Map<String, dynamic> toJson() {
//     return {
//       'regNo': regNo,
//       'backgroundColorRGB': backgroundColorRGB,
//       'fullname': fullname,
//       'bookingId': bookingId,
//       'userId': userId,
//       'suggestedUserId': suggestedUserId,
//       'cancelledOnArrival': cancelledOnArrival,
//       'cellText': cellText,
//       'hasDetails': hasDetails,
//       'status': status,
//       'endTime': endTime,
//       'dateCreated': dateCreated,
//       'bookedByName': bookedByName,
//       'cancelled': cancelled,
//       'details': details,
//       'email': email,
//       'durationMinutes': durationMinutes,
//       'isAllDay': isAllDay,
//       'passengerName': passengerName,
//       'passengers': passengers,
//       'paymentStatus': paymentStatus,
//       'confirmationStatus': confirmationStatus,
//       'scope': scope,
//       'phoneNumber': phoneNumber,
//       'pickupAddress': pickupAddress,
//       'pickupDateTime': pickupDateTime,
//       'arriveBy': arriveBy,
//       'pickupPostCode': pickupPostCode,
//       'destinationAddress': destinationAddress,
//       'destinationPostCode': destinationPostCode,
//       'vias': vias,
//       'recurrenceException': recurrenceException,
//       'recurrenceID': recurrenceID,
//       'recurrenceRule': recurrenceRule,
//       'updatedByName': updatedByName,
//       'cancelledByName': cancelledByName,
//       'price': price,
//       'manuallyPriced': manuallyPriced,
//       'priceDiscount': priceDiscount,
//       'priceAccount': priceAccount,
//       'mileage': mileage,
//       'mileageText': mileageText,
//       'durationText': durationText,
//       'chargeFromBase': chargeFromBase,
//       'actionByUserId': actionByUserId,
//       'accountNumber': accountNumber,
//       'parkingCharge': parkingCharge,
//       'waitingTimeMinutes': waitingTimeMinutes,
//       'paymentLinkSentOn': paymentLinkSentOn,
//       'paymentLinkSentBy': paymentLinkSentBy,
//       'isASAP': isASAP,
//       'navId': navId,
//     }..removeWhere((key, value) => value == null);
//   }

//   // Optional: copyWith for merging partial data
//   Bookings copyWith({
//     int? bookingId,
//     String? passengerName,
//     String? pickupAddress,
//     // Add others as needed
//   }) {
//     return Bookings(
//       bookingId: bookingId ?? this.bookingId,
//       passengerName: passengerName ?? this.passengerName,
//       pickupAddress: pickupAddress ?? this.pickupAddress,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       destinationAddress: destinationAddress ?? this.destinationAddress,
//       price: price ?? this.price,
//       pickupDateTime: pickupDateTime ?? this.pickupDateTime,
//       vias: vias ?? this.vias,
//       isASAP: isASAP ?? this.isASAP,
//       // ... copy others
//     );
//   }
// }

import 'dart:convert';

class Bookings {
  String? regNo;
  dynamic backgroundColorRGB;
  dynamic fullname;
  int? bookingId;
  int? userId;
  dynamic suggestedUserId;
  bool? cancelledOnArrival;
  String? cellText;
  String? hasDetails;
  int? status;
  String? endTime;
  String? dateCreated;
  String? bookedByName;
  bool? cancelled;
  String? details;
  String? email;
  int? durationMinutes;
  bool? isAllDay;
  String? passengerName;
  int? passengers;
  int? paymentStatus;
  int? confirmationStatus;
  int? scope;
  String? phoneNumber;
  String? pickupAddress;
  String? pickupDateTime;
  String? arriveBy;
  String? pickupPostCode;
  String? destinationAddress;
  String? destinationPostCode;
  List<dynamic>? vias;
  dynamic recurrenceException;
  dynamic recurrenceID;
  dynamic recurrenceRule;
  String? updatedByName;
  String? cancelledByName;
  double? price;
  bool? manuallyPriced;
  double? priceDiscount;
  double? priceAccount;
  double? mileage;
  String? mileageText;
  String? durationText;
  bool? chargeFromBase;
  int? actionByUserId;
  int? accountNumber;
  double? parkingCharge;
  int? waitingTimeMinutes;
  dynamic paymentLinkSentOn;
  dynamic paymentLinkSentBy;
  bool? isASAP;
  int? navId;

  // 🔥 JOB OFFER GUID (NEW)
  String? guid;

  Bookings({
    this.regNo,
    this.backgroundColorRGB,
    this.fullname,
    this.bookingId,
    this.userId,
    this.suggestedUserId,
    this.cancelledOnArrival,
    this.cellText,
    this.hasDetails,
    this.status,
    this.endTime,
    this.dateCreated,
    this.bookedByName,
    this.cancelled,
    this.details,
    this.email,
    this.durationMinutes,
    this.isAllDay,
    this.passengerName,
    this.passengers,
    this.paymentStatus,
    this.confirmationStatus,
    this.scope,
    this.phoneNumber,
    this.pickupAddress,
    this.pickupDateTime,
    this.arriveBy,
    this.pickupPostCode,
    this.destinationAddress,
    this.destinationPostCode,
    this.vias,
    this.recurrenceException,
    this.recurrenceID,
    this.recurrenceRule,
    this.updatedByName,
    this.cancelledByName,
    this.price,
    this.manuallyPriced,
    this.priceDiscount,
    this.priceAccount,
    this.mileage,
    this.mileageText,
    this.durationText,
    this.chargeFromBase,
    this.actionByUserId,
    this.accountNumber,
    this.parkingCharge,
    this.waitingTimeMinutes,
    this.paymentLinkSentOn,
    this.paymentLinkSentBy,
    this.isASAP,
    this.navId,
    this.guid, // ✅ added
  });

  // =================================================================
  // SAFE TYPE CONVERTERS
  // =================================================================
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    return null;
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // =================================================================
  // FACTORY: fromJson — SAFE FOR ALL APIs
  // =================================================================
  factory Bookings.fromJson(Map<String, dynamic> json) {
    return Bookings(
      regNo: _toString(json['regNo']),
      backgroundColorRGB: json['backgroundColorRGB'],
      fullname: json['fullname'],
      bookingId: _toInt(json['bookingId']),
      userId: _toInt(json['userId']),
      suggestedUserId: json['suggestedUserId'],
      cancelledOnArrival: _toBool(json['cancelledOnArrival']),
      cellText: _toString(json['cellText']),
      hasDetails: _toString(json['hasDetails']),
      status: _toInt(json['status']),
      endTime: _toString(json['endTime']),
      dateCreated: _toString(json['dateCreated']),
      bookedByName: _toString(json['bookedByName']),
      cancelled: _toBool(json['cancelled']),
      details: _toString(json['details']),
      email: _toString(json['email']),
      durationMinutes: _toInt(json['durationMinutes']),
      isAllDay: _toBool(json['isAllDay']),
      passengerName: _toString(json['passengerName']),
      passengers: _toInt(json['passengers']),
      paymentStatus: _toInt(json['paymentStatus']),
      confirmationStatus: _toInt(json['confirmationStatus']),
      scope: _toInt(json['scope']),
      phoneNumber: _toString(json['phoneNumber']),
      pickupAddress: _toString(json['pickupAddress']),
      pickupDateTime: _toString(json['pickupDateTime']),
      arriveBy: _toString(json['arriveBy']),
      pickupPostCode: _toString(json['pickupPostCode']),
      destinationAddress: _toString(json['destinationAddress']),
      destinationPostCode: _toString(json['destinationPostCode']),
      vias: json['vias'] is List ? json['vias'] : null,
      recurrenceException: json['recurrenceException'],
      recurrenceID: json['recurrenceID'],
      recurrenceRule: json['recurrenceRule'],
      updatedByName: _toString(json['updatedByName']),
      cancelledByName: _toString(json['cancelledByName']),
      price: _toDouble(json['price']),
      manuallyPriced: _toBool(json['manuallyPriced']),
      priceDiscount: _toDouble(json['priceDiscount']),
      priceAccount: _toDouble(json['priceAccount']),
      mileage: _toDouble(json['mileage']),
      mileageText: _toString(json['mileageText']),
      durationText: _toString(json['durationText']),
      chargeFromBase: _toBool(json['chargeFromBase']),
      actionByUserId: _toInt(json['actionByUserId']),
      accountNumber: _toInt(json['accountNumber']),
      parkingCharge: _toDouble(json['parkingCharge']),
      waitingTimeMinutes: _toInt(json['waitingTimeMinutes']),
      paymentLinkSentOn: json['paymentLinkSentOn'],
      paymentLinkSentBy: json['paymentLinkSentBy'],
      isASAP: _toBool(json['isASAP']),
      navId: _toInt(json['navId'] ?? json['NavId']),
      guid: _toString(json['guid']), // 🔥 JOB OFFER GUID
    );
  }

  // =================================================================
  // toJson
  // =================================================================
  Map<String, dynamic> toJson() {
    return {
      'regNo': regNo,
      'backgroundColorRGB': backgroundColorRGB,
      'fullname': fullname,
      'bookingId': bookingId,
      'userId': userId,
      'suggestedUserId': suggestedUserId,
      'cancelledOnArrival': cancelledOnArrival,
      'cellText': cellText,
      'hasDetails': hasDetails,
      'status': status,
      'endTime': endTime,
      'dateCreated': dateCreated,
      'bookedByName': bookedByName,
      'cancelled': cancelled,
      'details': details,
      'email': email,
      'durationMinutes': durationMinutes,
      'isAllDay': isAllDay,
      'passengerName': passengerName,
      'passengers': passengers,
      'paymentStatus': paymentStatus,
      'confirmationStatus': confirmationStatus,
      'scope': scope,
      'phoneNumber': phoneNumber,
      'pickupAddress': pickupAddress,
      'pickupDateTime': pickupDateTime,
      'arriveBy': arriveBy,
      'pickupPostCode': pickupPostCode,
      'destinationAddress': destinationAddress,
      'destinationPostCode': destinationPostCode,
      'vias': vias,
      'recurrenceException': recurrenceException,
      'recurrenceID': recurrenceID,
      'recurrenceRule': recurrenceRule,
      'updatedByName': updatedByName,
      'cancelledByName': cancelledByName,
      'price': price,
      'manuallyPriced': manuallyPriced,
      'priceDiscount': priceDiscount,
      'priceAccount': priceAccount,
      'mileage': mileage,
      'mileageText': mileageText,
      'durationText': durationText,
      'chargeFromBase': chargeFromBase,
      'actionByUserId': actionByUserId,
      'accountNumber': accountNumber,
      'parkingCharge': parkingCharge,
      'waitingTimeMinutes': waitingTimeMinutes,
      'paymentLinkSentOn': paymentLinkSentOn,
      'paymentLinkSentBy': paymentLinkSentBy,
      'isASAP': isASAP,
      'navId': navId,
      'guid': guid,
    }..removeWhere((key, value) => value == null);
  }

  // =================================================================
  // copyWith
  // =================================================================
  Bookings copyWith({
    int? bookingId,
    String? passengerName,
    String? pickupAddress,
    String? guid,
  }) {
    return Bookings(
      bookingId: bookingId ?? this.bookingId,
      passengerName: passengerName ?? this.passengerName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      price: price ?? this.price,
      pickupDateTime: pickupDateTime ?? this.pickupDateTime,
      vias: vias ?? this.vias,
      isASAP: isASAP ?? this.isASAP,
      guid: guid ?? this.guid,
    );
  }
}
