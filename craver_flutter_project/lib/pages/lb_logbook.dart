//http://10.128.97.87:8080/Shift/elog.rdf

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../support/data_getter.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../support/alert.dart';
import 'package:google_fonts/google_fonts.dart';
import '../support/settings.dart' as settings;

String cleanUpText(String text) {
  // Ahh... So there are non-break-spaces here...
  // This has caused quite some headackes.
  return text.replaceAll('\u{00A0}', ' ');
}

class LbReader extends StatefulWidget {
  final List data;
  static ScrollController scrollController = ScrollController();
  // This is used to either preserve scroll possition
  // or to reset it. Update the value to reset, or use the same
  // value to preserve the scroll state.
  const LbReader(this.data, {Key? key}) : super(key: key);

  @override
  State<LbReader> createState() => _LbReaderState();
}

class _LbReaderState extends State<LbReader> {
  @override
  Widget build(BuildContext context) {
    var texts = widget.data[0];
    var authors = widget.data[1];
    var dates = widget.data[2];

    GoogleFonts.config.allowRuntimeFetching = false;

    return ListView.builder(
      controller: LbReader.scrollController,
      itemCount: texts.length,
      //shrinkWrap: true,
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

  static ValueNotifier<List<List<String?>>?> data = ValueNotifier(null);

  static Timer? timer;

  static int _currentPage = 1;
  static int get currentPage => _currentPage;
  static set currentPage(int page) {
    settings.title.value = '${settings.defaultTitle}: Logbook - page $page';
    _currentPage = page;
  }

  static void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(minutes: 1),
        (Timer t) => refresh(updateData: true, keepScroll: true));
  }

  static void stopTimer() {
    timer?.cancel();
  }

  static void refresh({updateData = true, keepScroll = false}) async {
    if (updateData) {
      data.value = await _getData(LbLogbook.currentPage);
    }
    if (keepScroll && LbReader.scrollController.hasClients) {
      double offset = LbReader.scrollController.offset;
      LbReader.scrollController = ScrollController(initialScrollOffset: offset);
    } else {
      LbReader.scrollController = ScrollController();
    }

    // Reset automatic timer
    startTimer();
  }

  static Future<List<List<String?>>?> _getData(int page) async {
    var rawData = await getLbLogbook(page: page);
    if (rawData == null) {
      return null;
    }
    var textElements = rawData.getElementsByClassName('summary');
    List<String> texts = textElements
        .map((e) => parse(e.innerHtml).documentElement!.text)
        .toList();

    var otherElements = rawData.getElementsByClassName('list1');
    var other = otherElements
        .map((e) => parse(e.innerHtml).documentElement!.text)
        .toList();

    List<String> authors = [];
    List<String> dates = [];

    for (var i = 0; i < other.length; i += 5) {
      // These numbers, 1 and 4, are just found from
      // looking at the raw data of the responce from lblogbook
      dates.add(other[i + 1]);
      authors.add(other[i + 4]);
    }
    if (texts.isEmpty) {
      showOkayDontShowAgainDialog(
          'No Logbook Text!',
          'This should not happen. Please contact ${settings.SUPPORT_EMAIL}',
          'No logbook text');
    }

    return [texts, authors, dates];
  }

  static void updateTitle() {
    currentPage = currentPage;
  }

  @override
  State<LbLogbook> createState() => _LbLogbookState();
}

class _LbLogbookState extends State<LbLogbook> {
  Future scrollUpRefresh() async {
    //Im not sure if i want to reset the
    //page number when draging down, but
    // i think so
    LbLogbook.currentPage = 1;
    LbLogbook.refresh();
  }

  updateCurrentPage(direction) {
    LbLogbook.currentPage += direction == DismissDirection.endToStart ? 1 : -1;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: LbLogbook.data,
              builder: (BuildContext context, var _, Widget? child) {
                switch (LbLogbook.data.value) {
                  case null:
                    return Column(children: const [
                      Flexible(
                        child: ElevatedButton(
                          onPressed: LbLogbook.refresh,
                          child: Text('Refresh'),
                        ),
                      )
                    ]);
                  default:
                    return RefreshIndicator(
                        onRefresh: scrollUpRefresh,
                        child: Dismissible(
                          confirmDismiss: (direction) async {
                            return !(LbLogbook.currentPage == 1 &&
                                direction == DismissDirection.startToEnd);
                          },
                          onDismissed: (DismissDirection direction) {
                            updateCurrentPage(direction);
                            LbLogbook.refresh();
                          },
                          key: ValueKey(LbLogbook.currentPage),
                          //This is the actual log book list
                          child: LbReader(LbLogbook.data.value!),
                        ));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
