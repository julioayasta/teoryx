import '../../domain/entities/learning_objective.dart';
import '../../domain/entities/lesson.dart';

class MockLessonRepository {
  const MockLessonRepository();

  List<Lesson> getAvailableLessons() {
    return const [
      Lesson(
        id: 'fractions-whole',
        schoolId: 'school-demo',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
        standardId: 'ccss-math-4-nf-a-1',
        standardCode: 'CCSS.MATH.4.NF.A.1',
        language: 'en',
        title: 'Fractions as Parts of a Whole',
        bigIdea: 'Fractions describe equal parts of one whole.',
        essentialQuestion: 'How can a fraction help us describe part of a whole?',
        learningObjective: LearningObjective(
          id: 'lo-fractions-whole',
          statement: 'Understand that a fraction represents equal parts of a whole.',
        ),
        lessonContent:
            'A whole can be divided into equal parts. The denominator tells how many equal parts make the whole, and the numerator tells how many parts are being described.',
        guidedPractice:
            'Look at a rectangle divided into 4 equal parts. If 1 part is shaded, name the fraction and explain what each number means.',
        independentPractice:
            'Draw a circle divided into 6 equal parts. Shade 2 parts and write the fraction that represents the shaded part.',
        summary:
            'Fractions use a numerator and denominator to describe equal parts of a whole.',
      ),
      Lesson(
        id: 'comparing-fractions',
        schoolId: 'school-demo',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
        standardId: 'ccss-math-4-nf-a-2',
        standardCode: 'CCSS.MATH.4.NF.A.2',
        language: 'en',
        title: 'Comparing Fractions',
        bigIdea: 'Fractions can be compared by reasoning about their size.',
        essentialQuestion: 'How do we know which fraction is greater?',
        learningObjective: LearningObjective(
          id: 'lo-comparing-fractions',
          statement: 'Compare two fractions using visual models and number sense.',
        ),
        lessonContent:
            'When fractions refer to the same whole, we can compare them using models, common denominators, or benchmarks like one half.',
        guidedPractice:
            'Compare 1/4 and 3/4 using a fraction bar. Explain why one fraction is greater.',
        independentPractice:
            'Compare 2/3 and 2/6. Draw a model or explain your reasoning in words.',
        summary:
            'Comparing fractions requires checking the whole, then reasoning about numerator and denominator.',
      ),
      Lesson(
        id: 'equivalent-fractions',
        schoolId: 'school-demo',
        curriculumId: 'ca-common-core',
        gradeLevelId: 'grade-4',
        subjectId: 'math',
        standardId: 'ccss-math-4-nf-a-1',
        standardCode: 'CCSS.MATH.4.NF.A.1',
        language: 'en',
        title: 'Equivalent Fractions',
        bigIdea: 'Different fractions can name the same amount.',
        essentialQuestion: 'How can two different fractions be equal?',
        learningObjective: LearningObjective(
          id: 'lo-equivalent-fractions',
          statement: 'Recognize and generate equivalent fractions.',
        ),
        lessonContent:
            'Equivalent fractions represent the same value. Multiplying or dividing the numerator and denominator by the same number creates an equivalent fraction.',
        guidedPractice:
            'Use a model to show why 1/2 and 2/4 represent the same amount.',
        independentPractice:
            'Write two fractions equivalent to 3/6 and explain how you know.',
        summary:
            'Equivalent fractions may look different, but they represent the same part of a whole.',
      ),
    ];
  }

  Lesson getLessonById(String lessonId) {
    return getAvailableLessons().firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => getAvailableLessons().first,
    );
  }
}
