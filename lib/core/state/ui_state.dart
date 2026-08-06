sealed class UiState<T> {
  const UiState();
}

class InitialState<T> extends UiState<T> {
  const InitialState();
}

class LoadingState<T> extends UiState<T> {
  const LoadingState();
}

class EmptyState<T> extends UiState<T> {
  final String? message;
  const EmptyState([this.message]);
}

class SuccessState<T> extends UiState<T> {
  final T data;
  const SuccessState(this.data);
}

class ErrorState<T> extends UiState<T> {
  final String message;
  final dynamic exception;

  const ErrorState(this.message, {this.exception});
}
