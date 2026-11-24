import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/features/settings/controllers/settings_controller.dart';
import 'package:my_reviewer/src/features/settings/ui/ai_model_selector_section.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';
import 'package:my_reviewer/src/shared/models/task.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = t.settings.main;
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(s.title)),
      body: SettingsList(
        sections: [
          AiModelSelectorSection(taskKind: TaskKind.download),
          SettingsSection(
            tiles: [
              SettingsTile.switchTile(
                leading: const Icon(Icons.wifi_outlined),
                title: Text(s.downloads.fields.wifiOnly.label),
                description: Text(s.downloads.fields.wifiOnly.description),
                initialValue: settingsController.wifiOnly,
                onToggle: settingsController.setWifiOnly,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
