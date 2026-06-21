sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

class Problem<T> extends Result<T> {
  const Problem(this.message);

  final String message;
}
