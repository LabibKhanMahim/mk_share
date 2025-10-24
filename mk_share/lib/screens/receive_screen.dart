import 'dart:io';
import 'dart:convert'; // FIXED: Added for jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../widgets/neon_button.dart';
import '../widgets/cyber_text.dart';
import '../widgets/progress_tile.dart';
import '../services/file_transfer.dart';
import '../utils/network_utils.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController controller = MobileScannerController();
  String serverIP = '';
  bool showScanner = false;
  List<RemoteFile> availableFiles = [];
  List<DownloadTask> downloadTasks = [];
  bool isConnected = false;
  List<String> logs = [];
  String? pinCode;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.camera,
    ].request();
  }

  void _addLog(String message) {
    setState(() {
      logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _processQRCode(barcode.rawValue!);
        controller.stop();
        setState(() {
          showScanner = false;
        });
        break;
      }
    }
  }

  void _processQRCode(String qrCode) {
    final uri = Uri.parse(qrCode);
    setState(() {
      serverIP = uri.host;
    });
    _addLog('QR Code scanned: $serverIP');
    _connectToServer();
  }

  Future<void> _connectToServer() async {
    if (serverIP.isEmpty) {
      _showSnackBar('Please enter or scan a valid IP address');
      return;
    }

    _addLog('Connecting to $serverIP...');
    
    try {
      final response = await http.get(
        Uri.parse('http://$serverIP:8080/announce'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _addLog('Connected to server');
        setState(() {
          isConnected = true;
        });
        _fetchFileList();
      } else {
        _addLog('Server responded with error: ${response.statusCode}');
        _showSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _addLog('Failed to connect: $e');
      _showSnackBar('Failed to connect: $e');
    }
  }

  Future<void> _fetchFileList() async {
    try {
      final response = await http.get(
        Uri.parse('http://$serverIP:8080/files'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> filesJson = jsonDecode(response.body); // FIXED: Decoding JSON
        final List<RemoteFile> files = filesJson.map((json) {
          return RemoteFile(
            name: json['name'],
            size: json['size'],
            url: json['url'],
          );
        }).toList();

        setState(() {
          availableFiles = files;
        });
        _addLog('Fetched ${files.length} files from server');
      } else {
        _addLog('Failed to fetch file list: ${response.statusCode}');
        _showSnackBar('Failed to fetch file list');
      }
    } catch (e) {
      _addLog('Error fetching file list: $e');
      _showSnackBar('Error fetching file list: $e');
    }
  }

  Future<void> _downloadFile(RemoteFile file) async {
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download/MkShare');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    if (downloadsDir == null) {
      _showSnackBar('Could not access downloads directory');
      return;
    }

    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final savePath = '${downloadsDir.path}/${file.name}';
    
    final task = DownloadTask(
      file: file,
      savePath: savePath,
      status: DownloadStatus.pending,
    );
    
    setState(() {
      downloadTasks.add(task);
    });
    
    _addLog('Starting download: ${file.name}');
    
    FileTransfer.downloadFile(
      url: file.url,
      savePath: savePath,
      onProgress: (progress) {
        setState(() {
          task.progress = progress;
          task.status = DownloadStatus.downloading;
        });
      },
      onComplete: () {
        setState(() {
          task.status = DownloadStatus.completed;
        });
        _addLog('Download completed: ${file.name}');
        _showSnackBar('Download completed: ${file.name}');
      },
      onError: (error) {
        setState(() {
          task.status = DownloadStatus.failed;
        });
        _addLog('Download failed: ${file.name} - $error');
        _showSnackBar('Download failed: ${file.name}');
      },
    );
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
          text: 'RECEIVE FILES',
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
                    text: 'CONNECT TO SENDER',
                    size: 18,
                    color: Colors.cyan,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) { // FIXED: Moved onChanged inside TextField
                            serverIP = value;
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter sender IP (e.g., 192.168.1.100)',
                            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.withOpacity(0.5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.cyan.withOpacity(0.5)),
                            ),
                            focusedBorder: OutlineInputBorder( // FIXED: Used OutlineInputBorder instead of BorderSide
                              borderSide: const BorderSide(color: Colors.cyan),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      NeonButton(
                        text: 'CONNECT',
                        icon: Icons.link,
                        onPressed: _connectToServer,
                        color: Colors.cyan,
                        width: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  NeonButton(
                    text: 'SCAN QR CODE',
                    icon: Icons.qr_code_scanner,
                    onPressed: () {
                      setState(() {
                        showScanner = !showScanner;
                      });
                      if (showScanner) {
                        controller.start();
                      } else {
                        controller.stop();
                      }
                    },
                    color: Colors.purple,
                  ),
                  
                  if (showScanner) ...[
                    const SizedBox(height: 20),
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: MobileScanner(
                        controller: controller,
                        onDetect: _onDetect,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isConnected ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CyberText(
                          text: 'STATUS:',
                          size: 14,
                          color: Colors.cyan,
                        ),
                        CyberText(
                          text: isConnected ? 'CONNECTED' : 'DISCONNECTED',
                          size: 14,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (isConnected) ...[
                    const CyberText(
                      text: 'AVAILABLE FILES',
                      size: 18,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 10),
                    if (availableFiles.isEmpty)
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Center(
                          child: CyberText(
                            text: 'No files available',
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: ListView.builder(
                          itemCount: availableFiles.length,
                          itemBuilder: (context, index) {
                            final file = availableFiles[index];
                            return ListTile(
                              title: CyberText(
                                text: file.name,
                                size: 14,
                                color: Colors.white,
                              ),
                              subtitle: CyberText(
                                text: '${(file.size / 1024).toStringAsFixed(2)} KB',
                                size: 12,
                                color: Colors.grey,
                              ),
                              trailing: NeonButton(
                                text: 'DOWNLOAD',
                                icon: Icons.download,
                                onPressed: () => _downloadFile(file),
                                color: Colors.green,
                                width: 100,
                              ),
                            );
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    const CyberText(
                      text: 'DOWNLOAD PROGRESS',
                      size: 18,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 10),
                    if (downloadTasks.isEmpty)
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Center(
                          child: CyberText(
                            text: 'No downloads in progress',
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: ListView.builder(
                          itemCount: downloadTasks.length,
                          itemBuilder: (context, index) {
                            final task = downloadTasks[index];
                            return ProgressTile(
                              fileName: task.file.name,
                              progress: task.progress,
                              status: task.status,
                            );
                          },
                        ),
                      ),
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

class RemoteFile {
  final String name;
  final int size;
  final String url;

  RemoteFile({
    required this.name,
    required this.size,
    required this.url,
  });
}

class DownloadTask {
  final RemoteFile file;
  final String savePath;
  double progress;
  DownloadStatus status;

  DownloadTask({
    required this.file,
    required this.savePath,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
  });
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
}