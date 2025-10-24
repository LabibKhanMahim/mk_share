import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';

class LocalServer {
  HttpServer? _server;
  List<PlatformFile> _files = [];
  String? _pinCode;

  Future<void> start(List<PlatformFile> files, {String? pinCode}) async {
    if (_server != null) {
      throw Exception('Server is already running');
    }

    _files = files;
    _pinCode = pinCode;

    try {
      _server = await HttpServer.bind('0.0.0.0', 8080);
      await for (HttpRequest request in _server!) {
        _handleRequest(request);
      }
    } catch (e) {
      throw Exception('Failed to start server: $e');
    }
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
    }
  }

  void _handleRequest(HttpRequest request) {
    final path = request.uri.path;
    
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
    
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      request.response.close();
      return;
    }
    
    try {
      switch (path) {
        case '/announce':
          _handleAnnounce(request);
          break;
        case '/files':
          _handleFilesList(request);
          break;
        case '/verify':
          _handlePinVerification(request);
          break;
        default:
          if (path.startsWith('/download/')) {
            _handleFileDownload(request, path.substring(10));
          } else {
            _send404(request);
          }
      }
    } catch (e) {
      _sendError(request, 'Internal server error: $e');
    }
  }

  void _handleAnnounce(HttpRequest request) {
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'status': 'ok',
      'message': 'Mk Share server is running',
      'requiresPin': _pinCode != null,
    }));
    request.response.close();
  }

  Future<void> _handlePinVerification(HttpRequest request) async {
    if (_pinCode == null) {
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'status': 'ok',
        'verified': true,
      }));
      request.response.close();
      return;
    }
    
    try {
      final body = await utf8.decoder.bind(request).join();
      final data = jsonDecode(body);
      final providedPin = data['pin'];
      
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'status': 'ok',
        'verified': providedPin == _pinCode,
      }));
      request.response.close();
    } catch (e) {
      _sendError(request, 'Invalid request body');
    }
  }

  void _handleFilesList(HttpRequest request) {
    final List<Map<String, dynamic>> filesList = [];
    
    for (final file in _files) {
      filesList.add({
        'name': file.name,
        'size': file.size,
        'url': '/download/${file.name}',
      });
    }
    
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(filesList));
    request.response.close();
  }

  void _handleFileDownload(HttpRequest request, String fileName) {
    final file = _files.firstWhere(
      (f) => f.name == fileName,
      orElse: () => throw Exception('File not found'),
    );
    
    if (file.path == null) {
      _sendError(request, 'File path not available');
      return;
    }
    
    final fileToServe = File(file.path!);
    
    if (!fileToServe.existsSync()) {
      _sendError(request, 'File does not exist');
      return;
    }
    
    final extension = file.name?.split('.').last.toLowerCase();
    String contentType = 'application/octet-stream';
    
    if (extension != null) {
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'pdf':
          contentType = 'application/pdf';
          break;
        case 'txt':
          contentType = 'text/plain';
          break;
        case 'mp4':
          contentType = 'video/mp4';
          break;
        case 'mp3':
          contentType = 'audio/mpeg';
          break;
      }
    }
    
    request.response.headers.contentType = ContentType.parse(contentType);
    request.response.headers.set('Content-Disposition', 'attachment; filename="${file.name}"');
    request.response.headers.set('Content-Length', file.size.toString());
    
    fileToServe.openRead().pipe(request.response).catchError((e) {
      request.response.close();
    });
  }

  void _send404(HttpRequest request) {
    request.response.statusCode = HttpStatus.notFound;
    request.response.write('Not Found');
    request.response.close();
  }

  void _sendError(HttpRequest request, String message) {
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.write(message);
    request.response.close();
  }
}