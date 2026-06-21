import 'package:flutter_test/flutter_test.dart';
import 'package:teoryx_app/core/data/firestore/firestore_collection_paths.dart';
import 'package:teoryx_app/features/lesson/data/models/firestore_lesson_specification_model.dart';
import 'package:teoryx_app/features/lesson/data/models/firestore_course_model.dart';
import 'package:teoryx_app/features/lesson/data/models/firestore_published_lesson_model.dart';
import 'package:teoryx_app/features/lesson/data/repositories/mock_content_generation_repository.dart';
import 'package:teoryx_app/features/lesson/data/repositories/firestore_course_repository.dart';
import 'package:teoryx_app/features/lesson/data/repositories/firestore_published_lesson_repository.dart';
import 'package:teoryx_app/features/lesson/data/repositories/mock_course_repository.dart';
import 'package:teoryx_app/features/lesson/data/repositories/mock_lesson_repository.dart';
import 'package:teoryx_app/features/lesson/data/repositories/mock_lesson_specification_repository.dart';
import 'package:teoryx_app/features/lesson/domain/entities/content_generation_result.dart';
import 'package:teoryx_app/features/lesson/domain/repositories/course_repository.dart';
import 'package:teoryx_app/features/lesson/domain/repositories/lesson_repository.dart';
import 'package:teoryx_app/features/progress/data/models/firestore_student_progress_model.dart';
import 'package:teoryx_app/features/progress/data/repositories/firestore_progress_repository.dart';
import 'package:teoryx_app/features/progress/data/repositories/mock_progress_repository.dart';
import 'package:teoryx_app/features/progress/domain/entities/student_progress.dart';
import 'package:teoryx_app/features/school/data/models/firestore_school_theme_model.dart';
import 'package:teoryx_app/features/student/data/models/firestore_student_profile_model.dart';
import 'package:teoryx_app/features/student/data/repositories/firestore_student_repository.dart';
import 'package:teoryx_app/features/student/data/repositories/mock_student_repository.dart';
import 'package:teoryx_app/features/student/domain/repositories/student_repository.dart';

void main() {
  test('Firestore collection paths stay tenant scoped where required', () {
    expect(
      FirestoreCollectionPaths.school('school-demo'),
      'schools/school-demo',
    );
    expect(
      FirestoreCollectionPaths.student(
        schoolId: 'school-demo',
        studentId: 'student-001',
      ),
      'schools/school-demo/students/student-001',
    );
    expect(
      FirestoreCollectionPaths.course(
        schoolId: 'school-demo',
        courseId: 'grade-4-math',
      ),
      'schools/school-demo/courses/grade-4-math',
    );
    expect(
      FirestoreCollectionPaths.studentProgress(
        schoolId: 'school-demo',
        studentId: 'student-001',
      ),
      'schools/school-demo/studentProgress/student-001',
    );
    expect(
      FirestoreCollectionPaths.publishedLessonContent,
      'publishedLessonContent',
    );
  });

  test('mock repositories satisfy repository contracts by default', () async {
    const StudentRepository studentRepository = MockStudentRepository();
    const CourseRepository courseRepository = MockCourseRepository();
    const LessonRepository lessonRepository = MockLessonRepository();

    final student = studentRepository.getCurrentStudent();
    final courses = courseRepository.getAvailableCourses('en');
    final lessons = lessonRepository.getLessonsForCourse('grade-4-math', 'en');

    expect(student.schoolId, 'school-demo');
    expect(courses, isNotEmpty);
    expect(lessons, isNotEmpty);
    expect(
      await studentRepository.getStudentProfile(
        schoolId: 'missing-school',
        studentId: 'missing-student',
      ),
      isNull,
    );
  });

  test('Firestore mappers create domain read models', () {
    final student = FirestoreStudentProfileModel.fromFirestore(
      id: 'student-001',
      schoolId: 'school-demo',
      data: const {
        'studentId': 'student-001',
        'firstName': 'Sofia',
        'lastName': 'Rivera',
        'gradeLevelId': 'grade-4',
        'gradeLevelName': 'Grade 4',
        'preferredLanguage': 'en',
        'status': 'active',
      },
    );

    final course = FirestoreCourseModel.fromFirestore(
      id: 'grade-4-math',
      data: const {
        'curriculumId': 'ca-common-core',
        'gradeLevelId': 'grade-4',
        'gradeLevelName': 'Grade 4',
        'subjectId': 'math',
        'subjectName': 'Math',
        'title': 'Grade 4 Math',
        'status': 'published',
        'order': 1,
      },
    ).toEntity();

    final schoolTheme = FirestoreSchoolThemeModel.fromFirestore(const {
      'name': 'Demo School',
      'fullName': 'Demo School for Learning',
      'logoUrl': 'https://example.com/demo-logo.png',
      'primaryColor': '#123456',
      'secondaryColor': '#ABCDEF',
      'fontFamily': 'Atkinson Hyperlegible',
    }).toEntity();

    final lesson = FirestorePublishedLessonModel.fromFirestore(
      id: 'fractions-whole',
      data: const {
        'schoolId': 'school-demo',
        'courseId': 'grade-4-math',
        'publishedContentId': 'fractions-whole',
        'curriculumId': 'ca-common-core',
        'gradeLevelId': 'grade-4',
        'subjectId': 'math',
        'standardId': 'ccss-math-4-nf-a-1',
        'standardCode': 'CCSS.MATH.4.NF.A.1',
        'language': 'en',
        'title': 'Fractions as Parts of a Whole',
        'bigIdea': 'Fractions describe equal parts.',
        'essentialQuestion': 'How do fractions describe a whole?',
        'learningObjectiveId': 'lo-fractions-whole',
        'learningObjective': 'Understand fractions as equal parts.',
        'lessonContent': 'A whole can be divided into equal parts.',
        'guidedPractice': 'Name one fourth.',
        'independentPractice': 'Draw a fraction.',
        'summary': 'Fractions name equal parts.',
        'status': 'published',
        'version': 1,
        'presentationContract': {'template': 'guidedLesson'},
        'steps': [
          {
            'id': 'step-1',
            'order': 1,
            'type': 'story',
            'title': 'A whole pizza',
            'body': 'Start with one whole.',
          },
        ],
      },
    ).toEntity();
    final lessonSpecification = FirestoreLessonSpecificationModel.fromFirestore(
      id: 'spec-fractions-whole',
      data: const {
        'lessonId': 'lesson-fractions-whole',
        'schoolId': 'school-demo',
        'courseId': 'grade-4-math',
        'courseOfferingId': 'offering-school-demo-grade-4-math-en',
        'title': 'Fractions as Parts of a Whole',
        'order': 1,
        'language': 'en',
        'generationStatus': 'not_generated',
        'estimatedDuration': '20 minutes',
        'difficultyLevel': 'foundational',
        'status': 'active',
      },
    );
    final progress = FirestoreStudentProgressModel.fromFirestore(
      id: 'student-001',
      data: const {
        'studentId': 'student-001',
        'courseId': 'grade-4-math',
        'currentLessonId': 'comparing-fractions',
        'currentLessonTitle': 'Comparing Fractions',
        'currentLessonStatus': 'studying',
        'nextLessonId': 'equivalent-fractions',
        'nextLessonTitle': 'Equivalent Fractions',
        'lessonProgressLabel': 'Lesson 2 of 8',
        'masteryLevel': 'inProgress',
        'lastAssessmentScorePercentage': 67,
        'hasPendingReview': true,
        'pendingReviewCount': 2,
      },
    );

    expect(student.isValid, isTrue);
    expect(student.toEntity().firstName, 'Sofia');
    expect(course.title, 'Grade 4 Math');
    expect(schoolTheme.schoolName, 'Demo School');
    expect(schoolTheme.logoAssetPath, 'assets/schools/k2s/k2s_logo.png');
    expect(lesson.id, 'fractions-whole');
    expect(lesson.learningObjective.id, 'lo-fractions-whole');
    expect(lesson.steps.single.title, 'A whole pizza');
    expect(lessonSpecification.isValid, isTrue);
    expect(lessonSpecification.toEntity().id, 'spec-fractions-whole');
    expect(progress.isValid, isTrue);
    expect(
      progress.toEntity().currentLessonStatus,
      LessonProgressStatus.studying,
    );
  });

  test('Firestore course mapper rejects inactive or incomplete courses', () {
    final inactiveCourse = FirestoreCourseModel.fromFirestore(
      id: 'grade-4-math',
      data: const {
        'courseId': 'grade-4-math',
        'curriculumId': 'ca-common-core',
        'gradeLevelId': 'grade-4',
        'gradeLevelName': 'Grade 4',
        'subjectId': 'math',
        'subjectName': 'Math',
        'title': 'Grade 4 Math',
        'status': 'inactive',
        'order': 1,
      },
    );
    final missingTitle = FirestoreCourseModel.fromFirestore(
      id: 'grade-4-math',
      data: const {
        'courseId': 'grade-4-math',
        'curriculumId': 'ca-common-core',
        'gradeLevelId': 'grade-4',
        'gradeLevelName': 'Grade 4',
        'subjectId': 'math',
        'subjectName': 'Math',
        'status': 'published',
        'order': 1,
      },
    );

    expect(inactiveCourse.isValid, isFalse);
    expect(missingTitle.isValid, isFalse);
  });

  test(
    'Firestore published lesson mapper rejects unpublished or unsafe steps',
    () {
      final unpublishedLesson = FirestorePublishedLessonModel.fromFirestore(
        id: 'fractions-whole',
        data: const {
          'publishedContentId': 'fractions-whole',
          'courseId': 'grade-4-math',
          'curriculumId': 'ca-common-core',
          'gradeLevelId': 'grade-4',
          'subjectId': 'math',
          'standardId': 'ccss-math-4-nf-a-1',
          'standardCode': 'CCSS.MATH.4.NF.A.1',
          'language': 'en',
          'title': 'Fractions',
          'bigIdea': 'Fractions describe equal parts.',
          'essentialQuestion': 'How do fractions describe a whole?',
          'learningObjective': 'Understand fractions.',
          'lessonContent': 'Content',
          'guidedPractice': 'Guided',
          'independentPractice': 'Practice',
          'summary': 'Summary',
          'status': 'draft',
          'steps': [
            {
              'id': 'step-1',
              'order': 1,
              'type': 'story',
              'title': 'Story',
              'body': 'Body',
            },
          ],
        },
      );
      final unsafeLesson = FirestorePublishedLessonModel.fromFirestore(
        id: 'fractions-whole',
        data: const {
          'publishedContentId': 'fractions-whole',
          'courseId': 'grade-4-math',
          'curriculumId': 'ca-common-core',
          'gradeLevelId': 'grade-4',
          'subjectId': 'math',
          'standardId': 'ccss-math-4-nf-a-1',
          'standardCode': 'CCSS.MATH.4.NF.A.1',
          'language': 'en',
          'title': 'Fractions',
          'bigIdea': 'Fractions describe equal parts.',
          'essentialQuestion': 'How do fractions describe a whole?',
          'learningObjective': 'Understand fractions.',
          'lessonContent': 'Content',
          'guidedPractice': 'Guided',
          'independentPractice': 'Practice',
          'summary': 'Summary',
          'status': 'published',
          'steps': [
            {
              'id': 'step-1',
              'order': 1,
              'type': 'interactiveSimulation',
              'title': 'Unsupported',
              'body': 'Body',
            },
          ],
        },
      );

      expect(unpublishedLesson.isValid, isFalse);
      expect(unsafeLesson.hasUnsupportedSteps, isTrue);
      expect(unsafeLesson.isValid, isFalse);
    },
  );

  test('Firestore student mapper rejects missing or inactive profiles', () {
    final missingFirstName = FirestoreStudentProfileModel.fromFirestore(
      id: 'student-001',
      schoolId: 'school-demo',
      data: const {
        'studentId': 'student-001',
        'gradeLevelId': 'grade-4',
        'gradeLevelName': 'Grade 4',
        'preferredLanguage': 'en',
        'status': 'active',
      },
    );
    final inactiveProfile = FirestoreStudentProfileModel.fromFirestore(
      id: 'student-001',
      schoolId: 'school-demo',
      data: const {
        'studentId': 'student-001',
        'firstName': 'Sofia',
        'gradeLevelId': 'grade-4',
        'gradeLevelName': 'Grade 4',
        'preferredLanguage': 'en',
        'status': 'inactive',
      },
    );

    expect(missingFirstName.isValid, isFalse);
    expect(inactiveProfile.isValid, isFalse);
  });

  test('Firestore progress mapper rejects unsupported status or mastery', () {
    final unsupportedStatus = FirestoreStudentProgressModel.fromFirestore(
      id: 'student-001',
      data: const {
        'studentId': 'student-001',
        'courseId': 'grade-4-math',
        'currentLessonId': 'comparing-fractions',
        'currentLessonTitle': 'Comparing Fractions',
        'currentLessonStatus': 'paused',
        'nextLessonId': 'equivalent-fractions',
        'nextLessonTitle': 'Equivalent Fractions',
        'lessonProgressLabel': 'Lesson 2 of 8',
        'masteryLevel': 'inProgress',
      },
    );
    final unsupportedMastery = FirestoreStudentProgressModel.fromFirestore(
      id: 'student-001',
      data: const {
        'studentId': 'student-001',
        'courseId': 'grade-4-math',
        'currentLessonId': 'comparing-fractions',
        'currentLessonTitle': 'Comparing Fractions',
        'currentLessonStatus': 'studying',
        'nextLessonId': 'equivalent-fractions',
        'nextLessonTitle': 'Equivalent Fractions',
        'lessonProgressLabel': 'Lesson 2 of 8',
        'masteryLevel': 'expert',
      },
    );

    expect(unsupportedStatus.isValid, isFalse);
    expect(unsupportedMastery.isValid, isFalse);
  });

  test('Firestore student repository exposes mock fallback by default', () {
    final repository = FirestoreStudentRepository(
      schoolId: 'school-demo',
      studentId: 'student-001',
      fallbackRepository: const MockStudentRepository(),
    );

    expect(repository.getCurrentStudent().firstName, 'Sofia');
  });

  test('Firestore course repository exposes mock fallback by default', () {
    final repository = FirestoreCourseRepository(
      schoolId: 'school-demo',
      fallbackRepository: const MockCourseRepository(),
    );

    expect(repository.getAvailableCourses('en'), hasLength(4));
    expect(repository.getCoursesForGrade('grade-4', 'en'), hasLength(2));
    expect(
      repository.getCourseById('grade-4-math', 'en').title,
      'Grade 4 Math',
    );
  });

  test(
    'Firestore published lesson repository exposes mock fallback by default',
    () {
      final repository = FirestorePublishedLessonRepository(
        fallbackRepository: const MockLessonRepository(),
      );

      expect(repository.getLessonsForCourse('grade-4-math', 'en'), isNotEmpty);
      expect(
        repository.getLessonById('comparing-fractions', 'en').title,
        'Comparing Fractions',
      );
    },
  );

  test(
    'CE callable repositories expose safe mock fallback by default',
    () async {
      const lessonSpecificationRepository = MockLessonSpecificationRepository();
      const contentGenerationRepository = MockContentGenerationRepository();

      expect(
        await lessonSpecificationRepository.getLessonSpecificationsForCourse(
          'grade-4-math',
          'en',
        ),
        isEmpty,
      );
      expect(
        await lessonSpecificationRepository.getLessonSpecificationById(
          'missing-spec',
          'en',
        ),
        isNull,
      );

      final generationResult = await contentGenerationRepository
          .requestLessonContent(
            schoolId: 'school-demo',
            courseOfferingId: 'offering-school-demo-grade-4-math-en',
            courseId: 'grade-4-math',
            lessonSpecificationId: 'spec-fractions-whole',
            languageCode: 'en',
          );

      expect(generationResult.status, ContentGenerationStatus.failed);
    },
  );

  test('Firestore progress repository exposes mock fallback by default', () {
    final repository = FirestoreProgressRepository(
      schoolId: 'school-demo',
      studentId: 'student-001',
      fallbackRepository: const MockProgressRepository(),
    );

    expect(
      repository.getStudentProgress('student-001', 'en').currentLessonId,
      'comparing-fractions',
    );
    expect(
      repository
          .getCourseProgress('student-001', 'grade-4-math', 'en')
          .courseId,
      'grade-4-math',
    );
  });
}
