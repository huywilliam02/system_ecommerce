import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
class TextFieldShadow extends StatelessWidget {
  final Widget child;
  const TextFieldShadow({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 5, offset: const Offset(0,3))],
      ),
      child: child,
    );
  }
}
