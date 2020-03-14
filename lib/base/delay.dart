// ignore: non_constant_identifier_names
Future<bool> AnimationDelay([Duration duration = const Duration(milliseconds: 150)]) {
    return Future.delayed(duration).then((v) => true);
}
// ignore: non_constant_identifier_names
Future<bool> LongAnimationDelay() {
    return Future.delayed(const Duration(milliseconds: 300));
}