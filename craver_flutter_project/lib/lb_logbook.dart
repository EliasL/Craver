//http://10.128.97.87:8080/Shift/elog.rdf

import 'package:flutter/material.dart';
import 'data_getter.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class HTMLDisplay extends StatelessWidget {
  //This is NOT a general XML viewer, only for this specific use case.
  HTMLDisplay({Key? key, required this.data}) : super(key: key);
  var data;

  @override
  Widget build(BuildContext context) {
    var texts = data[0];
    var authors = data[1];
    var dates = data[2];
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      controller: ScrollController(),
      itemCount: texts.length,
      shrinkWrap: true,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        String author = authors[index];
        String text = texts[index];
        String dateString = dates[index];

        // DEPRICATED Get everything except the timezone
        // TODO: ENSURE THAT TIMEZONE IS HANDELED
        //var dateFormat = DateFormat('\nEEE, dd MMM yyyy HH:mm:ss');
        var dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
        var date = dateFormat.parse(dateString);
        var age = DateTime.now().subtract(DateTime.now().difference(date));
        var ageString = timeago.format(age);
        var automatedMessages = [
          //'Comments',
          'From Database',
          //'New State',
          //'Run Control',
        ];
        bool important = !automatedMessages.contains(author);
        return Card(
            child: ListTile(
          title: SelectableText(text),
          isThreeLine: true,
          enabled: important,
          subtitle:
              SelectableText('\nAuthor: $author\n$dateString - $ageString'),
        ));
      },
    );
  }
}

class LbLogbook extends StatefulWidget {
  const LbLogbook({Key? key}) : super(key: key);

  @override
  State<LbLogbook> createState() => _LbLogbookState();
  //In order to put a listener to update the app title
  //CRAVER: Logbook page 1, we need to use this
  static var currentPage = ValueNotifier<int>(1);
}

class _LbLogbookState extends State<LbLogbook> {
  Future? data;

  @override
  void initState() {
    data = _getData(LbLogbook.currentPage.value);
    super.initState();
  }

  Future refresh() async {
    data = _getData(LbLogbook.currentPage.value);
    setState(() {});
  }

  Future scrollUpRefresh() async {
    //Im not sure if i want to reset the
    //page number when draging down, but
    // i think so
    LbLogbook.currentPage.value = 1;
    refresh();
  }

  _getData(int page) async {
    var rawData = await getLbLogbook(page: page);
    var textElements = rawData.getElementsByClassName('summary');
    var texts = textElements
        .map((e) => parse(e.innerHtml).documentElement!.text)
        .toList();

    var otherElements = rawData.getElementsByClassName('list1');
    var other = otherElements
        .map((e) => parse(e.innerHtml).documentElement!.text)
        .toList();

    var authors = [];
    var dates = [];

    for (var i = 0; i < other.length; i += 5) {
      dates.add(other[i + 1]);
      authors.add(other[i + 4]);
    }

    return [texts, authors, dates];
  }

  updateCurrentPage(direction) {
    LbLogbook.currentPage.value +=
        direction == DismissDirection.endToStart ? 1 : -1;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: data,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return RefreshIndicator(
                        onRefresh: scrollUpRefresh,
                        child: Dismissible(
                          confirmDismiss: (direction) async {
                            return !(LbLogbook.currentPage.value == 1 &&
                                direction == DismissDirection.startToEnd);
                          },
                          onDismissed: (DismissDirection direction) {
                            updateCurrentPage(direction);
                            refresh();
                          },
                          key: ValueKey(LbLogbook.currentPage.value),
                          child: HTMLDisplay(data: snapshot.data),
                        ));

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
