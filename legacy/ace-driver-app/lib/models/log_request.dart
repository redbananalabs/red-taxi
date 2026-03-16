class LogRequest {
  final String type;
  final String message;
  final String source;

  LogRequest({
    required this.type,
    required this.message,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'message': message,
    'source': source,
  };
}