class DateUtils {
  static String formatTime({DateTime time, int timestamp, String template}) {
    var resultTime = time;
    if (resultTime == null) {
      resultTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    var result = template;
    result = result.replaceAll('YYYY', '${resultTime.year}');
    result = result.replaceAll('MM', '${resultTime.month}');
    result = result.replaceAll('DD', '${resultTime.day}');
    result = result.replaceAll('HH', '${resultTime.hour}');
    result = result.replaceAll('mm', '${resultTime.minute}');
    result = result.replaceAll('ss', '${resultTime.second}');
    return result;
  }
}
