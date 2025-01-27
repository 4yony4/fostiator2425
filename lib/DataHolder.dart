import 'package:fostiator/Network/PositionChannel.dart';
import 'package:fostiator/Network/SignalingService.dart';

class DataHolder{

  static final DataHolder _instance = DataHolder._internal();

  //SignalingService service=SignalingService();
  PositionChannel positionChannel = PositionChannel();


  DataHolder._internal();

  factory DataHolder(){
    return _instance;
  }


}