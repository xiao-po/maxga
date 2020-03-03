class DateUtils {
  static String formatTime({DateTime time, int timestamp, String template}) {
    if (timestamp == null && time == null) {
      throw DateUtilError('时间不能为 null ');
    }
    var resultTime = time;
    try {
      if (resultTime == null) {
        resultTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch(e) {
      throw DateUtilError('时间戳 formatter 失败');
    }
    var result = template;
    final int hh = resultTime.hour - 12 > 0 ? resultTime.hour - 12 : resultTime.hour;
    result = result.replaceAll('YYYY', '${resultTime.year}');
    result = result.replaceAll('MM', '${resultTime.month < 10 ? '0${resultTime.month}' : resultTime.month}');
    result = result.replaceAll('dd', '${resultTime.day < 10 ? '0${resultTime.day}' : resultTime.day}');
    result = result.replaceAll('HH', '${resultTime.hour < 10 ? '0${resultTime.hour}' : resultTime.hour}');
    result = result.replaceAll('hh', '${hh < 10 ? '0${resultTime.hour}' : hh}}');
    result = result.replaceAll('mm', '${resultTime.minute < 10 ? '0${resultTime.minute}' : resultTime.minute}');
    result = result.replaceAll('ss', '${resultTime.second < 10 ? '0${resultTime.second}' : resultTime.second}');
    return result;
  }
  static DateTime convertTimeStringToDateTime(String time, String template) {
    try {
      int yearTemplateIndex = template.indexOf('YYYY');
      int yearValue = yearTemplateIndex >= 0 ? int.parse(
          time.substring(yearTemplateIndex, yearTemplateIndex + 4)
      ) : 0;
      int monthTemplateIndex = template.indexOf('MM');
      int monthValue = monthTemplateIndex >= 0 ? int.parse(
          time.substring(monthTemplateIndex, monthTemplateIndex + 2)
      ) : 1;
      int dayTemplateIndex = template.indexOf('dd');
      int dayValue = dayTemplateIndex >= 0 ? int.parse(
          time.substring(dayTemplateIndex, dayTemplateIndex + 2)
      ) : 1;

      int hourTemplateIndex = template.indexOf('HH');
      int hourValue = hourTemplateIndex >= 0 ? int.parse(
          time.substring(hourTemplateIndex, hourTemplateIndex + 2)
      ) : 0;

      int minuteTemplateIndex = template.indexOf('mm');
      int minuteValue = minuteTemplateIndex >= 0 ? int.parse(
          time.substring(minuteTemplateIndex, minuteTemplateIndex + 2)
      ) : 0;
      int secondTemplateIndex = template.indexOf('mm');
      int secondValue = secondTemplateIndex >= 0 ? int.parse(
          time.substring(secondTemplateIndex, secondTemplateIndex + 2)
      ) : 0;

      return DateTime.utc(
          yearValue,
          monthValue,
          dayValue,
          hourValue,
          minuteValue,
          secondValue
      );
    } catch(e) {
      throw DateUtilError('转换时间错误');
    }
  }
  static int convertTimeStringToTimestamp(String time, String template) {
    return convertTimeStringToDateTime(time, template).millisecondsSinceEpoch;


  }

}


class DateUtilError extends Error {
  final String message;

  DateUtilError(this.message);
}