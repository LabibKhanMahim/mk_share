import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/local_server.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String _deviceIP = 'Getting IP...';
  List<PlatformFile> _selectedFiles = [];
  bool _serverRunning = false;
  bool _usePin = false;
  String _pin = '0000';
  final LocalServer _localServer = LocalServer();
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _getDeviceIP();
    _generatePin();
  }

  @override
  void dispose() {
    _localServer.stop();
    super.dispose();
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

  void _generatePin() {
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    setState(() {
      _pin = random.toString().padLeft(4, '0');
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
        _addLog('Selected ${_selectedFiles.length} file(s)');
      }
    } catch (e) {
      _addLog('Error picking files: $e');
    }
  }

  Future<void> _toggleServer() async {
    if (_serverRunning) {
      await _localServer.stop();
      setState(() {
        _serverRunning = false;
      });
      _addLog('Server stopped');
    } else {
      if (_selectedFiles.isEmpty) {
        _addLog('Please select files first');
        return;
      }

      // Storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _addLog('Storage permission denied');
        return;
      }

      try {
        await _localServer.start(
          port: 8080,
          files: _selectedFiles,
          usePin: _usePin,
          pin: _pin,
          onLog: (message) => _addLog(message),
        );

        setState(() {
          _serverRunning = true;
        });
        _addLog('Server started on http://$_deviceIP:8080');
      } catch (e) {
        _addLog('Failed to start server: $e');
      }
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 20) {
        _logs.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEND FILES'),
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: const Color(0xFF00FF41),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF41)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _serverRunning ? const Color(0xFF00FF41) : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _serverRunning ? Icons.check_circle : Icons.error,
                    color: _serverRunning
                        ? const Color(0xFF00FF41)
                        : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _serverRunning ? 'Server Running' : 'Server Stopped',
                    style: TextStyle(
                      color: _serverRunning
                          ? const Color(0xFF00FF41)
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'http://$_deviceIP:8080',
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QR Code
            if (_serverRunning)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'SCAN TO CONNECT',
                      style: TextStyle(
                        color: Color(0xFF00FF41),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 10),
                    QrImageView(
                      data: 'http://$_deviceIP:8080',
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                    if (_usePin)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'PIN: $_pin',
                          style: const TextStyle(
                            color: Color(0xFF00FF41),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            fontSize: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // PIN toggle
            Row(
              children: [
                const Text(
                  'Use PIN for security:',
                  style: TextStyle(color: Color(0xFF00FF41)),
                ),
                const Spacer(),
                Switch(
                  value: _usePin,
                  onChanged: (value) {
                    setState(() {
                      _usePin = value;
                    });
                  },
                  activeColor: const Color(0xFF00FF41),
                ),
              ],
            ),

            if (_usePin)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Text(
                      'PIN:',
                      style: TextStyle(color: Color(0xFF00FF41)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _pin,
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF00FF41)),
                      onPressed: _generatePin,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // File selection buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('SELECT FILES'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: const Color(0xFF00FF41),
                      side: const BorderSide(color: Color(0xFF00FF41)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleServer,
                    icon: Icon(_serverRunning ? Icons.stop : Icons.play_arrow),
                    label:
                        Text(_serverRunning ? 'STOP SERVER' : 'START SERVER'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: const Color(0xFF00FF41),
                      side: const BorderSide(color: Color(0xFF00FF41)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Selected files list
            if (_selectedFiles.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FF41)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECTED FILES:',
                      style: TextStyle(
                        color: Color(0xFF00FF41),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._selectedFiles.map(
                      (file) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                color: Color(0xFF00FFFF), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                file.name,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${((file.size ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB', // ✅ fixed
                              style: const TextStyle(
                                color: Color(0xFF00FFFF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Logs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00FF41)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LOGS:',
                    style: TextStyle(
                      color: Color(0xFF00FF41),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _logs
                            .map(
                              (log) => Text(
                                log,
                                style: const TextStyle(
                                  color: Color(0xFF00FFFF),
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
