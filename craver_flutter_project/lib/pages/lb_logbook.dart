//http://10.128.97.87:8080/Shift/elog.rdf

import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../support/data_getter.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../support/alert.dart';
import 'package:google_fonts/google_fonts.dart';

extension on String {
  // Splits a list into one part of the length given,
  // and the remainder in the other
  List<String> splitByLength(int length) =>
      [substring(0, length), substring(length)];
}

extension on String {
  // Splits the string into a list of equal lengths except
  // the last which is leftover
  // OPTIMIZATION: rewrite to avoid add
  List<String> splitIntoLengths(int length) {
    List<String> result = [];
    String leftOver = this;
    while (leftOver.length > length) {
      var AB = leftOver.splitByLength(length);
      result.add(AB[0]);
      leftOver = AB[1];
    }
    return result;
  }
}

String cleanUpText(String text) {
  // Ahh... So there are non-break-spaces here...
  // This has caused quite some headackes.
  return text.replaceAll('\u{00A0}', ' ');
}

class HTMLDisplay extends StatelessWidget {
  //This is NOT a general XML viewer, only for this specific use case.
  HTMLDisplay({Key? key, required this.data}) : super(key: key);
  var data;

  @override
  Widget build(BuildContext context) {
    var texts = data[0];
    var authors = data[1];
    var dates = data[2];

    GoogleFonts.config.allowRuntimeFetching = false;

    return ListView.builder(
      controller: ScrollController(),
      itemCount: texts.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        String author = authors[index];
        String text = cleanUpText(texts[index]);

        String dateString = dates[index];

        // TODO: ENSURE THAT TIMEZONE IS HANDELED
        var dateFormat = DateFormat('dd-MMM-yyyy HH:mm');
        var date = dateFormat.parse(dateString);
        var age = DateTime.now().subtract(DateTime.now().difference(date));
        var ageString = timeago.format(age);

        // Here we can choose to grey out some less important messages
        // based on the author
        var automatedMessages = [
          //'Comments',
          'From Database',
          //'New State',
          //'Run Control',
        ];
        bool important = !automatedMessages.contains(author);

        // https://github.com/flutter/flutter/issues/53797
        // Tap gesture AND selectable text
        return Card(
          child: ListTile(
            title: SelectableText.rich(TextSpan(
                text: text,
                style: GoogleFonts.sourceCodePro(),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    var url = Uri.parse(
                        "https://lblogbook.cern.ch/Shift/page${LbLogbook.currentPage}");
                    var urllaunchable = await canLaunchUrl(url);
                    if (urllaunchable) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      showOkayDialog('Error', 'Unable to open browser!');
                    }
                  })),
            isThreeLine: true,
            enabled: important,
            subtitle:
                SelectableText('\nAuthor: $author\n$dateString - $ageString'),
          ),
        );
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

  Timer? timer;

  @override
  void initState() {
    data = _getData(LbLogbook.currentPage.value);
    super.initState();
    // This updates the ages of the posts: 5 minutes ago -> 6 minutes ago
    // set update data to false if you want to optimize battery
    // (Don't know how much it matters)
    timer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) => refresh(updateData: true));
  }

  Future refresh({updateData = true}) async {
    if (updateData) {
      data = _getData(LbLogbook.currentPage.value);
    }
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
    if (rawData == null) {
      return null;
    }
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
      // These numbers, 1 and 4, are just found from
      // looking at the raw data of the responce from lblogbook
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
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: data,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.data == null) {
                      return Column(children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: refresh,
                            child: const Text('Refresh'),
                          ),
                        )
                      ]);
                    }
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
