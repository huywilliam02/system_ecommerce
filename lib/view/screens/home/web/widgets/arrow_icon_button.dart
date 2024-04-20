import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/on_hover.dart';

class ArrowIconButton extends StatelessWidget {
  final bool isRight;
  void Function()? onTap;
  ArrowIconButton({Key? key, this.isRight = true, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnHover(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40, width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Icon(isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios, color: Theme.of(context).disabledColor, size: 15),
        ),
      ),
    );
  }
}
