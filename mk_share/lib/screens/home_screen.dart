import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../widgets/neon_button.dart';
import '../widgets/cyber_text.dart';
import '../utils/network_utils.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String deviceIP = 'Getting IP...';
  bool showQR = false;
  String deviceName = '';

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _getDeviceIP();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      deviceName = androidInfo.model;
    });
  }

  Future<void> _getDeviceIP() async {
    String ip = await NetworkUtils.getLocalIP();
    setState(() {
      deviceIP = ip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const CyberText(
          text: 'MK SHARE',
          size: 24,
          color: Colors.cyan,
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black.withOpacity(0.9),
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const CyberText(
                    text: 'CYBERPUNK FILE TRANSFER',
                    size: 18,
                    color: Colors.green,
                    letterSpacing: 2.0,
                  ),
                  const SizedBox(height: 40),
                  
                  AnimationLimiter(
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          NeonButton(
                            text: 'SEND FILES',
                            icon: Icons.upload,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SendScreen(),
                                ),
                              );
                            },
                            color: Colors.cyan,
                          ),
                          const SizedBox(height: 20),
                          
                          NeonButton(
                            text: 'RECEIVE FILES',
                            icon: Icons.download,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReceiveScreen(),
                                ),
                              );
                            },
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CyberText(
                              text: 'DEVICE:',
                              size: 14,
                              color: Colors.cyan,
                            ),
                            CyberText(
                              text: deviceName,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CyberText(
                              text: 'IP ADDRESS:',
                              size: 14,
                              color: Colors.cyan,
                            ),
                            CyberText(
                              text: deviceIP,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (showQR)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Column(
                        children: [
                          const CyberText(
                            text: 'SCAN QR TO CONNECT',
                            size: 14,
                            color: Colors.cyan,
                          ),
                          const SizedBox(height: 10),
                          QrImageView(
                            data: 'http://$deviceIP:8080',
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  
                  NeonButton(
                    text: showQR ? 'HIDE QR' : 'SHOW QR',
                    icon: showQR ? Icons.qr_code_2_outlined : Icons.qr_code_2,
                    onPressed: () {
                      setState(() {
                        showQR = !showQR;
                      });
                    },
                    color: Colors.purple,
                    width: 150,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  const CyberText(
                    text: 'DEVELOPER',
                    size: 16,
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.purple),
                        onPressed: () async {
                          const url = 'https://www.instagram.com/labibkhanmahim?igsh=MTJ4YTR6cWNkYnk3dA==';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.facebook, color: Colors.blue),
                        onPressed: () async {
                          const url = 'https://www.facebook.com/share/1A2zqj2UiR/';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}