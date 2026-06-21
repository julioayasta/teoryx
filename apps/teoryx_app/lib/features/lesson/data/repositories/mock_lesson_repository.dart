import '../../domain/entities/learning_objective.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_step.dart';
import '../../domain/repositories/lesson_repository.dart';

class MockLessonRepository implements LessonRepository {
  const MockLessonRepository();

  @override
  List<Lesson> getAvailableLessons([String languageCode = 'en']) {
    if (languageCode == 'es') {
      return _spanishLessons;
    }

    return _englishLessons;
  }

  @override
  List<Lesson> getLessonsForCourse(String courseId, String languageCode) {
    final lessons = getAvailableLessons(languageCode);

    if (courseId == 'grade-4-ela' ||
        courseId == 'grade-5-math' ||
        courseId == 'grade-5-ela') {
      return const [];
    }

    return lessons
        .where(
          (lesson) =>
              lesson.gradeLevelId == 'grade-4' && lesson.subjectId == 'math',
        )
        .toList();
  }

  @override
  Lesson getLessonById(String lessonId, String languageCode) {
    return getAvailableLessons(languageCode).firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => getAvailableLessons(languageCode).first,
    );
  }

  @override
  Future<Lesson?> getPublishedLessonById(
    String lessonId,
    String languageCode,
  ) async {
    for (final lesson in getAvailableLessons(languageCode)) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }

    return null;
  }
}

const _englishLessons = [
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

const _spanishLessons = [
  Lesson(
    id: 'fractions-whole',
    schoolId: 'school-demo',
    curriculumId: 'ca-common-core',
    gradeLevelId: 'grade-4',
    subjectId: 'math',
    standardId: 'ccss-math-4-nf-a-1',
    standardCode: 'CCSS.MATH.4.NF.A.1',
    language: 'es',
    title: 'Fracciones como partes de un entero',
    bigIdea: 'Las fracciones describen partes iguales de un entero.',
    essentialQuestion:
        'Como puede una fraccion ayudarnos a describir una parte de un entero?',
    learningObjective: LearningObjective(
      id: 'lo-fractions-whole',
      statement:
          'Comprender que una fraccion representa partes iguales de un entero.',
    ),
    lessonContent:
        'Un entero puede dividirse en partes iguales. El denominador indica cuantas partes iguales forman el entero y el numerador indica cuantas partes estamos describiendo.',
    guidedPractice:
        'Observa un rectangulo dividido en 4 partes iguales. Si 1 parte esta sombreada, nombra la fraccion y explica que significa cada numero.',
    independentPractice:
        'Dibuja un circulo dividido en 6 partes iguales. Sombrea 2 partes y escribe la fraccion que representa la parte sombreada.',
    summary:
        'Las fracciones usan numerador y denominador para describir partes iguales de un entero.',
    steps: [
      LessonStep(
        id: 'fractions-whole-step-1',
        lessonId: 'fractions-whole',
        order: 1,
        type: LessonStepType.story,
        title: 'Te perdiste la leccion de pizza',
        body:
            'Imagina que faltaste cuando tu clase aprendio fracciones hoy. No pasa nada. Vamos a reconstruir la leccion poco a poco. Tu maestra llevo una pizza grande a la mesa y dijo: "Esta pizza es nuestro entero." Esa palabra importa: entero significa el objeto completo antes de cortar o compartir. Cuatro estudiantes van a compartirla. La clase decide que compartir de forma justa significa cortar la pizza en partes iguales. Antes de escribir numeros, preguntamos: cual es el entero? Las partes son iguales?',
      ),
      LessonStep(
        id: 'fractions-whole-step-2',
        lessonId: 'fractions-whole',
        order: 2,
        type: LessonStepType.imagePlaceholder,
        title: 'Imagina el entero antes de compartir',
        body:
            'Imagen futura generada: una pizza entera sobre una mesa antes de cortarla, con una etiqueta que dice "1 entero".',
        imageDescription:
            'Una pizza completa vista desde arriba. Ninguna porcion ha sido retirada. Una etiqueta senala la pizza y dice "el entero".',
      ),
      LessonStep(
        id: 'fractions-whole-step-3',
        lessonId: 'fractions-whole',
        order: 3,
        type: LessonStepType.explanation,
        title: 'Primero, nombra las partes iguales',
        body:
            'La maestra corta la pizza en 4 porciones iguales. Ahora podemos describirla con fracciones. El denominador es el numero de abajo. Indica cuantas partes iguales forman el entero. Como la pizza se corto en 4 partes iguales, el denominador es 4. El denominador no cuenta cuantas porciones come Sofia; describe como se dividio el entero.',
      ),
      LessonStep(
        id: 'fractions-whole-step-4',
        lessonId: 'fractions-whole',
        order: 4,
        type: LessonStepType.imagePlaceholder,
        title: 'Modelo visual: cuatro porciones iguales',
        body:
            'Imagen futura generada: la misma pizza dividida en cuatro porciones iguales.',
        imageDescription:
            'Una pizza redonda dividida en cuatro porciones iguales. Cada porcion esta marcada como una de cuatro partes iguales.',
      ),
      LessonStep(
        id: 'fractions-whole-step-5',
        lessonId: 'fractions-whole',
        order: 5,
        type: LessonStepType.explanation,
        title: 'Luego, cuenta las partes seleccionadas',
        body:
            'Ahora Sofia toma 1 porcion. El numerador es el numero de arriba. Indica cuantas partes iguales estamos describiendo. Sofia tiene 1 de las 4 porciones iguales, asi que su parte es 1/4. Si Sofia y Mateo juntan sus porciones, tendrian 2 de las 4 partes iguales, o 2/4 de la pizza.',
      ),
      LessonStep(
        id: 'fractions-whole-step-6',
        lessonId: 'fractions-whole',
        order: 6,
        type: LessonStepType.question,
        title: 'Pausa y explicalo',
        body:
            'Antes de seguir, imagina que se lo explicas a un companero que tambien falto. Usa las palabras entero, partes iguales, numerador y denominador si puedes.',
        prompt:
            'Que fraccion de la pizza recibio Sofia? Explica que significan el 1 y el 4.',
        expectedAnswer:
            'Sofia recibio 1/4 de la pizza. El 1 significa una porcion igual y el 4 significa que la pizza entera fue dividida en cuatro partes iguales.',
      ),
      LessonStep(
        id: 'fractions-whole-step-7',
        lessonId: 'fractions-whole',
        order: 7,
        type: LessonStepType.practice,
        title: 'Practica guiada: compartir pastel',
        body:
            'Probemos otro ejemplo. Un pastel de cumpleanos es el entero. El pastel se corta en 8 piezas iguales. Mateo toma 3 piezas para su mesa. Primero identifica el entero: un pastel. Luego cuenta las partes iguales del entero: 8 piezas. Ese es el denominador. Despues cuenta cuantas partes tiene Mateo: 3 piezas. Ese es el numerador. Mateo tiene 3/8 del pastel.',
        prompt: 'Escribe la fraccion de la parte de Mateo.',
        expectedAnswer:
            'Mateo tiene 3/8 del pastel porque tiene 3 de las 8 piezas iguales.',
      ),
      LessonStep(
        id: 'fractions-whole-step-8',
        lessonId: 'fractions-whole',
        order: 8,
        type: LessonStepType.imagePlaceholder,
        title: 'Modelo visual: tres octavos de pastel',
        body:
            'Imagen futura generada: un pastel rectangular dividido en ocho piezas iguales, con tres piezas sombreadas.',
        imageDescription:
            'Un pastel rectangular cortado en 8 rectangulos iguales. Tres rectangulos estan sombreados y etiquetados como 3/8.',
      ),
      LessonStep(
        id: 'fractions-whole-step-9',
        lessonId: 'fractions-whole',
        order: 9,
        type: LessonStepType.practice,
        title: 'Practica independiente: crea una parte justa',
        body:
            'Ahora intenta tu. Dibuja un objeto entero que se pueda compartir, como un sandwich, brownies, un pastel o un jardin. Dividelo en partes iguales. Sombrea algunas partes. Luego escribe la fraccion que representa la parte sombreada.',
        prompt:
            'Crea tu propio modelo de fraccion y etiqueta numerador, denominador y entero.',
      ),
      LessonStep(
        id: 'fractions-whole-step-10',
        lessonId: 'fractions-whole',
        order: 10,
        type: LessonStepType.summary,
        title: 'Lo que debes recordar',
        body:
            'Una fraccion describe parte de un entero cuando el entero se divide en partes iguales. El denominador nombra cuantas partes iguales forman el entero. El numerador nombra cuantas de esas partes estamos describiendo. Cuando te atores, vuelve a tres preguntas: cual es el entero? Cuantas partes iguales lo forman? Cuantas partes estan seleccionadas?',
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
    language: 'es',
    title: 'Comparar fracciones',
    bigIdea: 'Las fracciones se pueden comparar razonando sobre su tamano.',
    essentialQuestion: 'Como sabemos que fraccion es mayor?',
    learningObjective: LearningObjective(
      id: 'lo-comparing-fractions',
      statement:
          'Comparar dos fracciones usando modelos visuales y sentido numerico.',
    ),
    lessonContent:
        'Cuando las fracciones se refieren al mismo entero, podemos compararlas con modelos, denominadores comunes o puntos de referencia.',
    guidedPractice:
        'Compara 1/4 y 3/4 usando una barra de fracciones. Explica por que una es mayor.',
    independentPractice:
        'Compara 2/3 y 2/6. Dibuja un modelo o explica tu razonamiento.',
    summary:
        'Comparar fracciones requiere revisar el entero y razonar sobre numerador y denominador.',
    steps: [
      LessonStep(
        id: 'comparing-fractions-step-1',
        lessonId: 'comparing-fractions',
        order: 1,
        type: LessonStepType.story,
        title: 'Dos mesas, dos pizzas',
        body:
            'Dos mesas reciben pizzas del mismo tamano. Una mesa come 1/4 y otra come 3/4. Como los enteros son iguales y las pizzas tienen el mismo numero de partes, podemos comparar los numeradores.',
      ),
      LessonStep(
        id: 'comparing-fractions-step-2',
        lessonId: 'comparing-fractions',
        order: 2,
        type: LessonStepType.summary,
        title: 'Idea clave',
        body:
            'Cuando los denominadores son iguales y los enteros son iguales, la fraccion con mayor numerador es mayor.',
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
    language: 'es',
    title: 'Fracciones equivalentes',
    bigIdea: 'Diferentes fracciones pueden nombrar la misma cantidad.',
    essentialQuestion: 'Como pueden dos fracciones diferentes ser iguales?',
    learningObjective: LearningObjective(
      id: 'lo-equivalent-fractions',
      statement: 'Reconocer y generar fracciones equivalentes.',
    ),
    lessonContent: 'Las fracciones equivalentes representan el mismo valor.',
    guidedPractice: 'Usa un modelo para mostrar por que 1/2 y 2/4 son iguales.',
    independentPractice:
        'Escribe dos fracciones equivalentes a 3/6 y explica como lo sabes.',
    summary:
        'Las fracciones equivalentes pueden verse diferentes, pero representan la misma parte de un entero.',
    steps: [
      LessonStep(
        id: 'equivalent-fractions-step-1',
        lessonId: 'equivalent-fractions',
        order: 1,
        type: LessonStepType.story,
        title: 'Compartir la misma cantidad',
        body:
            'Un pastel se corta primero en 2 partes iguales. Se guarda una mitad. Luego esa misma mitad se corta en 2 partes iguales mas pequenas. La cantidad guardada puede describirse como 1/2 o 2/4.',
      ),
      LessonStep(
        id: 'equivalent-fractions-step-2',
        lessonId: 'equivalent-fractions',
        order: 2,
        type: LessonStepType.summary,
        title: 'Idea clave',
        body:
            'Las fracciones equivalentes usan numeradores y denominadores diferentes para nombrar el mismo valor.',
      ),
    ],
  ),
];
