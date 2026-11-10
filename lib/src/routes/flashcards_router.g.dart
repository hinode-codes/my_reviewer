// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcards_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$flashcardsRoute];

RouteBase get $flashcardsRoute => GoRouteData.$route(
  path: '/flashcards',
  hasOverriddenOnExit: false,
  factory: $FlashcardsRoute._fromState,
);

mixin $FlashcardsRoute on GoRouteData {
  static FlashcardsRoute _fromState(GoRouterState state) =>
      const FlashcardsRoute();

  @override
  String get location => GoRouteData.$location('/flashcards');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
