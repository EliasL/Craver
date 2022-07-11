import 'package:flutter/material.dart';
import 'data_getter.dart';

class Instances extends StatefulWidget {
  const Instances({Key? key}) : super(key: key);

  @override
  State<Instances> createState() => _InstancesState();
}

class _InstancesState extends State<Instances> {
  Future? data;

  String dropdownValue = 'Off';

  @override
  void initState() {
    data = _getData();
    super.initState();
  }

  void refresh() async {
    data = _getData();
    setState(() {});
  }

  _getData() async {
    switch (dropdownValue) {
      case 'All':
        return await getPrometheusAllUp();
      case 'On':
        return await getPrometheusOnlyUp();
      case 'Off':
        return await getPrometheusNotUp();
      default:
        return await getPrometheusAllUp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: refresh,
                child: const Text('Refresh'),
              ),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                underline: Container(
                  height: 2,
                ),
                onChanged: (String? newValue) {
                  dropdownValue = newValue!;
                  refresh();
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
            child: FutureBuilder(
              future: data,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return InstanceColumn(
                      data: snapshot.data,
                    );

                  default:
                    return Column(children: const [
                      Flexible(child: CircularProgressIndicator())
                    ]);
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
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      controller: ScrollController(),
      itemCount: data.length,
      shrinkWrap: true,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = data[index];
        String instanceName = item['metric']['instance'];
        String value = item['value'][1];
        String date = DateTime.fromMillisecondsSinceEpoch(
                (item['value'][0] * 1000).toInt())
            .toString();
        Icon icon;

        List<String> badStrings = [
          '.lbdaq.cern.ch',
          ':9100',
          ':9090',
          'https://',
          '.cern.ch',
          'http://'
        ];

        String niceInstanceName = instanceName;
        for (String badString in badStrings) {
          niceInstanceName = niceInstanceName.replaceAll(badString, '');
        }

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
