import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkUtils {
  static Future<String> getLocalIP() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      
      if (wifiIP != null) {
        return wifiIP;
      }
      
      for (final interface in await NetworkInterface.list()) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address.address;
          }
        }
      }
      
      return '192.168.1.100';
    } catch (e) {
      return '192.168.1.100';
    }
  }
}