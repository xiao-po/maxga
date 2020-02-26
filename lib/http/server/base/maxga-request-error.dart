import 'maxga-server-response-status.dart';

class MaxgaRequestError extends Error {
  final MaxgaServerResponseStatus status;
  final String message;

  MaxgaRequestError(this.status, [String message]): this.message = message ?? MaxgaServerResponseCodeMessageMap[status];

}

