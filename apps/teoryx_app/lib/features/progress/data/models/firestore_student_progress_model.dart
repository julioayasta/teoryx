import '../../domain/entities/student_progress.dart';

class FirestoreStudentProgressModel {
  const FirestoreStudentProgressModel({
    required this.studentId,
    required this.courseId,
    required this.currentLessonId,
    required this.currentLessonTitle,
    required this.currentLessonStatus,
    required this.nextLessonId,
    required this.nextLessonTitle,
    required this.lessonProgressLabel,
    required this.masteryLevel,
    required this.lastAssessmentScorePercentage,
    required this.hasPendingReview,
    required this.pendingReviewCount,
  });

  final String studentId;
  final String courseId;
  final String currentLessonId;
  final String currentLessonTitle;
  final LessonProgressStatus? currentLessonStatus;
  final String nextLessonId;
  final String nextLessonTitle;
  final String lessonProgressLabel;
  final MasteryLevel? masteryLevel;
  final int? lastAssessmentScorePercentage;
  final bool hasPendingReview;
  final int pendingReviewCount;

  bool get isValid {
    return studentId.isNotEmpty &&
        courseId.isNotEmpty &&
        currentLessonId.isNotEmpty &&
        currentLessonTitle.isNotEmpty &&
        currentLessonStatus != null &&
        nextLessonId.isNotEmpty &&
        nextLessonTitle.isNotEmpty &&
        lessonProgressLabel.isNotEmpty &&
        masteryLevel != null;
  }

  StudentProgress toEntity() {
    return StudentProgress(
      studentId: studentId,
      courseId: courseId,
      currentLessonId: currentLessonId,
      currentLessonTitle: currentLessonTitle,
      currentLessonStatus: currentLessonStatus!,
      nextLessonId: nextLessonId,
      nextLessonTitle: nextLessonTitle,
      lessonProgressLabel: lessonProgressLabel,
      masteryLevel: masteryLevel!,
      lastAssessmentScorePercentage: lastAssessmentScorePercentage,
      hasPendingReview: hasPendingReview,
      pendingReviewCount: pendingReviewCount,
    );
  }

  static FirestoreStudentProgressModel fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return FirestoreStudentProgressModel(
      studentId: data['studentId'] as String? ?? id,
      courseId: data['courseId'] as String? ?? '',
      currentLessonId: data['currentLessonId'] as String? ?? '',
      currentLessonTitle: data['currentLessonTitle'] as String? ?? '',
      currentLessonStatus: _statusFromFirestore(
        data['currentLessonStatus'] as String?,
      ),
      nextLessonId: data['nextLessonId'] as String? ?? '',
      nextLessonTitle: data['nextLessonTitle'] as String? ?? '',
      lessonProgressLabel: data['lessonProgressLabel'] as String? ?? '',
      masteryLevel: _masteryLevelFromFirestore(data['masteryLevel'] as String?),
      lastAssessmentScorePercentage:
          data['lastAssessmentScorePercentage'] as int?,
      hasPendingReview: data['hasPendingReview'] as bool? ?? false,
      pendingReviewCount: data['pendingReviewCount'] as int? ?? 0,
    );
  }

  static LessonProgressStatus? _statusFromFirestore(String? value) {
    return switch (value) {
      'studying' => LessonProgressStatus.studying,
      'assessmentStarted' => LessonProgressStatus.assessmentStarted,
      'assessmentCompleted' => LessonProgressStatus.assessmentCompleted,
      'readyForNextLesson' => LessonProgressStatus.readyForNextLesson,
      _ => null,
    };
  }

  static MasteryLevel? _masteryLevelFromFirestore(String? value) {
    return switch (value) {
      'notStarted' => MasteryLevel.notStarted,
      'inProgress' => MasteryLevel.inProgress,
      'developing' => MasteryLevel.developing,
      'proficient' => MasteryLevel.proficient,
      'mastered' => MasteryLevel.mastered,
      _ => null,
    };
  }
}
