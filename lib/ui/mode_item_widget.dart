import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ModeItemWidget<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String text;
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;
  final double spacing;

  const ModeItemWidget({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.text,
    required this.textStyle,
    required this.selectedTextStyle,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: spacing),
        GestureDetector(
          onTap: () => onChanged(value),
          child: Text(
            text,
            style: value == groupValue ? selectedTextStyle : textStyle,
          ),
        ),
        SizedBox(width: spacing),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('text', text));
    properties.add(DiagnosticsProperty('textStyle', textStyle));
    properties.add(DoubleProperty('spacing', spacing));
    super.debugFillProperties(properties);
  }
}
