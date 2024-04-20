import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';

class WebScreenTitleWidget extends StatelessWidget {
  final String title;
  const WebScreenTitleWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? Container(
      height: 64,
      color: Theme.of(context).primaryColor.withOpacity(0.10),
      child: Center(child: Text(title, style: robotoMedium)),
    ) : const SizedBox();
  }
}
