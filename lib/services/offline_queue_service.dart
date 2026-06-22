import 'dart:async';

class OfflineQueueService {
  final _queue = <QueuedOperation>[];
  bool _isProcessing = false;

  void add(QueuedOperation operation) {
    _queue.add(operation);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final operation = _queue.removeAt(0);

      try {
        await operation.execute();
      } catch (e) {
        // Retry later with exponential backoff
        await Future.delayed(_calculateBackoff(operation.retryCount));
        operation.retryCount++;

        if (operation.retryCount < 5) {
          _queue.add(operation);
        } else {
          // Max retries reached
          print('Operation failed after 5 retries: $e');
        }
      }
    }

    _isProcessing = false;
  }

  Duration _calculateBackoff(int retryCount) {
    final seconds = [2, 5, 10, 30, 60, 120, 300][retryCount.clamp(0, 5)] * 1000;
    return Duration(milliseconds: seconds);
  }
}

class QueuedOperation {
  final Future<void> Function() execute;
  int retryCount = 0;

  QueuedOperation(this.execute);
}