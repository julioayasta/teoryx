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
        essentialQuestion:
            'How can a fraction help us describe part of a whole?',
        learningObjective: LearningObjective(
          id: 'lo-fractions-whole',
          statement:
              'Understand that a fraction represents equal parts of a whole.',
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
            title: 'You Missed The Pizza Lesson',
            body:
                'Imagine you were absent when your class learned fractions today. No problem. Let us replay the lesson slowly. Your teacher brought one large pizza to the front table and said, "This pizza is our whole." That word matters: whole means the complete object before we cut or share anything. Four students came up to share it: Sofia, Mateo, Lena, and Amir. Sofia asked, "How can we make sure everyone gets a fair share?" The class decided that fair sharing means cutting the pizza into equal parts. If one slice is much bigger than another, the pieces are not equal and the fraction would not describe the share clearly. So before we write any numbers, we ask two questions: What is the whole? Are the parts equal?',
          ),
          LessonStep(
            id: 'fractions-whole-step-2',
            lessonId: 'fractions-whole',
            order: 2,
            type: LessonStepType.imagePlaceholder,
            title: 'Picture The Whole Before It Is Shared',
            body:
                'Future generated image: one whole pizza on a classroom table before it is cut, with a label that says "1 whole."',
            imageDescription:
                'A top-down classroom table showing one complete pizza. No slices are removed. A simple label points to the pizza and says "the whole."',
          ),
          LessonStep(
            id: 'fractions-whole-step-3',
            lessonId: 'fractions-whole',
            order: 3,
            type: LessonStepType.explanation,
            title: 'First, Name The Equal Parts',
            body:
                'The teacher cuts the pizza into 4 equal slices. Now the class can describe the pizza with fractions. The denominator is the bottom number in a fraction. It tells how many equal parts make the whole. Since this pizza was cut into 4 equal parts, the denominator is 4. Notice something important: the denominator is not the number of slices Sofia eats. It is the number of equal parts in the whole pizza. If the pizza were cut into 6 equal parts, the denominator would be 6. If it were cut into 8 equal parts, the denominator would be 8. The denominator is about how the whole is divided.',
          ),
          LessonStep(
            id: 'fractions-whole-step-4',
            lessonId: 'fractions-whole',
            order: 4,
            type: LessonStepType.imagePlaceholder,
            title: 'Visual Model: Four Equal Slices',
            body:
                'Future generated image: the same pizza divided into four equal slices, with light guide lines showing that every slice is the same size.',
            imageDescription:
                'A round pizza divided into four equal slices. Each slice is labeled as one of four equal parts.',
          ),
          LessonStep(
            id: 'fractions-whole-step-5',
            lessonId: 'fractions-whole',
            order: 5,
            type: LessonStepType.explanation,
            title: 'Then, Count The Parts We Are Talking About',
            body:
                'Now Sofia takes 1 slice. The numerator is the top number in a fraction. It tells how many of the equal parts we are talking about. Sofia has 1 of the 4 equal slices, so her share is 1/4. Read that as one fourth. If Sofia and Mateo put their slices together, they would have 2 of the 4 equal slices, or 2/4 of the pizza. If three students put their slices together, they would have 3/4. The denominator stays 4 because the whole was still divided into 4 equal parts. The numerator changes because the number of selected parts changes.',
          ),
          LessonStep(
            id: 'fractions-whole-step-6',
            lessonId: 'fractions-whole',
            order: 6,
            type: LessonStepType.question,
            title: 'Pause And Say It Back',
            body:
                'Before moving on, pause for a moment. Imagine you are explaining this to a classmate who also missed school. Use the words whole, equal parts, numerator, and denominator if you can.',
            prompt:
                'What fraction of the pizza did Sofia receive? Explain what the 1 and the 4 mean.',
            expectedAnswer:
                'Sofia received 1/4 of the pizza. The 1 means she received one equal slice, and the 4 means the whole pizza was divided into four equal slices.',
          ),
          LessonStep(
            id: 'fractions-whole-step-7',
            lessonId: 'fractions-whole',
            order: 7,
            type: LessonStepType.practice,
            title: 'Guided Practice: Sharing Cake',
            body:
                'Let us try a new example together. A birthday cake is the whole. The cake is cut into 8 equal pieces. Mateo takes 3 pieces for his table group. We do not start by guessing the fraction. We follow the same routine every time. First, identify the whole: one birthday cake. Next, count the equal parts in the whole: 8 pieces. That gives us the denominator. Then count how many parts Mateo has: 3 pieces. That gives us the numerator. So Mateo has 3/8 of the cake.',
            prompt: 'Write the fraction for Mateo\'s share of the cake.',
            expectedAnswer:
                'Mateo has 3/8 of the cake because he has 3 of the 8 equal pieces.',
          ),
          LessonStep(
            id: 'fractions-whole-step-8',
            lessonId: 'fractions-whole',
            order: 8,
            type: LessonStepType.imagePlaceholder,
            title: 'Visual Model: Three Eighths Of A Cake',
            body:
                'Future generated image: a rectangular sheet cake divided into eight equal pieces, with three pieces shaded.',
            imageDescription:
                'A sheet cake cut into 8 equal rectangles. Three rectangles are shaded and labeled as 3/8.',
          ),
          LessonStep(
            id: 'fractions-whole-step-9',
            lessonId: 'fractions-whole',
            order: 9,
            type: LessonStepType.practice,
            title: 'Independent Practice: Create A Fair Share',
            body:
                'Now you try. Draw one whole object that could be shared, such as a sandwich, a pan of brownies, a sheet cake, or a garden plot. Divide it into equal parts. Shade some of the parts. Then write the fraction that represents the shaded amount. Check your work by asking: Did I show one whole? Are all parts equal? Does the denominator match the total number of equal parts? Does the numerator match the number of shaded parts?',
            prompt:
                'Create your own fraction model and label the numerator, denominator, and whole.',
          ),
          LessonStep(
            id: 'fractions-whole-step-10',
            lessonId: 'fractions-whole',
            order: 10,
            type: LessonStepType.summary,
            title: 'What You Should Remember',
            body:
                'A fraction describes part of a whole when the whole is divided into equal parts. The denominator names the number of equal parts in the whole. The numerator names how many of those parts we are describing. In the pizza story, 1/4 means one of four equal slices. In the cake story, 3/8 means three of eight equal pieces. When you feel stuck, return to the same three questions: What is the whole? How many equal parts make the whole? How many parts are selected?',
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
          statement:
              'Compare two fractions using visual models and number sense.',
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

  List<Lesson> getLessonsForCourse(String courseId) {
    final lessons = getAvailableLessons();

    if (courseId == 'grade-4-ela') {
      return const [];
    }

    return lessons
        .where(
          (lesson) =>
              lesson.gradeLevelId == 'grade-4' && lesson.subjectId == 'math',
        )
        .toList();
  }

  Lesson getLessonById(String lessonId) {
    return getAvailableLessons().firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => getAvailableLessons().first,
    );
  }
}
