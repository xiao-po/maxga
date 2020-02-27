// ignore: non_constant_identifier_names
Future<void> AnimationDelay([Duration duration = const Duration(milliseconds: 150)]) {
    return Future.delayed(duration);
}
// ignore: non_constant_identifier_names
Future<void> LongAnimationDelay() {
    return Future.delayed(const Duration(milliseconds: 300));
}