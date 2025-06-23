import 'package:flutter/material.dart';

/// Custom Row widget containing a value and a description.
/// 
/// Optionally, can also have an icon.
class ValueRow extends StatelessWidget {
  final String description;
  final String value;
  final IconData? icon;
  const ValueRow({
    super.key,
    required this.description,
    required this.value,
    this.icon,
  });

  @override
  /// Builds the widget.
  /// 
  /// The widget displays [value] on the right with a [description] on the left.
  /// Optionally an [icon] can be specified before the [description].
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              if (icon != null) Icon(icon),
              Flexible(
                child: Text(description, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Flexible(child: Text(value)),
      ],
    );
  }
}
