class DateUtils {
  static String formatTime({DateTime time, int timestamp, String template}) {
    var resultTime = time;
    if (resultTime == null) {
      resultTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    var result = template;
    result = result.replaceAll('yyyy', '${resultTime.year}');
    result = result.replaceAll('MM', '${resultTime.month}');
    result = result.replaceAll('dd', '${resultTime.day}');
    result = result.replaceAll('hh', '${resultTime.hour}');
    result = result.replaceAll('mm', '${resultTime.minute}');
    result = result.replaceAll('ss', '${resultTime.second}');
    return result;
  }
}
