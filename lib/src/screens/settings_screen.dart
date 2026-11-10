import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

import '../gen/strings.g.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.title), actions: [
            ],
          ),
      body: SettingsSplitView(sections: [SettingsSection(tiles: [

            ]
          )]),
    );
  }
}
