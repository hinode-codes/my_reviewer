import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/screens/flashcards_screen.dart';

part "flashcards_router.g.dart";

@TypedGoRoute<FlashcardsRoute>(path: "/flashcards")
class FlashcardsRoute extends GoRouteData with $FlashcardsRoute {
  const FlashcardsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FlashcardsScreen();
  }
}
