import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/web_page_title_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WebSupportScreen extends StatelessWidget {
  const WebSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: Stack(
        children: [
          //  WebScreenTitleWidget(title: 'help_support'.tr),
          Positioned(
            child: Column(children: [
              Expanded(flex: 1, child: Container(color: Theme.of(context).primaryColor.withOpacity(0.10))),
              Expanded(flex: 4, child: Container(color: Theme.of(context).primaryColor)),
              Expanded(flex: 7, child: Container(color: Theme.of(context).cardColor)),
            ]),
          ),

          SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  WebScreenTitleWidget(title: 'help_support'.tr),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                    child: Column(children: [
                      const SizedBox(height: 50),

                      Text('how_we_can_help_you'.tr, style: robotoBold.copyWith( fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).cardColor,
                      )),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Text('hey_let_us_know_your_problem'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor)),
                      const SizedBox(height: 50),

                      Stack(clipBehavior: Clip.none, children: [
                        Container(
                          height: size.height * 0.35,
                          width: Dimensions.webMaxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                          ),
                        ),

                        Positioned(
                          top: -20, left: 20, right: 20,
                          child: Column(
                            children: [
                              Row(children: [
                                const SizedBox(width: Dimensions.paddingSizeExtremeLarge),
                                const SizedBox(width: Dimensions.paddingSizeExtremeLarge),

                                Expanded(child: customCard(context,
                                  child: element(context,
                                      image: Images.helpPhone, title: 'call'.tr,
                                      subTitle: Get.find<SplashController>().configModel!.phone!,
                                      onTap: () async {
                                        if (await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                                          launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
                                        } else {
                                          showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
                                        }
                                      }
                                  ),
                                )),
                                const SizedBox(width: Dimensions.paddingSizeExtremeLarge),

                                Expanded(
                                  child: customCard(context,
                                      child: element(context,
                                        image: Images.helpAddress,
                                        title: 'address'.tr,
                                        subTitle: Get.find<SplashController>().configModel!.address!,
                                        onTap: () {},
                                      )
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtremeLarge),

                                Expanded(child: customCard(context,
                                  child: element(context,
                                    image: Images.helpEmail, title: 'email_us'.tr,
                                    subTitle: Get.find<SplashController>().configModel!.email!,
                                    onTap: () {
                                      final Uri emailLaunchUri = Uri(scheme: 'mailto',
                                        path: Get.find<SplashController>().configModel!.email,
                                      );
                                      launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
                                    },
                                  ),
                                )),

                                const SizedBox(width: Dimensions.paddingSizeExtremeLarge),
                                const SizedBox(width: Dimensions.paddingSizeExtremeLarge),

                              ])
                            ],
                          ),
                        )

                      ])
                    ]),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
      /*body: Scrollbar(child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Image.asset(Images.supportImage, height: 120),
          const SizedBox(height: 30),

          Image.asset(Images.logo, width: 100),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Image.asset(Images.logoName, width: 100),
          *//*Text(AppConstants.APP_NAME, style: robotoBold.copyWith(
            fontSize: 20, color: Theme.of(context).primaryColor,
          )),*//*
          const SizedBox(height: 30),

          SupportButton(
            icon: Icons.location_on, title: 'address'.tr, color: Colors.blue,
            info: Get.find<SplashController>().configModel!.address,
            onTap: () {},
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SupportButton(
            icon: Icons.call, title: 'call'.tr, color: Colors.red,
            info: Get.find<SplashController>().configModel!.phone,
            onTap: () async {
              if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
              }else {
                showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
              }
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SupportButton(
            icon: Icons.mail_outline, title: 'email_us'.tr, color: Colors.green,
            info: Get.find<SplashController>().configModel!.email,
            onTap: () {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: Get.find<SplashController>().configModel!.email,
              );
              launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
            },
          ),

        ]))),
      )),*/


  Widget customCard(BuildContext context, {required Widget child}){
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor,
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).primaryColor.withOpacity(0.5),
              Theme.of(context).primaryColor,
            ],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          )
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: child,
      ),
    );
  }

  Widget element(BuildContext context,{required String image, required String title, required String subTitle, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(image, height: 70, width: 70, fit: BoxFit.cover),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        Text(
          subTitle,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        ),
      ]),
    );
  }

