import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class FileTransfer {
  static Future<void> downloadFile({
    required String url,
    required String savePath,
    required Function(double) onProgress,
    required Function() onComplete,
    required Function(String) onError,
  }) async {
    try {
      final file = File(savePath);
      final sink = file.openWrite();
      
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await request.send();
      
      final contentLength = streamedResponse.contentLength ?? 0;
      int downloaded = 0;
      
      final stream = streamedResponse.stream;
      stream.listen(
        (data) {
          sink.add(data);
          downloaded += data.length;
          
          if (contentLength > 0) {
            final progress = downloaded / contentLength;
            onProgress(progress);
          }
        },
        onDone: () {
          sink.close();
          onComplete();
        },
        onError: (e) {
          sink.close();
          onError(e.toString());
        },
        cancelOnError: true,
      );
    } catch (e) {
      onError(e.toString());
    }
  }
}