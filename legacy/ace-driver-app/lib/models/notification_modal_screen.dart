class JobModel {
  final String? regNo;
  final String? backgroundColorRGB;
  final String? fullname;
  final int bookingId;
  final int? userId;
  final int? suggestedUserId;
  final bool cancelledOnArrival;
  final String? cellText;
  final String? hasDetails;
  final int status;
  final DateTime? endTime;
  final DateTime? dateCreated;
  final String? bookedByName;
  final bool cancelled;
  final String? details;
  final String? email;
  final int durationMinutes;
  final bool isAllDay;
  final String passengerName;
  final int passengers;
  final int paymentStatus;
  final int confirmationStatus;
  final String scope;
  final String? phoneNumber;
  final String pickupAddress;
  final DateTime? pickupDateTime;
  final String? arriveBy;
  final String destinationAddress;
  final String? pickupPostCode;
  final String? destinationPostCode;
  final List<String> vias;
  final String? recurrenceException;
  final String? recurrenceID;
  final String? recurrenceRule;
  final String? updatedByName;
  final String? cancelledByName;
  final double price;
  final bool manuallyPriced;
  final double priceDiscount;
  final double priceAccount;
  final double mileage;
  final String mileageText;
  final String durationText;
  final bool chargeFromBase;
  final int? actionByUserId;
  final int? accountNumber;
  final double parkingCharge;
  final int waitingTimeMinutes;
  final String? paymentLinkSentOn;
  final String? paymentLinkSentBy;
  final bool isASAP;

  JobModel({
    this.regNo,
    this.backgroundColorRGB,
    this.fullname,
    required this.bookingId,
    this.userId,
    this.suggestedUserId,
    this.cancelledOnArrival = false,
    this.cellText,
    this.hasDetails,
    required this.status,
    this.endTime,
    this.dateCreated,
    this.bookedByName,
    this.cancelled = false,
    this.details,
    this.email,
    this.durationMinutes = 0,
    this.isAllDay = false,
    this.passengerName = '',
    this.passengers = 0,
    this.paymentStatus = 0,
    this.confirmationStatus = 0,
    this.scope = '',
    this.phoneNumber,
    this.pickupAddress = '',
    this.pickupDateTime,
    this.arriveBy,
    this.destinationAddress = '',
    this.pickupPostCode,
    this.destinationPostCode,
    this.vias = const [],
    this.recurrenceException,
    this.recurrenceID,
    this.recurrenceRule,
    this.updatedByName,
    this.cancelledByName,
    this.price = 0.0,
    this.manuallyPriced = false,
    this.priceDiscount = 0.0,
    this.priceAccount = 0.0,
    this.mileage = 0.0,
    this.mileageText = '',
    this.durationText = '',
    this.chargeFromBase = false,
    this.actionByUserId,
    this.accountNumber,
    this.parkingCharge = 0.0,
    this.waitingTimeMinutes = 0,
    this.paymentLinkSentOn,
    this.paymentLinkSentBy,
    this.isASAP = false,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
    double parseDouble(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      return v.toString() == "1" || v.toString().toLowerCase() == "true";
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        final parts = v.toString().split(' ');
        final d = parts[0].split('/');
        final t = parts.length > 1 ? parts[1].split(':') : ['0', '0'];
        return DateTime(
          int.parse(d[2]),
          int.parse(d[1]),
          int.parse(d[0]),
          int.parse(t[0]),
          int.parse(t[1]),
        );
      } catch (_) {
        return null;
      }
    }

    return JobModel(
      regNo: json['regNo'],
      backgroundColorRGB: json['backgroundColorRGB'],
      fullname: json['fullname'],
      bookingId: parseInt(json['bookingId']),
      userId: parseInt(json['userId']),
      suggestedUserId: parseInt(json['suggestedUserId']),
      cancelledOnArrival: parseBool(json['cancelledOnArrival']),
      cellText: json['cellText'],
      hasDetails: json['hasDetails'],
      status: parseInt(json['status']),
      endTime: parseDate(json['endTime']),
      dateCreated: parseDate(json['dateCreated']),
      bookedByName: json['bookedByName'],
      cancelled: parseBool(json['cancelled']),
      details: json['details'],
      email: json['email'],
      durationMinutes: parseInt(json['DurationMinutes']),
      isAllDay: parseBool(json['isAllDay']),
      passengerName: json['passenger'] ?? '',
      passengers: parseInt(json['passengers']),
      paymentStatus: parseInt(json['paymentStatus']),
      confirmationStatus: parseInt(json['confirmationStatus']),
      scope: json['scope']?.toString() ?? '',
      phoneNumber: json['phoneNumber'],
      pickupAddress: json['pickup'] ?? '',
      pickupDateTime: parseDate(json['datetime']),
      arriveBy: json['arriveBy'],
      destinationAddress: json['drop'] ?? '',
      pickupPostCode: json['pickupPostCode'],
      destinationPostCode: json['destinationPostCode'],
      vias: (json['vias'] is List)
          ? List<String>.from(json['vias'])
          : (json['vias']?.toString().split(',') ?? []),
      recurrenceException: json['recurrenceException'],
      recurrenceID: json['recurrenceID'],
      recurrenceRule: json['recurrenceRule'],
      updatedByName: json['updatedByName'],
      cancelledByName: json['cancelledByName'],
      price: parseDouble(json['price']),
      manuallyPriced: parseBool(json['manuallyPriced']),
      priceDiscount: parseDouble(json['priceDiscount']),
      priceAccount: parseDouble(json['priceAccount']),
      mileage: parseDouble(json['mileage']),
      mileageText: json['mileageText'] ?? '',
      durationText: json['durationText'] ?? '',
      chargeFromBase: parseBool(json['chargeFromBase']),
      actionByUserId: parseInt(json['actionByUserId']),
      accountNumber: parseInt(json['accountNumber']),
      parkingCharge: parseDouble(json['parkingCharge']),
      waitingTimeMinutes: parseInt(json['waitingTimeMinutes']),
      paymentLinkSentOn: json['paymentLinkSentOn'],
      paymentLinkSentBy: json['paymentLinkSentBy'],
      isASAP: parseBool(json['isASAP']),
    );
  }
}
