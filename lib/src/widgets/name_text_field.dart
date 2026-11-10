import 'package:material_ui/material_ui.dart';

/// A text field for naming something.
///
/// It owns its [TextEditingController], so callers only supply the starting
/// text and listen for changes. [initialValue] is read once: to show a
/// different item's name, give the field a new [key] (for example
/// `ValueKey(item.id)`) so it starts over with fresh text.
///
/// Validation is the caller's job. Pass the message to show in [errorText],
/// or null when the value is fine.
class NameTextField extends StatefulWidget {
  const NameTextField({
    super.key,
    required this.initialValue,
    required this.labelText,
    required this.onChanged,
    this.hintText,
    this.errorText,
  });

  final String initialValue;
  final String labelText;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  State<NameTextField> createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.edit_outlined),
      ),
    );
  }
}
