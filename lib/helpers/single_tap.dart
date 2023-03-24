// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
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
  final Function()? onPressedLoading;
  final ButtonStyle style;
  final bool? dissapear;
  final Widget? loader;

  const SingleTapEventElevatedButton(
      {Key? key,
      required this.child,
      required this.onPressed,
      singleTap = false,
      required this.style,
      this.loader,
      this.onPressedLoading,
      this.dissapear})
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
    return (widget.dissapear == true && !((!singleTap && mounted)))
        ? const SizedBox()
        : ElevatedButton(
            style: widget.style,
            onPressed: (!singleTap && mounted)
                ? () {
                    Function.apply(widget.onPressed, []);
                    if (kDebugMode) {
                      print("en el delay esta $singleTap");
                    }

                    setState(() {
                      singleTap = true;
                    });

                    Future.delayed(const Duration(seconds: 10)).then((value) {
                      if (!mounted) return;

                      setState(() {
                        singleTap = false;
                      });
                      if (kDebugMode) {
                        print("en el delay esta $singleTap");
                      }
                    });
                  }
                : widget.onPressedLoading,
            child: (!singleTap) ? widget.child : widget.loader ?? widget.child);
  }
}
