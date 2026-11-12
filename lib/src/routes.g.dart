// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$mainShellRouteData];

RouteBase get $mainShellRouteData => StatefulShellRouteData.$route(
  factory: $MainShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      observers: DocsShellBranchData.$observers,
      routes: [
        GoRouteData.$route(
          path: '/docs',
          hasOverriddenOnExit: false,
          factory: $DocsRouteData._fromState,
          routes: [
            GoRouteData.$route(
              path: 'scan',
              hasOverriddenOnExit: false,
              factory: $DocsScanPreviewRouteData._fromState,
            ),
            GoRouteData.$route(
              path: 'groups/:docId',
              hasOverriddenOnExit: false,
              factory: $DocsGroupRouteData._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'edit',
                  hasOverriddenOnExit: false,
                  factory: $DocsGroupEditRouteData._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: ':docId',
              hasOverriddenOnExit: false,
              factory: $DocsDocRouteData._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'transcription',
                  hasOverriddenOnExit: false,
                  factory: $DocsDocTranscriptionRouteData._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/learn',
          hasOverriddenOnExit: false,
          factory: $LearnRouteData._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/settings',
          hasOverriddenOnExit: false,
          factory: $SettingsRouteData._fromState,
        ),
      ],
    ),
  ],
);

extension $MainShellRouteDataExtension on MainShellRouteData {
  static MainShellRouteData _fromState(GoRouterState state) =>
      const MainShellRouteData();
}

mixin $DocsRouteData on GoRouteData {
  static DocsRouteData _fromState(GoRouterState state) =>
      DocsRouteData(query: state.uri.queryParameters['query']);

  DocsRouteData get _self => this as DocsRouteData;

  @override
  String get location => GoRouteData.$location(
    '/docs',
    queryParams: {if (_self.query != null) 'query': _self.query},
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

mixin $DocsScanPreviewRouteData on GoRouteData {
  static DocsScanPreviewRouteData _fromState(GoRouterState state) =>
      const DocsScanPreviewRouteData();

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

mixin $DocsGroupRouteData on GoRouteData {
  static DocsGroupRouteData _fromState(GoRouterState state) =>
      DocsGroupRouteData(
        docId: state.pathParameters['docId']!,
        $extra: state.extra as List<ScannedDocumentModel>?,
      );

  DocsGroupRouteData get _self => this as DocsGroupRouteData;

  @override
  String get location =>
      GoRouteData.$location('/docs/groups/${Uri.encodeComponent(_self.docId)}');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $DocsGroupEditRouteData on GoRouteData {
  static DocsGroupEditRouteData _fromState(GoRouterState state) =>
      DocsGroupEditRouteData(
        docId: state.pathParameters['docId']!,
        $extra: state.extra as ScannedDocumentGroupModel?,
      );

  DocsGroupEditRouteData get _self => this as DocsGroupEditRouteData;

  @override
  String get location => GoRouteData.$location(
    '/docs/groups/${Uri.encodeComponent(_self.docId)}/edit',
  );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

mixin $DocsDocRouteData on GoRouteData {
  static DocsDocRouteData _fromState(GoRouterState state) =>
      DocsDocRouteData(docId: state.pathParameters['docId']!);

  DocsDocRouteData get _self => this as DocsDocRouteData;

  @override
  String get location =>
      GoRouteData.$location('/docs/${Uri.encodeComponent(_self.docId)}');

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

mixin $DocsDocTranscriptionRouteData on GoRouteData {
  static DocsDocTranscriptionRouteData _fromState(GoRouterState state) =>
      DocsDocTranscriptionRouteData(docId: state.pathParameters['docId']!);

  DocsDocTranscriptionRouteData get _self =>
      this as DocsDocTranscriptionRouteData;

  @override
  String get location => GoRouteData.$location(
    '/docs/${Uri.encodeComponent(_self.docId)}/transcription',
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

mixin $LearnRouteData on GoRouteData {
  static LearnRouteData _fromState(GoRouterState state) =>
      const LearnRouteData();

  @override
  String get location => GoRouteData.$location('/learn');

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

mixin $SettingsRouteData on GoRouteData {
  static SettingsRouteData _fromState(GoRouterState state) =>
      const SettingsRouteData();

  @override
  String get location => GoRouteData.$location('/settings');

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
