import 'package:flutter/material.dart';

class SingleTapEvent extends StatelessWidget {
  final Widget child;
  final Function() onTap;

  bool singleTap = false;

  SingleTapEvent(
      {Key? key, required this.child, required this.onTap, singleTap = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (!singleTap) {
            Function.apply(onTap, []);
            singleTap = true;
            Future.delayed(const Duration(seconds: 3)).then((value) {
              singleTap = false;
            });
          }
        },
        child: child);
  }
}

class SingleTapEventElevatedButton extends StatefulWidget {
  final Widget child;
  final Function() onPressed;
  final ButtonStyle style;
  final Widget? loader;

  const SingleTapEventElevatedButton(
      {Key? key,
      required this.child,
      required this.onPressed,
      singleTap = false,
      required this.style,
      this.loader})
      : super(key: key);

  @override
  State<SingleTapEventElevatedButton> createState() =>
      _SingleTapEventElevatedButtonState();
}

class _SingleTapEventElevatedButtonState
    extends State<SingleTapEventElevatedButton> {
  bool singleTap = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: widget.style,
        onPressed: (!singleTap && mounted)
            ? () {
                Function.apply(widget.onPressed, []);
                print("en el delay esta $singleTap");

                setState(() {
                  singleTap = true;
                });

                Future.delayed(const Duration(seconds: 10)).then((value) {
                  if (!mounted) return;

                  setState(() {
                    singleTap = false;
                  });
                  print("en el delay esta $singleTap");
                });
              }
            : null,
        child: (!singleTap) ? widget.child : widget.loader ?? widget.child);
  }
}