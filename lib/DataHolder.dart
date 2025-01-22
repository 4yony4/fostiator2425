import 'package:fostiator/Network/SignalingService.dart';

class DataHolder{

  static final DataHolder _instance = DataHolder._internal();

  SignalingService service=SignalingService();


  DataHolder._internal();

  factory DataHolder(){
    return _instance;
  }


}