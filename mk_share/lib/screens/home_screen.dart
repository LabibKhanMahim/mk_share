import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _deviceIP = 'Getting IP...';
  bool _showQR = false;

  @override
  void initState() {
    super.initState();
    _getDeviceIP();
  }

  Future<void> _getDeviceIP() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    if (wifiIP != null) {
      setState(() {
        _deviceIP = wifiIP;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mk Share'),
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: const Color(0xFF00FF41),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // অ্যাপ টাইটেল
            const Text(
              'MK SHARE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF41),
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
            const Text(
              'LOCAL FILE SHARING',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF00FFFF),
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 40),

            // ডিভাইস IP প্রদর্শন
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00FF41)),
              ),
              child: Column(
                children: [
                  const Text(
                    'DEVICE IP',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF00FFFF),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _deviceIP,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FF41),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showQR = !_showQR;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF00FF41),
                      side: const BorderSide(color: Color(0xFF00FF41)),
                    ),
                    child: const Text('SHOW QR'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QR কোড প্রদর্শন
            if (_showQR)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: 'http://$_deviceIP:8080',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),

            const SizedBox(height: 40),

            // অ্যাকশন বাটন
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const SendScreen()),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('SEND FILES'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: const Color(0xFF00FF41),
                    side: const BorderSide(color: Color(0xFF00FF41)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ReceiveScreen()),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('RECEIVE FILES'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: const Color(0xFF00FF41),
                    side: const BorderSide(color: Color(0xFF00FF41)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // সোশ্যাল মিডিয়া লিঙ্ক
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(
                        'https://www.instagram.com/labibkhanmahim?igsh=MTJ4YTR6cWNkYnk3dA==');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF00FF41)),
                  label: const Text(
                    'Instagram',
                    style: TextStyle(color: Color(0xFF00FF41)),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton.icon(
                  onPressed: () async {
                    final uri =
                        Uri.parse('https://www.facebook.com/share/1A2zqj2UiR/');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.facebook, color: Color(0xFF00FF41)),
                  label: const Text(
                    'Facebook',
                    style: TextStyle(color: Color(0xFF00FF41)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
