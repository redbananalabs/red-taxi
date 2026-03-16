class DriverMessage {
  final String title;
  final String body;
  final DateTime timestamp;

  DriverMessage({
    required this.title,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "body": body,
        "timestamp": timestamp.toIso8601String(),
      };

  factory DriverMessage.fromJson(Map<String, dynamic> json) {
    return DriverMessage(
      title: json["title"],
      body: json["body"],
      timestamp: DateTime.parse(json["timestamp"]),
    );
  }
}
