import 'MaxgaServerResponseStatus.dart';

class MaxgaRequestError extends Error {
  final MaxgaServerResponseStatus status;
  final String message;

  MaxgaRequestError(this.status, this.message);

}

