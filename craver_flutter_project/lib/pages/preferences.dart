import 'package:Craver/support/control_values_and_color.dart';
import 'package:flutter/material.dart';
import '../support/settings.dart' as settings;

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  double optionInset = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Preferences'),
        ),
        body: Column(
          children: [
            ExpansionTile(
              title: const Text('Control panel color scheme'),
              children: [
                ListView.builder(
                  // Let the ListView know how many items it needs to build.
                  controller: ScrollController(),
                  itemCount: settings.ColorSchemes.values.length,
                  shrinkWrap: true,
                  // Provide a builder function. This is where the magic happens.
                  // Convert each item into a widget based on the type of item it is.
                  itemBuilder: (context, index) {
                    settings.ColorSchemes value =
                        settings.ColorSchemes.values[index];
                    settings.ColorSchemes currentlySelected =
                        settings.COLORSETTING;
                    bool checked = currentlySelected == value;
                    return CheckboxListTile(
                      value: checked,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(value.name),
                          ColorPreview(getColorScheme(value)),
                        ],
                      ),
                      contentPadding: EdgeInsets.only(left: optionInset),
                      onChanged: (v) {
                        if (v!) {
                          settings.COLORSETTING = value;
                          ControlValues.loadColorScheme();
                          setState(() {});
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Theme'),
              children: [
                CheckboxListTile(
                  value: Brightness.dark == settings.theme.value,
                  title: const Text('Dark'),
                  contentPadding: EdgeInsets.only(left: optionInset),
                  onChanged: (v) {
                    if (v!) {
                      settings.theme.value = Brightness.dark;
                      setState(() {});
                    }
                  },
                ),
                CheckboxListTile(
                  value: Brightness.light == settings.theme.value,
                  title: const Text('Light'),
                  contentPadding: EdgeInsets.only(left: optionInset),
                  onChanged: (v) {
                    if (v!) {
                      settings.theme.value = Brightness.light;
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
