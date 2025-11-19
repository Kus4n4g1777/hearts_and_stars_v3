/// Detection model matching backend response format
/// Keeps original bbox structure that works with BoundingBoxPainter
class Detection {
  final String label;
  final double confidence;
  final List<double> bbox; // Keep as raw list [x1, y1, x2, y2] normalized

  Detection({
    required this.label,
    required this.confidence,
    required this.bbox,
  });

  /// Factory from JSON (backend format)
  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      label: json['label'] as String? ?? 'Object',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      bbox: List<double>.from(
        (json['bbox'] as List).map((v) => v.toDouble())
      ),
    );
  }

  /// Convert to Map (matches original format for BoundingBoxPainter)
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'confidence': confidence,
      'bbox': bbox,
    };
  }

  /// Check if high confidence
  bool get isHighConfidence => confidence >= 0.9;

  @override
  String toString() {
    return 'Detection(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, bbox: $bbox)';
  }
}

/// Helper class for detection list management
class DetectionList {
  final List<Detection> items;
  final DateTime timestamp;

  DetectionList({
    required this.items,
    required this.timestamp,
  });

  /// Factory from WebSocket JSON response
  factory DetectionList.fromJson(Map<String, dynamic> json) {
    final detectionsJson = json['detections'] as List? ?? [];
    return DetectionList(
      items: detectionsJson
          .map((d) => Detection.fromJson(d as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.now(),
    );
  }

  /// Convert to list of maps (for BoundingBoxPainter compatibility)
  List<Map<String, dynamic>> toMapList() {
    return items.map((d) => d.toMap()).toList();
  }

  /// Get count
  int get count => items.length;

  /// Filter by confidence threshold
  List<Detection> filterByConfidence(double threshold) {
    return items.where((d) => d.confidence >= threshold).toList();
  }
}