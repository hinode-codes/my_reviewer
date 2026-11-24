import 'package:material_ui/material_ui.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    required this.closeLabel,
  });

  final String title;
  final String message;
  final String closeLabel;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required String closeLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          InfoDialog(title: title, message: message, closeLabel: closeLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(closeLabel),
        ),
      ],
    );
  }
}
