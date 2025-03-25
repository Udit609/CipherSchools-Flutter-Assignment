import 'package:cipher_schools_assignment/constants/color_consts.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final bool? isObscure;
  final bool? autoFocus;
  final bool? isLast;
  final bool isEnabled;
  final TextEditingController controller;
  final TextCapitalization? textCapitalization;
  final void Function(String)? onChanged;
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.isObscure = false,
    this.autoFocus = false,
    this.isLast = false,
    this.isEnabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _myFocusNode;
  final ValueNotifier<bool> _myFocusNotifier = ValueNotifier<bool>(false);

  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    _myFocusNode = FocusNode();
    _myFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _myFocusNode.removeListener(_onFocusChange);
    _myFocusNode.dispose();
    _myFocusNotifier.dispose();

    super.dispose();
  }

  void _onFocusChange() {
    _myFocusNotifier.value = _myFocusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    Color focusColor = kFocusColor;
    Color fillColor = Colors.white;

    return ValueListenableBuilder(
      valueListenable: _myFocusNotifier,
      builder: (context, isFocus, child) {
        return TextField(
          controller: widget.controller,
          autofocus: widget.autoFocus!,
          obscureText: widget.isObscure! ? !showPassword : false,
          enableSuggestions: !widget.isObscure!,
          autocorrect: false,
          enabled: widget.isEnabled,
          focusNode: _myFocusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.isLast! ? TextInputAction.done : TextInputAction.next,
          textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
          decoration: InputDecoration(
            filled: true,
            fillColor: isFocus
                ? focusColor
                : widget.isEnabled
                    ? fillColor
                    : kGrey.withValues(alpha: 0.3),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: kGrey,
            ),
            enabled: widget.isEnabled,
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kGrey.withValues(alpha: 0.7), width: 2.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kGrey.withValues(alpha: 0.5), width: 1.0),
              borderRadius: BorderRadius.circular(12.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor, width: 1.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            suffixIcon: widget.isObscure! && widget.isEnabled == true
                ? InkWell(
                    onTap: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    child: showPassword
                        ? Icon(
                            Icons.visibility_off_outlined,
                            color: isFocus ? kDark : kGrey,
                          )
                        : Icon(
                            Icons.visibility_outlined,
                            color: isFocus ? kDark : kGrey,
                          ),
                  )
                : const SizedBox.shrink(),
          ),
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: kDark,
          ),
          onChanged: widget.onChanged,
        );
      },
    );
  }
}
