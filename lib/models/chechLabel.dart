import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    this.label,
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(4),
            ),
            border: Border.all(
              width: 2,
              color: Colors.white60,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
              Checkbox(
                value: value,
                onChanged: (bool newValue) {
                  onChanged(newValue);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
