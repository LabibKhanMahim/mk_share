import 'package:flutter/material.dart';
import 'cyber_text.dart';
import '../screens/receive_screen.dart';

class ProgressTile extends StatelessWidget {
  final String fileName;
  final double progress;
  final DownloadStatus status;

  const ProgressTile({
    super.key,
    required this.fileName,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case DownloadStatus.pending:
        statusColor = Colors.yellow;
        statusText = 'PENDING';
        break;
      case DownloadStatus.downloading:
        statusColor = Colors.blue;
        statusText = 'DOWNLOADING';
        break;
      case DownloadStatus.completed:
        statusColor = Colors.green;
        statusText = 'COMPLETED';
        break;
      case DownloadStatus.failed:
        statusColor = Colors.red;
        statusText = 'FAILED';
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CyberText(
                  text: fileName,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              CyberText(
                text: statusText,
                size: 12,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          const SizedBox(height: 5),
          CyberText(
            text: '${(progress * 100).toStringAsFixed(1)}%',
            size: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}