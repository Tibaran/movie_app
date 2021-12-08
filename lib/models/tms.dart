import 'package:intl/intl.dart';
class Tms{
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd');
  static String _currentDate = formatter.format(now);
  //static const apiKey = "tnhxguz6jzuwfbryjnmwrb8r";
  static const apiKey = "9pm3vjw57dcpvu2dqcvyba95";

  static const baseUrl = "http://data.tmsapi.com/v1.1/movies/";
  static const testUrl = "${baseUrl}showings?startDate=2021-12-08&lat=39.956163&lng=-75.162474&api_key=$apiKey";
  static var testUrlD = "${baseUrl}showings?startDate=${_currentDate}&lat=39.956163&lng=-75.162474&api_key=$apiKey";

  static String getUrl(String date, String lat, String lng){
    return "${baseUrl}showings?startDate=$date&lat=$lat&lng=$lng&api_key=$apiKey";
  }

}