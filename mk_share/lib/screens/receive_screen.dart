import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final List<String> _logs = [];
  String _senderIP = '';
  bool _showScanner = false;
  List<Map<String, dynamic>> _availableFiles = [];
  bool _connecting = false;
  String _pin = '';

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 20) {
        _logs.removeAt(0);
      }
    });
  }

  void _onQRViewCreated(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      final url = Uri.parse(barcode.rawValue!);
      setState(() {
        _senderIP = url.host;
        _showScanner = false;
      });
      _fetchFileList();
    }
  }

  Future<void> _fetchFileList() async {
    if (_senderIP.isEmpty) return;

    setState(() {
      _connecting = true;
    });
    _addLog('Connecting to $_senderIP...');

    try {
      final response = await http
          .get(
            Uri.parse('http://$_senderIP:8080/files'),
            headers: _pin.isNotEmpty ? {'X-Pin': _pin} : null,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // ফাইল লিস্ট পার্স করা (উদাহরণ)
        setState(() {
          _availableFiles = [
            {
              'name': 'example1.jpg',
              'size': 1024000,
              'path': '/files/example1.jpg'
            },
            {
              'name': 'example2.pdf',
              'size': 2048000,
              'path': '/files/example2.pdf'
            },
            {
              'name': 'example3.mp4',
              'size': 10240000,
              'path': '/files/example3.mp4'
            },
          ];
          _connecting = false;
        });
        _addLog('Connected successfully');
      } else if (response.statusCode == 401) {
        _addLog('PIN required or incorrect');
        _showPinDialog();
      } else {
        _addLog('Failed to connect: ${response.statusCode}');
        setState(() {
          _connecting = false;
        });
      }
    } catch (e) {
      _addLog('Connection error: $e');
      setState(() {
        _connecting = false;
      });
    }
  }

  void _showPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Enter PIN',
          style: TextStyle(color: Color(0xFF00FF41)),
        ),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            hintText: '4-digit PIN',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00FF41)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00FFFF)),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _pin = pinController.text;
              });
              _fetchFileList();
            },
            child: const Text(
              'CONNECT',
              style: TextStyle(color: Color(0xFF00FF41)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    // স্টোরেজ পারমিশন চাওয়া
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      _addLog('Storage permission denied');
      return;
    }

    // ডাউনলোড ডিরেক্টরি পাওয়া
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      _addLog('Failed to get storage directory');
      return;
    }

    final downloadsDir = Directory('${directory.path}/Downloads/MkShare');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final filePath = '${downloadsDir.path}/${file['name']}';

    _addLog('Starting download: ${file['name']}');

    try {
      final request = http.Request(
          'GET', Uri.parse('http://$_senderIP:8080${file['path']}'));
      if (_pin.isNotEmpty) {
        request.headers.addAll({'X-Pin': _pin});
      }

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception(
            'Failed to download file: ${streamedResponse.statusCode}');
      }

      final fileOnDisk = File(filePath);
      final sink = fileOnDisk.openWrite();

      try {
        await sink.addStream(streamedResponse.stream);
      } finally {
        await sink.close();
      }

      _addLog('Download completed: ${file['name']}');
    } catch (e) {
      _addLog('Download failed: ${file['name']} - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECEIVE FILES'),
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
            // কানেকশন স্ট্যাটাস
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _availableFiles.isNotEmpty
                      ? const Color(0xFF00FF41)
                      : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _availableFiles.isNotEmpty
                        ? Icons.check_circle
                        : Icons.error,
                    color: _availableFiles.isNotEmpty
                        ? const Color(0xFF00FF41)
                        : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _availableFiles.isNotEmpty
                        ? 'Connected to $_senderIP'
                        : 'Not connected',
                    style: TextStyle(
                      color: _availableFiles.isNotEmpty
                          ? const Color(0xFF00FF41)
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_connecting)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF00FF41),
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // IP ইনপুট বা QR স্ক্যানার
            if (!_showScanner && _availableFiles.isEmpty)
              Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      _senderIP = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Sender IP',
                      hintText: '192.168.1.100',
                      labelStyle: TextStyle(color: Color(0xFF00FF41)),
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00FF41)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00FFFF)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _fetchFileList,
                          icon: const Icon(Icons.link),
                          label: const Text('CONNECT'),
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
                          onPressed: () {
                            setState(() {
                              _showScanner = true;
                            });
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('SCAN QR'),
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
                ],
              ),

            // QR স্ক্যানার
            if (_showScanner)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FF41)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    onDetect: _onQRViewCreated,
                  ),
                ),
              ),

            if (_showScanner)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showScanner = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('CANCEL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: const Color(0xFF00FF41),
                    side: const BorderSide(color: Color(0xFF00FF41)),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // উপলব্ধ ফাইল
            if (_availableFiles.isNotEmpty)
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
                      'AVAILABLE FILES:',
                      style: TextStyle(
                        color: Color(0xFF00FF41),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._availableFiles.map((file) => ListTile(
                          title: Text(
                            file['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${(file['size'] / 1024 / 1024).toStringAsFixed(2)} MB',
                            style: const TextStyle(color: Color(0xFF00FFFF)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.download,
                                color: Color(0xFF00FF41)),
                            onPressed: () => _downloadFile(file),
                          ),
                        )),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // লগ
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
                            .map((log) => Text(
                                  log,
                                  style: const TextStyle(
                                    color: Color(0xFF00FFFF),
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ))
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
