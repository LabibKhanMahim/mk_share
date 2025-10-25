import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:file_picker/file_picker.dart';

class LocalServer {
  HttpServer? _server;
  List<PlatformFile> _files = [];
  bool _usePin = false;
  String _pin = '';
  Function(String)? _onLog;

  Future<void> start({
    required int port,
    required List<PlatformFile> files,
    bool usePin = false,
    String pin = '',
    Function(String)? onLog,
  }) async {
    _files = files;
    _usePin = usePin;
    _pin = pin;
    _onLog = onLog;

    // হ্যান্ডলার ফাংশন তৈরি করুন
    Handler handler = (Request request) {
      // রুট পাথ পান
      final path = request.url.path;

      // রুট হ্যান্ডলিং
      if (path == '/' || path.isEmpty) {
        return _handleRoot(request);
      } else if (path == '/files') {
        return _handleFileList(request);
      } else if (path.startsWith('/files/')) {
        // ফাইল নাম এক্সট্র্যাক্ট করুন
        final fileName = path.substring(7); // '/files/' এর পরের অংশ
        return _handleFileDownload(request, fileName);
      } else if (path == '/announce') {
        return _handleAnnounce(request);
      }

      // 404 রিটার্ন করুন যদি কোনো রুট মেলে না
      return Response.notFound('Endpoint not found');
    };

    // PIN যাচাইকরণ মিডলওয়্যার যোগ করুন যদি PIN সক্রিয় থাকে
    if (_usePin) {
      handler = _addPinValidationMiddleware(handler);
    }

    // CORS হেডার যোগ করুন
    handler = _addCorsHeadersMiddleware(handler);

    try {
      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        port,
      );
      _onLog?.call('Server started on port $port');
    } catch (e) {
      _onLog?.call('Failed to start server: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      _onLog?.call('Server stopped');
    }
  }

  Response _handleRoot(Request request) {
    return Response.ok(
      '<html><body><h1>Mk Share Server</h1><p>Access <a href="/files">/files</a> to see available files</p></body></html>',
      headers: {'content-type': 'text/html'},
    );
  }

  Response _handleFileList(Request request) {
    final fileList = _files
        .map((file) => {
              'name': file.name,
              'size': file.size,
              'path': '/files/${file.name}',
            })
        .toList();

    return Response.ok(
      jsonEncode(fileList),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> _handleFileDownload(Request request, String fileName) async {
    final file = _files.firstWhere(
      (f) => f.name == fileName,
      orElse: () => throw Exception('File not found'),
    );

    if (file.path == null) {
      return Response(404, body: 'File not found on device');
    }

    final fileOnDisk = File(file.path!);
    if (!await fileOnDisk.exists()) {
      return Response(404, body: 'File not found on device');
    }

    final bytes = await fileOnDisk.readAsBytes();
    final contentType = _getContentType(file.extension ?? '');

    return Response.ok(
      bytes,
      headers: {
        'content-type': contentType,
        'content-disposition': 'attachment; filename="${file.name}"',
      },
    );
  }

  Response _handleAnnounce(Request request) {
    return Response.ok(
      jsonEncode({
        'server': 'Mk Share',
        'message': 'Use this endpoint to connect to the file server',
        'filesEndpoint': '/files',
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  Handler _addPinValidationMiddleware(Handler handler) {
    return (Request request) async {
      // ঘোষণা এন্ডপয়েন্টের জন্য PIN যাচাইকরণ এড়িয়ে যান
      if (request.url.path == 'announce') {
        return await handler(request);
      }

      final pin = request.headers['x-pin'];
      if (pin != _pin) {
        return Response(401, body: 'Unauthorized: Invalid or missing PIN');
      }

      return await handler(request);
    };
  }

  Handler _addCorsHeadersMiddleware(Handler handler) {
    return (Request request) async {
      final response = await handler(request);

      // রেসপন্সে CORS হেডার যোগ করুন
      return response.change(headers: {
        ...response.headers,
        'access-control-allow-origin': '*',
        'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'access-control-allow-headers': 'Content-Type, X-Pin',
      });
    };
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'html':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'zip':
        return 'application/zip';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
