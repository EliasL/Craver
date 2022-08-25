import '../support/control_values_and_color.dart';
import 'package:flutter/material.dart';
import 'package:gauges/gauges.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

class RadialGaugeWithNumbers extends StatefulWidget {
  /// A guage with numbers on the side, and a centeral
  /// value in the middle.
  ///
  /// Sorry about the mess...
  /// I hope you don't have to try to understand the angles
  /// It's a bit of a pile of junk
  ///
  final List<ControlValue> gaugeValues;
  final ValueNotifier updateData;
  final List<MaterialColor> colors;
  final double radius;
  final double minValue;
  final double maxValue;
  final bool useExp;
  final String descreption;
  final List<String> units;
  const RadialGaugeWithNumbers({
    Key? key,
    required this.gaugeValues,
    required this.updateData,
    required this.radius,
    required this.minValue,
    required this.maxValue,
    required this.useExp,
    required this.colors,
    this.descreption = '',
    this.units = const ['Hz'],
  })  : assert(gaugeValues.length <= colors.length),
        assert(gaugeValues.length == units.length),
        super(key: key);

  @override
  State<RadialGaugeWithNumbers> createState() => _RadialGaugeWithNumbersState();
}

class _RadialGaugeWithNumbersState extends State<RadialGaugeWithNumbers> {
  RadialGaugePointer fancyPointer(
      MaterialColor color, double value, double minValue, double maxValue) {
    final double radius = widget.radius;

    List<Color> color2Colors(MaterialColor color) {
      return [
        Color(color[300]!.value),
        Color(color[300]!.value),
        Color(color[600]!.value),
        Color(color[600]!.value)
      ];
    }

    return RadialNeedlePointer(
      minValue: minValue,
      maxValue: maxValue,
      value: value,
      thicknessStart: 20,
      thicknessEnd: 0,
      color: Colors.red,
      length: radius,
      knobRadiusAbsolute: 10,
      gradient: LinearGradient(
        colors: color2Colors(color),
        stops: const [0, 0.5, 0.5, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static String toSuper(int i) {
    // Converts number to superscript: -45 -> ⁻⁴⁵
    const String superScript = '⁰¹²³⁴⁵⁶⁷⁸⁹';
    if (i < 0) {
      return '⁻${toSuper(i.abs())}';
    } else if (i > 9) {
      var s = i.toString();
      return toSuper(int.parse(s[0])) + toSuper(int.parse(s.substring(1)));
    } else {
      return superScript[i];
    }
  }

  // get the text size
  static Size _textSize(String text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text),
        maxLines: 1,
        textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final List<ControlValue> gaugeValues = widget.gaugeValues;
          final List<MaterialColor> colors = widget.colors;
          final bool useExp = widget.useExp;

          final double radius = widget.radius;
          String description = widget.descreption;
          if (description != '') description += ": ";
          final List<String> units = widget.units;
          List<Widget> children = [];

          double minValue = widget.minValue;
          double maxValue = widget.maxValue;
          double rangeValue = maxValue - minValue;
          double minAngle = -150;
          double maxAngle = 150;
          double offsett = math.radians(180 - minAngle); // We need a offsett :/
          double rangeAngle = maxAngle - minAngle;
          int displayedNumberOfValues =
              max(10, (maxValue.round() + 2) * (useExp ? 1 : 0));
          int nrOfValues = displayedNumberOfValues - 1;
          double interval = rangeValue / nrOfValues;
          // Pick numbers that look nice
          int ticksInBetween =
              (8 * radius * 8 / displayedNumberOfValues).round();

          double tickLength = 0.2;
          double tickLengthSmall = 0.1;

          double numberOffsett = 0.02;

          var radialGauge = Positioned.fill(
              top: 0,
              left: 0,
              child: ValueListenableBuilder(
                  valueListenable: widget.updateData,
                  builder: (context, _, widget) {
                    double log10(num x) => log(x) / ln10;
                    return RadialGauge(
                      axes: [
                        // Main axis
                        RadialGaugeAxis(
                          minValue: minValue,
                          maxValue: maxValue,
                          minAngle: minAngle,
                          maxAngle: maxAngle,
                          radius: radius,
                          width: tickLength,
                          color: Colors.transparent,
                          ticks: [
                            RadialTicks(
                                interval: interval,
                                alignment: RadialTickAxisAlignment.inside,
                                color: Colors.blue,
                                length: tickLength,
                                children: [
                                  RadialTicks(
                                    ticksInBetween: ticksInBetween,
                                    length: tickLengthSmall,
                                    color: Colors.grey[500]!,
                                  ),
                                ])
                          ],
                          pointers: List<RadialGaugePointer>.generate(
                              gaugeValues.length,
                              (i) => fancyPointer(
                                    colors[i],
                                    useExp
                                        ? log10(gaugeValues[i].numValue)
                                        : gaugeValues[i].numValue,
                                    minValue,
                                    maxValue,
                                  )),
                        ),
                      ],
                    );
                  }));

          children.add(radialGauge);

          // Now we add the numbers...

          var width = constraints.maxWidth;
          var height = constraints.maxHeight;
          var widthR = width / 2;
          var heightR = height / 2;

          // We're not going to cover the whole circle, only the parts between
          // min and max angle
          var radiansToCover = math.radians(rangeAngle);
          var smallFormat = NumberFormat('##.#');
          var compactFormat = NumberFormat.compact(); //NumberFormat('####');

          //Create text values
          var textSize = _textSize('value');
          double textx = textSize.width;
          double texty = textSize.height;

          for (var i = 0; i <= nrOfValues; i++) {
            String value;
            if (useExp) {
              value = "10${toSuper(i - 1)}";
            } else {
              double number = minValue + i * rangeValue / nrOfValues;
              if (number.abs() < 100) {
                value = smallFormat.format(number);
              } else {
                value = compactFormat.format(number);
              }
            }

            //Update text values
            textSize = _textSize(value);
            textx = textSize.width;
            texty = textSize.height;

            var theta = -i * radiansToCover / nrOfValues + offsett;
            children.add(
              Positioned(
                top: heightR + //Center of guage
                    cos(theta) *
                        widthR *
                        (radius +
                            tickLength +
                            numberOffsett) + //outside of ticks
                    texty / 2 * (-1 + cos(theta)), //Center text
                left: widthR + //Center of guage
                    sin(theta) *
                        widthR *
                        (radius +
                            tickLength +
                            numberOffsett) + //outside of ticks
                    textx / 2 * (-1 + sin(theta)), //Center text
                child: Text(
                  value,
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ),
            );
          }

          var minTheta = math.radians(-minAngle) + pi;
          var maxTheta = math.radians(-maxAngle) + pi;
          var R = radius + tickLengthSmall / 2;
          // Find the size of the box we can fit between the gaues
          // Assume that it is symetric around the 0 degree axis.
          // The length of the box is then

          var A = widthR + //Center of guage
              sin(minTheta) * widthR * R;
          var B = widthR + //Center of guage
              sin(maxTheta) * widthR * R;
          var lengthOfBox = B - A;

          // Finally we'll add the number at the bottom to show the real value numerically
          children.add(Positioned(
              top: heightR + //Center of guage
                  cos(minTheta) * widthR * R,
              left: widthR + //Center of guage
                  sin(minTheta) * widthR * R,
              child: SizedBox(
                  width: lengthOfBox,
                  child: ValueListenableBuilder(
                      valueListenable: widget.updateData,
                      builder: (context, _, widget) {
                        return SizedBox(
                            width: lengthOfBox,
                            child: RichText(
                              text: TextSpan(
                                children: List<TextSpan>.generate(
                                    gaugeValues.length,
                                    (i) => TextSpan(
                                        text:
                                            '$description${compactFormat.format(gaugeValues[i].numValue)}${units[i]}\n',
                                        style: TextStyle(
                                            color:
                                                Color(colors[i][600]!.value)))),
                              ),
                              textAlign: ui.TextAlign.center,
                            ));
                      }))));

          return Stack(
            clipBehavior: ui.Clip.none,
            alignment: Alignment.center,
            children: children,
          );
        },
      ),
    );
  }
}
