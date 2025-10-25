import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ProgressTile extends StatelessWidget {
  final String fileName;
  final int fileSize;
  final double progress;
  final String status;

  const ProgressTile({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                style: const TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    status == 'Completed'
                        ? AppTheme.primaryColor
                        : status.contains('Failed')
                            ? AppTheme.errorColor
                            : AppTheme.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              color: status == 'Completed'
                  ? AppTheme.primaryColor
                  : status.contains('Failed')
                      ? AppTheme.errorColor
                      : AppTheme.secondaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
