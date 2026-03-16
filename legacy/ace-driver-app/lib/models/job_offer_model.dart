class JobOffer {
  final int bookingId;
  final String guid;
  final String? bookingDateTime;

  JobOffer({
    required this.bookingId,
    required this.guid,
    this.bookingDateTime,
  });

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      bookingId: json['bookingId'],
      guid: json['guid'],
      bookingDateTime: json['bookingDateTime'],
    );
  }
}
