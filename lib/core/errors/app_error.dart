class AppError implements Exception {
  AppError({required this.message, this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() {
    return 'AppError(message: $message, code: $code, statusCode: $statusCode)';
  }
}
