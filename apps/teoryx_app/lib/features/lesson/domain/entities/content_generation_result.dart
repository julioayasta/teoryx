import 'package:equatable/equatable.dart';

enum ContentGenerationStatus { pending, ready, failed }

class ContentGenerationResult extends Equatable {
  const ContentGenerationResult({
    required this.status,
    this.requestId,
    this.publishedContentId,
    this.message,
  });

  final ContentGenerationStatus status;
  final String? requestId;
  final String? publishedContentId;
  final String? message;

  bool get isReady => status == ContentGenerationStatus.ready;

  bool get isPending => status == ContentGenerationStatus.pending;

  bool get isFailed => status == ContentGenerationStatus.failed;

  @override
  List<Object?> get props => [status, requestId, publishedContentId, message];
}
