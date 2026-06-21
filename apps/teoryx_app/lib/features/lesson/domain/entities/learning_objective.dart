import 'package:equatable/equatable.dart';

class LearningObjective extends Equatable {
  const LearningObjective({required this.id, required this.statement});

  final String id;
  final String statement;

  @override
  List<Object?> get props => [id, statement];
}
