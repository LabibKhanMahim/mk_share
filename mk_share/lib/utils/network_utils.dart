import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkUtils {
  static Future<String?> getLocalIP() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiIP();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isSameNetwork(String ip1, String ip2) async {
    try {
      final parts1 = ip1.split('.');
      final parts2 = ip2.split('.');

      if (parts1.length != 4 || parts2.length != 4) {
        return false;
      }

      // Check if first three octets are the same
      return parts1[0] == parts2[0] &&
          parts1[1] == parts2[1] &&
          parts1[2] == parts2[2];
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isPortOpen(String host, int port) async {
    try {
      final socket =
          await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Platform-specific hotspot creation would go here
  // This is a placeholder for Android hotspot creation
  static Future<bool> createHotspot({String? ssid, String? password}) async {
    // This would require platform channels to implement
    // as Flutter doesn't have direct access to hotspot APIs
    // Implementation would vary by Android version

    // Placeholder code - would need to be implemented with platform channels
    return false;
  }

  // Platform-specific hotspot connection would go here
  static Future<bool> connectToHotspot(String ssid, {String? password}) async {
    // This would require platform channels to implement
    // as Flutter doesn't have direct access to Wi-Fi APIs

    // Placeholder code - would need to be implemented with platform channels
    return false;
  }
}
