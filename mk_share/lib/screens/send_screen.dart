import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/neon_button.dart';
import '../widgets/cyber_text.dart';
import '../services/local_server.dart';
import '../utils/network_utils.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  List<PlatformFile> selectedFiles = [];
  bool isServerRunning = false;
  String serverIP = 'Getting IP...';
  String serverURL = '';
  bool showQR = false;
  final LocalServer _localServer = LocalServer();
  List<String> logs = [];
  bool usePin = false;
  String pinCode = '';

  @override
  void initState() {
    super.initState();
    _getDeviceIP();
    _generatePin();
  }

  @override
  void dispose() {
    if (isServerRunning) {
      _localServer.stop();
    }
    super.dispose();
  }

  Future<void> _getDeviceIP() async {
    String ip = await NetworkUtils.getLocalIP();
    setState(() {
      serverIP = ip;
      serverURL = 'http://$ip:8080';
    });
  }

  void _generatePin() {
    setState(() {
      pinCode = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
      });
      _addLog('Selected ${selectedFiles.length} file(s)');
    }
  }

  void _addLog(String message) {
    setState(() {
      logs.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $message');
      if (logs.length > 100) {
        logs = logs.take(100).toList();
      }
    });
  }

  Future<void> _startServer() async {
    if (selectedFiles.isEmpty) {
      _showSnackBar('Please select files first');
      return;
    }

    if (isServerRunning) {
      _showSnackBar('Server is already running');
      return;
    }

    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }

    try {
      _addLog('Starting server...');
      await _localServer.start(selectedFiles, pinCode: usePin ? pinCode : null);
      setState(() {
        isServerRunning = true;
      });
      _addLog('Server started at $serverURL');
      _showSnackBar('Server started successfully');
    } catch (e) {
      _addLog('Failed to start server: $e');
      _showSnackBar('Failed to start server: $e');
    }
  }

  Future<void> _stopServer() async {
    try {
      _addLog('Stopping server...');
      await _localServer.stop();
      setState(() {
        isServerRunning = false;
      });
      _addLog('Server stopped');
      _showSnackBar('Server stopped');
    } catch (e) {
      _addLog('Failed to stop server: $e');
      _showSnackBar('Failed to stop server: $e');
    }
  }

  void _removeFile(int index) {
    final fileName = selectedFiles[index].name;
    setState(() {
      selectedFiles.removeAt(index);
    });
    _addLog('Removed file: $fileName');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CyberText(text: message, size: 14, color: Colors.white),
        backgroundColor: Colors.black.withOpacity(0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const CyberText(
          text: 'SEND FILES',
          size: 24,
          color: Colors.cyan,
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyan),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CyberText(
                    text: 'SELECT FILES',
                    size: 18,
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 10),
                  NeonButton(
                    text: 'PICK FILES',
                    icon: Icons.folder_open,
                    onPressed: _pickFiles,
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 20),
                  
                  if (selectedFiles.isNotEmpty) ...[
                    const CyberText(
                      text: 'SELECTED FILES',
                      size: 16,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: ListView.builder(
                        itemCount: selectedFiles.length,
                        itemBuilder: (context, index) {
                          final file = selectedFiles[index];
                          return ListTile(
                            title: CyberText(
                              text: file.name,
                              size: 14,
                              color: Colors.white,
                            ),
                            subtitle: CyberText(
                              text: '${(file.size ?? 0) / 1024} KB',
                              size: 12,
                              color: Colors.grey,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeFile(index),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  const CyberText(
                    text: 'SERVER CONTROLS',
                    size: 18,
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: NeonButton(
                          text: isServerRunning ? 'STOP SERVER' : 'START SERVER',
                          icon: isServerRunning ? Icons.stop : Icons.play_arrow,
                          onPressed: isServerRunning ? _stopServer : _startServer,
                          color: isServerRunning ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      NeonButton(
                        text: usePin ? 'PIN ON' : 'PIN OFF',
                        icon: Icons.lock,
                        onPressed: () {
                          setState(() {
                            usePin = !usePin;
                          });
                        },
                        color: usePin ? Colors.green : Colors.grey,
                        width: 100,
                      ),
                    ],
                  ),
                  
                  if (usePin) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CyberText(
                            text: 'PIN CODE:',
                            size: 14,
                            color: Colors.green,
                          ),
                          CyberText(
                            text: pinCode,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  if (isServerRunning) ...[
                    const CyberText(
                      text: 'SERVER INFO',
                      size: 18,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 10),
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
                                text: 'IP ADDRESS:',
                                size: 14,
                                color: Colors.cyan,
                              ),
                              CyberText(
                                text: serverIP,
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
                                text: 'STATUS:',
                                size: 14,
                                color: Colors.cyan,
                              ),
                              const CyberText(
                                text: 'RUNNING',
                                size: 14,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    NeonButton(
                      text: showQR ? 'HIDE QR' : 'SHOW QR',
                      icon: showQR ? Icons.qr_code_2_outlined : Icons.qr_code_2,
                      onPressed: () {
                        setState(() {
                          showQR = !showQR;
                        });
                      },
                      color: Colors.purple,
                    ),
                    
                    if (showQR) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
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
                                data: serverURL,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                  
                  const SizedBox(height: 20),
                  const CyberText(
                    text: 'ACTIVITY LOG',
                    size: 18,
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: logs.isEmpty
                        ? const Center(
                            child: CyberText(
                              text: 'No activity yet',
                              size: 14,
                              color: Colors.grey,
                            ),
                          )
                        : ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                child: CyberText(
                                  text: logs[index],
                                  size: 12,
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
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