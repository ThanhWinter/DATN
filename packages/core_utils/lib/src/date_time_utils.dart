/// Parse ngày giờ từ JSON backend.
///
/// Hỗ trợ:
/// - Chuỗi ISO-8601 (khuyến nghị): Spring `write-dates-as-timestamps: false` +
///   `JavaTimeModule` → `"2026-05-03T14:30:00"` hoặc có `Z`/offset.
/// - Số: epoch **milliseconds** UTC (vd. `Instant.toEpochMilli()`).
/// - Mảng (legacy Jackson `write-dates-as-timestamps: true`):
///   `[year, month, day, hour, minute, second, nano]` — nano có thể là int/double trong JSON.
///
/// Lưu ý: `DateTime(y,m,d,...)` không gắn zone → coi là **local**; nên ưu tiên backend gửi
/// ISO có `Z` hoặc offset (`+07:00`) để không lệch múi giờ.
DateTime parseApiDateTime(dynamic value) {
  if (value == null) {
    throw FormatException('parseApiDateTime: null');
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(
      value.toInt(),
      isUtc: true,
    ).toLocal();
  }
  if (value is List && value.length >= 3) {
    final y = _intFromJson(value[0]);
    final mo = _intFromJson(value[1]);
    final d = _intFromJson(value[2]);
    final h = value.length > 3 ? _intFromJson(value[3]) : 0;
    final mi = value.length > 4 ? _intFromJson(value[4]) : 0;
    final s = value.length > 5 ? _intFromJson(value[5]) : 0;
    final nano = value.length > 6 ? _intFromJson(value[6]) : 0;
    return DateTime(
      y,
      mo,
      d,
      h,
      mi,
      s,
      nano ~/ 1000000,
      (nano % 1000000) ~/ 1000,
    );
  }
  throw FormatException(
    'parseApiDateTime: unsupported type ${value.runtimeType}: $value',
  );
}

int _intFromJson(Object? e) {
  if (e is int) return e;
  if (e is num) return e.toInt();
  throw FormatException('Expected int-compatible JSON value, got $e');
}

String formatOrderDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute - $day/$month/$year';
}

String formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inSeconds < 60) {
    return 'Vừa xong';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} phút trước';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} giờ trước';
  } else {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month lúc $hour:$minute';
  }
}
