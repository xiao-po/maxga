import 'package:maxga/model/MangaSource.dart';

class MaxgaHttpError extends Error {
  final String message;
  final MangaSource source;

  MaxgaHttpError(this.message, this.source);



}
