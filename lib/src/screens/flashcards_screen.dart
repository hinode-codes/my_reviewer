import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/gen/strings.g.dart';

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.flashcards.main.title)),
      body: Center(child: Text(t.flashcards.main.title)),
    );
  }
}
