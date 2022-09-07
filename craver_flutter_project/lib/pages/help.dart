import '../support/control_values_and_color.dart';
import 'package:flutter/material.dart';
import '../support/settings.dart' as settings;

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text('Help'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 5),
            Card(
              child: ExpansionTile(
                title: const Text('How to log out'),
                children: [
                  ListTile(
                    title: const SelectableText(
                        'In the main app view, press this button in the top left corner of the screen to go to the preferences:'),
                    trailing: Image.asset('assets/icon/craver_logo_icon.png'),
                  ),
                  ListTile(
                    title:
                        const SelectableText('Then press the log out button:'),
                    trailing: ElevatedButton(
                        onPressed: () {}, child: const Text('Log out')),
                  ),
                ],
              ),
            ),
            Card(
              child: ExpansionTile(
                title: const Text('Customization'),
                children: [
                  ListTile(
                    title: const SelectableText(
                        'In the main app view, press this button in the top left corner of the screen to go to the preferences:'),
                    trailing: Image.asset('assets/icon/craver_logo_icon.png'),
                  ),
                  ListTile(
                    title: const SelectableText(
                        'You can then select one of two color schemes for the control panel, and choose between a light and dark theme for the app.'),
                    trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ColorPreview(
                              getColorScheme(settings.ColorSchemes.ECS)),
                          ColorPreview(
                              getColorScheme(settings.ColorSchemes.Craver)),
                        ]),
                  ),
                ],
              ),
            ),
            const Card(
              child: ExpansionTile(
                title: Text('Suggestions'),
                children: [
                  ListTile(
                    title: SelectableText(
                        'If you have any suggestions for features, they can be sent to:'),
                  ),
                  ListTile(
                    title: SelectableText(
                      settings.SUPPORT_EMAIL,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    title: SelectableText(
                        'Especially take a look at the details tab of the control panel. If you know of information that you think would be useful to have here, send a suggestion!'),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
