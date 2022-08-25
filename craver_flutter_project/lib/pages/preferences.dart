import '../support/control_values_and_color.dart';
import 'package:flutter/material.dart';
import '../support/settings.dart' as settings;
import 'package:shared_preferences/shared_preferences.dart';

void setPreference(String key, var value) async {
  assert([String, int].contains(value.runtimeType));
  // Check that the key is a commonly used one and not misspelled
  assert(settings.settingKeys.contains(key));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  switch (value.runtimeType) {
    case int:
      await prefs.setInt(key, value);
      break;
    case String:
      await prefs.setString(key, value);
      break;
    default:
  }
}

void loadPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  settings.controlColors =
      settings.ColorSchemes.values[prefs.getInt('controlColors') ?? 0];
  settings.theme.value = (prefs.getInt('theme') ?? 0) == Brightness.dark.index
      ? Brightness.dark
      : Brightness.light;
}

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
                        settings.controlColors;
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
                      onChanged: (v) async {
                        if (v!) {
                          settings.controlColors = value;
                          setPreference('controlColors', value.index);
                          setState(() {});
                          ControlValues.loadColorScheme();
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
                  onChanged: (v) async {
                    if (v!) {
                      settings.theme.value = Brightness.dark;
                      setPreference('theme', Brightness.dark.index);
                      setState(() {});
                    }
                  },
                ),
                CheckboxListTile(
                  value: Brightness.light == settings.theme.value,
                  title: const Text('Light'),
                  contentPadding: EdgeInsets.only(left: optionInset),
                  onChanged: (v) async {
                    if (v!) {
                      settings.theme.value = Brightness.light;
                      setPreference('theme', Brightness.light.index);
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
