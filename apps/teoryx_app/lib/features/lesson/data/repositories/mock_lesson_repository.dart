import '../../domain/entities/learning_objective.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_step.dart';

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
        steps: [
          LessonStep(
            id: 'fractions-whole-step-1',
            lessonId: 'fractions-whole',
            order: 1,
            type: LessonStepType.story,
            title: 'A Pizza For The Study Group',
            body:
                'Sofia and three classmates stay after school to work on their math project. Their teacher brings one large pizza as a snack. The pizza is not four separate pizzas. It is one whole pizza that everyone will share. Before anyone takes a slice, Sofia says, "If we want this to be fair, each person should get the same amount." The group agrees to cut the pizza into equal pieces so that each student can describe their share clearly.',
          ),
          LessonStep(
            id: 'fractions-whole-step-2',
            lessonId: 'fractions-whole',
            order: 2,
            type: LessonStepType.imagePlaceholder,
            title: 'Visual Model Placeholder',
            body:
                'Future generated image: one round pizza divided into 4 equal slices, with 1 slice highlighted for Sofia and the remaining 3 slices unshaded for her classmates.',
            imageDescription:
                'A top-down classroom table with one pizza cut into four equal slices. One slice is highlighted to show one fourth.',
          ),
          LessonStep(
            id: 'fractions-whole-step-3',
            lessonId: 'fractions-whole',
            order: 3,
            type: LessonStepType.explanation,
            title: 'What The Denominator Tells Us',
            body:
                'The denominator is the bottom number in a fraction. It tells how many equal parts make one whole. In this story, the whole is the entire pizza. The group cuts the pizza into 4 equal parts, so the denominator is 4. The denominator does not count how many slices Sofia ate. It describes how the whole pizza was partitioned. If the pieces were not equal, the group could not use one simple fraction to describe a fair share.',
          ),
          LessonStep(
            id: 'fractions-whole-step-4',
            lessonId: 'fractions-whole',
            order: 4,
            type: LessonStepType.explanation,
            title: 'What The Numerator Tells Us',
            body:
                'The numerator is the top number in a fraction. It tells how many of the equal parts we are talking about. Sofia receives 1 of the 4 equal slices. Her share is written as 1/4. We read this as one fourth. If two classmates put their slices together, they would have 2 of the 4 equal parts, or 2/4 of the pizza. The numerator changes when the number of selected parts changes.',
          ),
          LessonStep(
            id: 'fractions-whole-step-5',
            lessonId: 'fractions-whole',
            order: 5,
            type: LessonStepType.question,
            title: 'Check Your Understanding',
            body:
                'Think about the pizza as one whole. The whole was divided into 4 equal slices, and Sofia received 1 slice.',
            prompt: 'What fraction of the pizza did Sofia receive? Explain what the 1 and the 4 mean.',
            expectedAnswer:
                'Sofia received 1/4 of the pizza. The 1 means she received one equal slice, and the 4 means the whole pizza was divided into four equal slices.',
          ),
          LessonStep(
            id: 'fractions-whole-step-6',
            lessonId: 'fractions-whole',
            order: 6,
            type: LessonStepType.practice,
            title: 'Guided Practice: Sharing Cake',
            body:
                'Now imagine a birthday cake instead of a pizza. The cake is cut into 8 equal pieces. Mateo takes 3 pieces for his table group. First, identify the whole. Next, identify how many equal parts make the whole. Then identify how many parts Mateo has. Use those ideas to write the fraction. Read your fraction aloud and explain why the denominator is 8, not 3.',
            prompt: 'Write the fraction for Mateo\'s share of the cake.',
            expectedAnswer:
                'Mateo has 3/8 of the cake because he has 3 of the 8 equal pieces.',
          ),
          LessonStep(
            id: 'fractions-whole-step-7',
            lessonId: 'fractions-whole',
            order: 7,
            type: LessonStepType.practice,
            title: 'Independent Practice: Create A Fair Share',
            body:
                'Draw one whole object that could be shared, such as a sandwich, a pan of brownies, a sheet cake, or a garden plot. Divide it into equal parts. Shade some of the parts. Then write the fraction that represents the shaded amount. Your drawing must make the equal parts clear, because fractions depend on equal-sized parts.',
            prompt:
                'Create your own fraction model and label the numerator, denominator, and whole.',
          ),
          LessonStep(
            id: 'fractions-whole-step-8',
            lessonId: 'fractions-whole',
            order: 8,
            type: LessonStepType.summary,
            title: 'Lesson Summary',
            body:
                'A fraction describes part of a whole when the whole is divided into equal parts. The denominator names the number of equal parts in the whole. The numerator names how many of those parts we are describing. In the pizza story, 1/4 means one of four equal slices. In the cake story, 3/8 means three of eight equal pieces. Always ask: What is the whole? Are the parts equal? How many equal parts are selected?',
          ),
        ],
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
        steps: [
          LessonStep(
            id: 'comparing-fractions-step-1',
            lessonId: 'comparing-fractions',
            order: 1,
            type: LessonStepType.story,
            title: 'Two Tables, Two Pizzas',
            body:
                'Two tables each receive one same-size pizza. One table eats 1/4 of its pizza. The other table eats 3/4 of its pizza. Since the wholes are the same size and the pizzas are cut into the same number of equal parts, the group can compare the numerators.',
          ),
          LessonStep(
            id: 'comparing-fractions-step-2',
            lessonId: 'comparing-fractions',
            order: 2,
            type: LessonStepType.summary,
            title: 'Comparison Takeaway',
            body:
                'When denominators are the same and the wholes are equal, the fraction with the greater numerator is greater.',
          ),
        ],
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
        steps: [
          LessonStep(
            id: 'equivalent-fractions-step-1',
            lessonId: 'equivalent-fractions',
            order: 1,
            type: LessonStepType.story,
            title: 'Sharing The Same Amount',
            body:
                'A cake is first cut into 2 equal pieces. One half is saved. Later, that same half is cut into 2 smaller equal pieces. The saved amount can be described as 1/2 or 2/4 because both fractions name the same amount of the same whole.',
          ),
          LessonStep(
            id: 'equivalent-fractions-step-2',
            lessonId: 'equivalent-fractions',
            order: 2,
            type: LessonStepType.summary,
            title: 'Equivalent Fraction Takeaway',
            body:
                'Equivalent fractions use different numerators and denominators to name the same value.',
          ),
        ],
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
