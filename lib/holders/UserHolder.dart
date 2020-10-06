import 'package:style_app/model/ServiceWrapper.dart';
import 'package:style_app/model/Sketch.dart';

class UserHolder {
  static int profileType;
  static int id ;
  static int city;
  static String token;
  static String name;
  static String surname;
  static String phone;
  static String email;
  static String address = "";
  static String about = "";
  static String avatar = "";
  static bool isShowAddress = true;
  static bool isShowPhone = true;
  static bool isShowEmail = true;
  static List<ServiceWrapper> services = [];
  static List<Sketch> sketches = [];
  static List<String> portfolioImages = [];
}