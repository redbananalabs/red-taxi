import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class UkTime {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    tz.initializeTimeZones();
    _initialized = true;
  }

  /// 🇬🇧 Current UK time (DST safe)
  static DateTime now() {
    init();
    final uk = tz.getLocation('Europe/London');
    return tz.TZDateTime.now(uk);
  }

  /// 🇬🇧 Convert backend datetime → UK time correctly
  static DateTime parse(String date) {
    init();
    final uk = tz.getLocation('Europe/London');

    final parsed = DateTime.parse(date);

    // ✅ If backend sends UTC (recommended)
    if (parsed.isUtc) {
      return tz.TZDateTime.from(parsed, uk);
    }

    // ⚠️ If backend sends local time (rare but possible)
    return tz.TZDateTime(
      uk,
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    );
  }
}
