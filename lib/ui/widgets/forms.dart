import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final TextCapitalization textCap;
  final Function onFieldSubmitted;
  final TextInputType inputType;
  final TextInputAction action;
  final IconData prefixIcon;
  final Function validator;
  final Widget suffixIcon;
  final Color labelColor;
  final String labelText;
  final bool obscureText;
  final Color iconColor;
  final Color textColor;
  final FocusNode node;
  final bool enable;

  const CustomField({
    this.action = TextInputAction.next,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.controller,
    this.labelColor,
    this.suffixIcon,
    this.prefixIcon,
    this.labelText,
    this.validator,
    this.inputType,
    this.iconColor,
    this.textColor,
    this.textCap,
    this.enable,
    this.node,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enable,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: iconColor),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.white60, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(color: Colors.yellow[700], width: 1.5),
        ),
        errorStyle:
            TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.w500),
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
      ),
      onFieldSubmitted: onFieldSubmitted,
      textCapitalization: textCap,
      cursorColor: Colors.white,
      obscureText: obscureText,
      keyboardType: inputType,
      textInputAction: action,
      controller: controller,
      validator: validator,
      focusNode: node,
    );
  }
}

class MaskedTextField extends StatefulWidget {
  final TextEditingController maskedTextFieldController;
  final ValueSetter<String> onSubmitted;
  final InputDecoration inputDecoration;
  final TextInputType keyboardType;
  final String escapeCharacter;
  final TextAlign textAlign;
  final TextStyle style;
  final FocusNode node;
  final int maxLength;
  final String mask;

  const MaskedTextField({
    this.inputDecoration: const InputDecoration(),
    this.keyboardType: TextInputType.text,
    this.maskedTextFieldController,
    this.escapeCharacter: "x",
    this.maxLength: 100,
    this.onSubmitted,
    this.textAlign,
    this.style,
    this.mask,
    this.node,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MaskedTextFieldState();
}

class MaskedTextFieldState extends State<MaskedTextField> {
  @override
  Widget build(BuildContext context) {
    var lastTextSize = 0;

    return TextField(
      style: widget.style ?? Theme.of(context).textTheme.subhead,
      onSubmitted: (String text) => widget?.onSubmitted(text),
      textAlign: widget.textAlign ?? TextAlign.start,
      controller: widget.maskedTextFieldController,
      decoration: widget.inputDecoration,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      focusNode: widget.node,
      onChanged: (String text) {
        // Deleting/removing
        if (text.length < lastTextSize) {
          if (widget.mask[text.length] != widget.escapeCharacter) {
            widget.maskedTextFieldController.selection =
                TextSelection.fromPosition(TextPosition(
              offset: widget.maskedTextFieldController.text.length,
            ));
          }
        } else {
          // Typing
          if (text.length >= lastTextSize) {
            var position = text.length;

            if ((widget.mask[position - 1] != widget.escapeCharacter) &&
                (text[position - 1] != widget.mask[position - 1])) {
              widget.maskedTextFieldController.text = _buildText(text);
            }

            if (widget.mask[position] != widget.escapeCharacter)
              widget.maskedTextFieldController.text =
                  "${widget.maskedTextFieldController.text}${widget.mask[position]}";
          }
          // Android's onChange resets cursor position (cursor goes to 0)
          // so you have to check if it was reset, then put in the end
          // as iOS bugs if you simply put it in the end
          if (widget.maskedTextFieldController.selection.start <
              widget.maskedTextFieldController.text.length) {
            widget.maskedTextFieldController.selection =
                TextSelection.fromPosition(TextPosition(
              offset: widget.maskedTextFieldController.text.length,
            ));
          }
        }
        // Updating cursor position
        lastTextSize = widget.maskedTextFieldController.text.length;
      },
    );
  }

  String _buildText(String text) {
    var result = "";

    for (int i = 0; i < text.length - 1; i++) {
      result += text[i];
    }

    result += widget.mask[text.length - 1];
    result += text[text.length - 1];

    return result;
  }

  String get unmaskedText {
    final filteredMasks = widget.mask
        .splitMapJoin(widget.escapeCharacter, onMatch: (m) => "")
        .split("");
    String text = widget.maskedTextFieldController.text.trim();
    for (String character in filteredMasks) {
      text = text.replaceAll(character, "");
    }
    return text;
  }
}
