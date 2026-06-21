import 'package:equatable/equatable.dart';

class AnswerOption extends Equatable {
  const AnswerOption({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;

  @override
  List<Object?> get props => [id, label, value];
}
