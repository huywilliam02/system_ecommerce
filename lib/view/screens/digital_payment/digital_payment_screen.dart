import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
class DigitalPaymentScreen extends StatefulWidget {
  const DigitalPaymentScreen({Key? key}) : super(key: key);

  @override
  State<DigitalPaymentScreen> createState() => _DigitalPaymentScreenState();
}

class _DigitalPaymentScreenState extends State<DigitalPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: 'payment'.tr, backButton: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0.0 : Dimensions.paddingSizeLarge),
        child: FooterView(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: GridView.builder(
              key: UniqueKey(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 50,
                mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.45,
                crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
              ),
              physics:  const NeverScrollableScrollPhysics(),
              shrinkWrap:  true,
              itemCount: 5,
              padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.green,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
