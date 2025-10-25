import 'dart:io';
import 'package:http/http.dart' as http;

class FileTransfer {
  Future<void> downloadFile({
    required String url,
    required String savePath,
    Map<String, String>? headers,
    Function(double)? onProgress,
  }) async {
    final file = File(savePath);

    // চেক করুন ফাইলটি আগে থেকেই আছে কিনা
    if (await file.exists()) {
      // রিজিউমের জন্য বিদ্যমান ফাইলের সাইজ পান
      final existingSize = await file.length();

      // রিজিউমের জন্য রেঞ্জ হেডার যোগ করুন
      final rangeHeaders = <String, String>{
        'Range': 'bytes=$existingSize-',
        ...?headers,
      };

      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(rangeHeaders);

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 206 &&
          streamedResponse.statusCode != 200) {
        throw Exception(
            'Failed to download file: ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      final totalSize = existingSize + contentLength;

      // অ্যাপেন্ড মোডে ফাইল খুনুন
      final sink = file.openWrite(mode: FileMode.append);

      try {
        int downloadedBytes = existingSize;

        await for (final chunk in streamedResponse.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length;

          if (onProgress != null) {
            onProgress(downloadedBytes / totalSize);
          }
        }
      } finally {
        await sink.close();
      }
    } else {
      // নতুন ডাউনলোড
      final request = http.Request('GET', Uri.parse(url));
      if (headers != null) {
        request.headers.addAll(headers);
      }

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        throw Exception(
            'Failed to download file: ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? 0;

      // রাইট মোডে ফাইল খুনুন
      final sink = file.openWrite();

      try {
        int downloadedBytes = 0;

        await for (final chunk in streamedResponse.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length;

          if (onProgress != null) {
            onProgress(downloadedBytes / contentLength);
          }
        }
      } finally {
        await sink.close();
      }
    }
  }

  Future<void> uploadFile({
    required String url,
    required String filePath,
    Map<String, String>? headers,
    Function(double)? onProgress,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final request = http.MultipartRequest('POST', Uri.parse(url));

    if (headers != null) {
      request.headers.addAll(headers);
    }

    final stream = file.openRead();
    final length = await file.length();

    final multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: filePath.split('/').last,
    );

    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }
}
