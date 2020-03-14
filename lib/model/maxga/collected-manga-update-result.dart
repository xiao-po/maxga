import 'package:maxga/base/status/update-status.dart';

import 'collected-manga.dart';

class CollectedMangaUpdateResult {
  final CollectedUpdateStatus status;
  final CollectedManga manga;

  const CollectedMangaUpdateResult(this.status, this.manga);
}
