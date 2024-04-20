import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/config_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/hover/text_hover.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FooterView extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final bool visibility;
  const FooterView({Key? key, required this.child, this.minHeight = 0.65, this.visibility = true}) : super(key: key);

  @override
  State<FooterView> createState() => _FooterViewState();
}

class _FooterViewState extends State<FooterView> {
  // final TextEditingController _newsLetterController = TextEditingController();
  // final Color _color = Colors.white;
  final ConfigModel? _config = Get.find<SplashController>().configModel;

  @override
  Widget build(BuildContext context) {
    return Column( mainAxisAlignment: MainAxisAlignment.start, children: [
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: (widget.visibility && ResponsiveHelper.isDesktop(context)) ? MediaQuery.of(context).size.height * widget.minHeight : MediaQuery.of(context).size.height *0.7) ,
        child: widget.child,
      ),

      (widget.visibility && ResponsiveHelper.isDesktop(context)) ? Container(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        width: context.width,
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        child: Center(child: Column(children: [

          Container(
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeExtremeLarge),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.85),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
            ),
            width: Dimensions.webMaxWidth,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(width: Dimensions.paddingSizeExtraLarge),

              Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                Image.asset(Images.logo, width: 126, height: 40),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // SizedBox(
                //   width: 280,
                //   child: Text('Best information about the company gies here but now lorem ipsum is', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor))
                // ),
                // const SizedBox(height: Dimensions.paddingSizeSmall),

                // Text('news_letter'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                // const SizedBox(height: Dimensions.paddingSizeSmall),
                //
                Text('subscribe_to_out_new_channel_to_get_latest_updates'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                /*Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
                  ),
                  child: Row(children: [
                    const SizedBox(width: 20),
                    Expanded(child: TextField(
                      controller: _newsLetterController,
                      expands: false,
                      style: robotoMedium.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeExtraSmall),
                      decoration: InputDecoration(
                        hintText: 'your_email_address'.tr,
                        hintStyle: robotoRegular.copyWith(color: Colors.grey, fontSize: Dimensions.fontSizeExtraSmall),
                        border: InputBorder.none,
                        isCollapsed: true
                      ),
                      maxLines: 1,
                    )),
                    GetBuilder<SplashController>(builder: (splashController) {
                      return InkWell(
                        onTap: () {
                          String email = _newsLetterController.text.trim().toString();
                          if (email.isEmpty) {
                            showCustomSnackBar('enter_email_address'.tr);
                          }else if (!GetUtils.isEmail(email)) {
                            showCustomSnackBar('enter_a_valid_email_address'.tr);
                          }else{
                            Get.find<SplashController>().subscribeMail(email).then((value) {
                              if(value) {
                                _newsLetterController.clear();
                              }
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: !splashController.isLoading ? Text('subscribe'.tr, style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall))
                              : const SizedBox(height: 15, width: 20, child: CircularProgressIndicator(color: Colors.white)),
                        ),
                      );
                    }),
                  ]),
                ),*/

                GetBuilder<SplashController>(
                  builder: (splashController) {
                    return SizedBox(height: 50, child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: splashController.configModel!.socialMedia!.length,
                      itemBuilder: (context, index) {
                        String? name = splashController.configModel!.socialMedia![index].name;
                        late String icon;
                        if(name == 'facebook'){
                          icon = Images.facebook;
                        }else if(name == 'linkedin'){
                          icon = Images.linkedin;
                        } else if(name == 'youtube'){
                          icon = Images.youtube;
                        }else if(name == 'twitter'){
                          icon = Images.twitter;
                        }else if(name == 'instagram'){
                          icon = Images.instagram;
                        }else if(name == 'pinterest'){
                          icon = Images.pinterest;
                        }
                        return  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: InkWell(
                            onTap: () async {
                              String url = splashController.configModel!.socialMedia![index].link!;
                              if(!url.startsWith('https://')) {
                                url = 'https://$url';
                              }
                              url = url.replaceFirst('www.', '');
                              if(await canLaunchUrlString(url)) {
                                _launchURL(url);
                              }
                            },
                            child: Image.asset(icon, height: 30, width: 30, fit: BoxFit.contain, color: Theme.of(context).primaryColor),
                          ),
                        );
                      },
                    ));
                  }
                ),

                Row(children: [

                  _config!.landingPageLinks!.appUrlAndroidStatus == '1' ? InkWell(
                    onTap: () => _launchURL(_config!.landingPageLinks!.appUrlAndroid ?? ''),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Image.asset(Images.landingGooglePlay, height: 40, fit: BoxFit.contain),
                    ),
                  ) : const SizedBox(),
                  SizedBox(width: _config!.landingPageLinks!.appUrlAndroidStatus == '1' ? Dimensions.paddingSizeSmall : 0.0),

                  _config!.landingPageLinks!.appUrlIosStatus == '1' ? InkWell(
                    onTap: () => _launchURL(_config!.landingPageLinks!.appUrlIos ?? ''),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      child: Image.asset(Images.landingAppStore, height: 40, fit: BoxFit.contain),
                    ),
                  ) : const SizedBox(),
                ]),

              ])),

              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment : MainAxisAlignment.spaceBetween, children: [

                            /*Text('about'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),*/

                          FooterButton(title: 'become_a_store_owner'.tr, route: RouteHelper.getRestaurantRegistrationRoute()),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          FooterButton(title: 'become_a_delivery_man'.tr, route: RouteHelper.getDeliverymanRegistrationRoute()),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          FooterButton(title: 'help_support'.tr, route: RouteHelper.getSupportRoute()),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          FooterButton(title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          FooterButton(title: 'terms_and_condition'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),

                            // FooterButton(title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                            // const SizedBox(height: Dimensions.paddingSizeSmall),
                            //
                            // FooterButton(title: 'find_stores'.tr, route: RouteHelper.getAllStoreRoute('popular')),
                            // const SizedBox(height: Dimensions.paddingSizeSmall),
                            //
                            // FooterButton(title: 'categories'.tr, route: RouteHelper.getCategoryRoute()),
                            // const SizedBox(height: Dimensions.paddingSizeSmall),

                            // FooterButton(title: 'blogs'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                            // const SizedBox(height: Dimensions.paddingSizeSmall),
                          ],
                        ),

                        Column(children: [
                            /*Text('quick_links'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            _config!.refundPolicyStatus == 1 ? FooterButton(title: 'money_refund'.tr, route: RouteHelper.getHtmlRoute('refund-policy')) : const SizedBox(),
                            SizedBox(height: _config!.refundPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                            _config!.shippingPolicyStatus == 1 ? FooterButton(title: 'shipping'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')) : const SizedBox(),
                            SizedBox(height: _config!.shippingPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                              FooterButton(title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'terms_and_condition'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),*/

                          Image.asset(Images.sendUsMail, width: 50, height: 50),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text('send_us_mail'.tr, style: robotoBold),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          InkWell(
                            onTap: () async {
                              String url = 'mailto:${_config!.email ?? ''}';
                              if(await canLaunchUrlString(url)) {
                                _launchURL(url);
                              }
                            },
                            child: Text(_config!.email ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                          ),

                        ]),

                        Column(children: [
                          /*Text('quick_links'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            _config!.refundPolicyStatus == 1 ? FooterButton(title: 'money_refund'.tr, route: RouteHelper.getHtmlRoute('refund-policy')) : const SizedBox(),
                            SizedBox(height: _config!.refundPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                            _config!.shippingPolicyStatus == 1 ? FooterButton(title: 'shipping'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')) : const SizedBox(),
                            SizedBox(height: _config!.shippingPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                              FooterButton(title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'terms_and_condition'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),*/

                          Image.asset(Images.contactUs, width: 50, height: 50),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text('contact_us'.tr, style: robotoBold),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(_config!.phone ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),

                        ]),

                        Column(children: [
                          /*Text('quick_links'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            _config!.refundPolicyStatus == 1 ? FooterButton(title: 'money_refund'.tr, route: RouteHelper.getHtmlRoute('refund-policy')) : const SizedBox(),
                            SizedBox(height: _config!.refundPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                            _config!.shippingPolicyStatus == 1 ? FooterButton(title: 'shipping'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')) : const SizedBox(),
                            SizedBox(height: _config!.shippingPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                              FooterButton(title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'terms_and_condition'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),*/

                          Image.asset(Images.findUsHere, width: 50, height: 50),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text('find_us_here'.tr, style: robotoBold),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          SizedBox(
                            width: 200,
                            child: Text(
                              _config!.address ?? '',
                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                            ),
                          ),

                        ]),

                        /*Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('for_users'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            TextHover(builder: (hovered) {
                              return InkWell(
                                hoverColor: Colors.transparent,
                                onTap: () {
                                  if (Get.find<AuthController>().isLoggedIn()) {
                                    Get.toNamed(RouteHelper.getProfileRoute());
                                  }else{
                                    Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true));
                                  }
                                },
                                child: Text(Get.find<AuthController>().isLoggedIn() ? 'profile'.tr : 'login'.tr, style: hovered ? robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)
                                    : robotoRegular.copyWith(color:  Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                              );
                            }),
                            const SizedBox(height: Dimensions.paddingSizeSmall),


                            // TextHover(builder: (hovered) {
                            //   return InkWell(
                            //     hoverColor: Colors.transparent,
                            //     onTap: () {
                            //       // Get.dialog(const Center(child: SizedBox(height: 780, width : 600, child: SignUpDialog())));
                            //       // Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                            //       // Get.dialog(const Center(child: SizedBox(child: SignInScreen( exitFromApp: true, backFromThis: true))));
                            //
                            //       Get.dialog(const SignUpScreen());
                            //     },
                            //     child: Text('register'.tr, style: hovered ? robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)
                            //         : robotoRegular.copyWith(color:  Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                            //   );
                            // }),
                            // const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'my_orders'.tr, route: RouteHelper.getOrderRoute()),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'help_support'.tr, route: RouteHelper.getSupportRoute()),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                          ],
                        ),*/

                        /*Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('get_app'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            _config!.landingPageLinks!.appUrlAndroidStatus == '1' ? InkWell(
                              onTap: () => _launchURL(_config!.landingPageLinks!.appUrlAndroid ?? ''),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Image.asset(Images.landingGooglePlay, height: 40, fit: BoxFit.contain),
                              ),
                            ) : const SizedBox(),

                            _config!.landingPageLinks!.appUrlIosStatus == '1' ? InkWell(
                              onTap: () => _launchURL(_config!.landingPageLinks!.appUrlIos ?? ''),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Image.asset(Images.landingAppStore, height: 40, fit: BoxFit.contain),
                              ),
                            ) : const SizedBox(),
                          ],
                        ),*/

                      ],
                    ),
                  ),
                ),
              )

            ]),
          ),
          Divider(thickness: 0.5, color: Theme.of(context).disabledColor, indent: 0, height: 0,),

          Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth, height: 50,
                child: Center(
                  child: Text(
                    '© ${_config!.footerText ?? ''}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ),

        ])),
      ) : const SizedBox.shrink(),

    ]);
  }

  _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class FooterButton extends StatelessWidget {
  final String title;
  final String route;
  final bool url;
  const FooterButton({Key? key, required this.title, required this.route, this.url = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextHover(builder: (hovered) {
      return InkWell(
        hoverColor: Colors.transparent,
        onTap: route.isNotEmpty ? () async {
          if(url) {
            if(await canLaunchUrlString(route)) {
              launchUrlString(route, mode: LaunchMode.externalApplication);
            }
          }else {
            Get.toNamed(route);
          }
        } : null,
        child: Text(title, style: hovered ? robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)
            : robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
      );
    });
  }
}







// previous code
// Expanded(flex: 4, child: Column(children: [
//   const SizedBox(height: Dimensions.paddingSizeLarge * 2),
//
//   (_config!.landingPageLinks!.appUrlAndroidStatus == '1' || _config!.landingPageLinks!.appUrlIosStatus == '1') ? Text(
//     'download_our_apps'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeExtraLarge),
//   ) : const SizedBox(),
//   SizedBox(height: (_config!.landingPageLinks!.appUrlAndroidStatus == '1' || _config!.landingPageLinks!.appUrlIosStatus == '1')
//       ? Dimensions.paddingSizeLarge : 0),
//
//   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//     _config!.landingPageLinks!.appUrlAndroidStatus == '1' ? InkWell(
//       onTap: () => _launchURL(_config!.landingPageLinks!.appUrlAndroid ?? ''),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//         child: Image.asset(Images.landingGooglePlay, height: 40, fit: BoxFit.contain),
//       ),
//     ) : const SizedBox(),
//     _config!.landingPageLinks!.appUrlIosStatus == '1' ? InkWell(
//       onTap: () => _launchURL(_config!.landingPageLinks!.appUrlIos ?? ''),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//         child: Image.asset(Images.landingAppStore, height: 40, fit: BoxFit.contain),
//       ),
//     ) : const SizedBox(),
//   ]),
//   const SizedBox(height: Dimensions.paddingSizeLarge),
//
//   if(_config!.socialMedia!.isNotEmpty)  GetBuilder<SplashController>(builder: (splashController) {
//     return Column(children: [
//
//       Text(
//         'follow_us_on'.tr,
//         style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall),
//       ),
//       const SizedBox(height: Dimensions.paddingSizeSmall),
//
//       SizedBox(height: 50, child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         padding: EdgeInsets.zero,
//         itemCount: splashController.configModel!.socialMedia!.length,
//         itemBuilder: (context, index) {
//           String? name = splashController.configModel!.socialMedia![index].name;
//           late String icon;
//           if(name == 'facebook'){
//             icon = Images.facebook;
//           }else if(name == 'linkedin'){
//             icon = Images.linkedin;
//           } else if(name == 'youtube'){
//             icon = Images.youtube;
//           }else if(name == 'twitter'){
//             icon = Images.twitter;
//           }else if(name == 'instagram'){
//             icon = Images.instagram;
//           }else if(name == 'pinterest'){
//             icon = Images.pinterest;
//           }
//           return  Padding(
//             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
//             child: InkWell(
//               onTap: () async {
//                 String url = splashController.configModel!.socialMedia![index].link!;
//                 if(!url.startsWith('https://')) {
//                   url = 'https://$url';
//                 }
//                 url = url.replaceFirst('www.', '');
//                 if(await canLaunchUrlString(url)) {
//                   _launchURL(url);
//                 }
//               },
//               child: Image.asset(icon, height: 30, width: 30, fit: BoxFit.contain),
//             ),
//           );
//
//         },
//       )),
//
//     ]);
//   }),
// ])) ,
//
// Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//   const SizedBox(height: Dimensions.paddingSizeLarge * 2),
//
//   Text('my_account'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
//   const SizedBox(height: Dimensions.paddingSizeLarge),
//
//   FooterButton(title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'address'.tr, route: RouteHelper.getAddressRoute()),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'my_orders'.tr, route: RouteHelper.getOrderRoute()),
//
//   SizedBox(height: _config!.toggleStoreRegistration! ? Dimensions.paddingSizeSmall : 0),
//   _config!.toggleStoreRegistration! ? FooterButton(
//     title: 'become_a_seller'.tr, url: true, route: '${AppConstants.baseUrl}/store/apply',
//   ) : const SizedBox(),
//
//   SizedBox(height: _config!.toggleDmRegistration! ? Dimensions.paddingSizeSmall : 0),
//   _config!.toggleDmRegistration! ? FooterButton(
//     title: 'become_a_delivery_man'.tr, url: true, route: '${AppConstants.baseUrl}/deliveryman/apply',
//   ) : const SizedBox(),
//
// ])),
//
// Expanded(flex: 2,child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//   const SizedBox(height: Dimensions.paddingSizeLarge * 2),
//
//   Text('quick_links'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
//   const SizedBox(height: Dimensions.paddingSizeLarge),
//
//   FooterButton(title: 'contact_us'.tr, route: RouteHelper.getSupportRoute()),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'terms_and_condition'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   _config!.refundPolicyStatus == 1 ? FooterButton(title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy')) : const SizedBox(),
//   SizedBox(height: _config!.refundPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),
//
//   _config!.cancellationPolicyStatus == 1 ? FooterButton(title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')) : const SizedBox(),
//   SizedBox(height: _config!.cancellationPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),
//
//   _config!.shippingPolicyStatus == 1 ? FooterButton(title: 'shipping_policy'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')) : const SizedBox(),
//   SizedBox(height: _config!.shippingPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),
//
//   FooterButton(title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
//
// ])),