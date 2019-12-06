class DateUtils {
  static String formatTime({DateTime time, int timestamp, String template}) {
    try {
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
    } catch(e) {

      throw DateUtilError('时间戳 formatter 失败');
    }
  }

  static int convertTimeStringToTimestamp(String time, String template) {
    try {
      int yearTemplateIndex = template.indexOf('yyyy');
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

      int hourTemplateIndex = template.indexOf('hh');
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
      ).millisecondsSinceEpoch;
    } catch(e) {
      throw DateUtilError('转换时间错误');
    }


  }

}


class DateUtilError extends Error {
  final String message;

  DateUtilError(this.message);
}