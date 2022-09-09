import 'package:flutter/material.dart';
import '../support/data_getter.dart';

class Instances extends StatefulWidget {
  const Instances({Key? key}) : super(key: key);

  static ValueNotifier<List?> data = ValueNotifier(null);

  static String dropdownValue = 'Off';

  static void refresh() async {
    data.value = await _getData();
  }

  static Future<List?> _getData() async {
    switch (dropdownValue) {
      case 'All':
        return await getPrometheus(PrometheusCommands.up);
      case 'On':
        return await getPrometheus(PrometheusCommands.onlyUp);
      case 'Off':
        return await getPrometheus(PrometheusCommands.notUp);
      default:
        return await getPrometheus(PrometheusCommands.up);
    }
  }

  @override
  State<Instances> createState() => _InstancesState();
}

class _InstancesState extends State<Instances> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const ElevatedButton(
                onPressed: Instances.refresh,
                child: Text('Refresh'),
              ),
              DropdownButton<String>(
                value: Instances.dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                underline: Container(
                  height: 2,
                ),
                onChanged: (String? newValue) {
                  Instances.dropdownValue = newValue!;
                  Instances.refresh();
                  setState(() {});
                },
                items: <String>['All', 'On', 'Off']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Instances.data,
              builder: (BuildContext context, List? value, Widget? child) {
                switch (value) {
                  case null:
                    return Column(children: const [
                      Flexible(child: CircularProgressIndicator())
                    ]);

                  default:
                    return InstanceColumn(
                      data: value,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InstanceColumn extends StatelessWidget {
  const InstanceColumn({Key? key, this.data}) : super(key: key);
  final List? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Column(children: const [
        Flexible(child: CircularProgressIndicator()),
      ]);
    }
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      controller: ScrollController(),
      itemCount: data!.length,
      shrinkWrap: true,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = data![index];
        String instanceName = item['metric']['instance'];
        String value = item['value'][1];
        String date = DateTime.fromMillisecondsSinceEpoch(
                (item['value'][0] * 1000).toInt())
            .toString();
        Icon icon;

        // We want to make some of the instance names look prettier.
        List<String> badStrings = [
          '.lbdaq.cern.ch',
          'https://',
          '.cern.ch',
          'http://'
        ];
        String niceInstanceName = instanceName;
        for (String badString in badStrings) {
          niceInstanceName = niceInstanceName.replaceAll(badString, '');
        }
        // Remove port (Assume only one ':')
        niceInstanceName = niceInstanceName.split(':')[0];

        //Choose what icon to use depending on server status
        if (value == '1') {
          icon = const Icon(Icons.cloud_rounded);
        } else {
          icon = const Icon(Icons.cloud_off);
        }

        return ExpansionTile(
          leading: icon,
          title: SelectableText(niceInstanceName),
          children: [
            ListTile(
              title: SelectableText(instanceName),
            ),
            ListTile(
              title: SelectableText('Value: ${item['value'][1]}'),
            ),
            ListTile(
              title: SelectableText('Date recorded: $date'),
            ),
          ],
        );
      },
    );
  }
}
