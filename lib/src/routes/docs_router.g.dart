// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'docs_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$docsRoute];

RouteBase get $docsRoute => GoRouteData.$route(
  path: '/docs',
  hasOverriddenOnExit: false,
  factory: $DocsRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'scan',
      hasOverriddenOnExit: false,
      factory: $DocsScanRoute._fromState,
    ),
    GoRouteData.$route(
      path: ':docId',
      hasOverriddenOnExit: false,
      factory: $DocsDetailRoute._fromState,
    ),
  ],
);

mixin $DocsRoute on GoRouteData {
  static DocsRoute _fromState(GoRouterState state) => const DocsRoute();

  @override
  String get location => GoRouteData.$location('/docs');

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

mixin $DocsScanRoute on GoRouteData {
  static DocsScanRoute _fromState(GoRouterState state) => const DocsScanRoute();

  @override
  String get location => GoRouteData.$location('/docs/scan');

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

mixin $DocsDetailRoute on GoRouteData {
  static DocsDetailRoute _fromState(GoRouterState state) => DocsDetailRoute(
    docId: state.pathParameters['docId']!,
    docName: state.uri.queryParameters['doc-name']!,
  );

  DocsDetailRoute get _self => this as DocsDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/docs/${Uri.encodeComponent(_self.docId)}',
    queryParams: {'doc-name': _self.docName},
  );

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
