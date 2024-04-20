import 'package:flutter/foundation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/html_type.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/base/web_page_title_widget.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({Key? key, required this.htmlType}) : super(key: key);

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<SplashController>().getHtmlText(widget.htmlType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: widget.htmlType == HtmlType.termsAndCondition
              ? 'terms_conditions'.tr
              : widget.htmlType == HtmlType.aboutUs
                  ? 'about_us'.tr
                  : widget.htmlType == HtmlType.privacyPolicy
                      ? 'privacy_policy'.tr
                      : widget.htmlType == HtmlType.shippingPolicy
                          ? 'shipping_policy'.tr
                          : widget.htmlType == HtmlType.refund
                              ? 'refund_policy'.tr
                              : widget.htmlType == HtmlType.cancellation
                                  ? 'cancellation_policy'.tr
                                  : 'no_data_found'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: splashController.htmlText != null
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      WebScreenTitleWidget(
                          title: widget.htmlType == HtmlType.termsAndCondition
                              ? 'terms_conditions'.tr
                              : widget.htmlType == HtmlType.aboutUs
                                  ? 'about_us'.tr
                                  : widget.htmlType == HtmlType.privacyPolicy
                                      ? 'privacy_policy'.tr
                                      : widget.htmlType ==
                                              HtmlType.shippingPolicy
                                          ? 'shipping_policy'.tr
                                          : widget.htmlType == HtmlType.refund
                                              ? 'refund_policy'.tr
                                              : widget.htmlType ==
                                                      HtmlType.cancellation
                                                  ? 'cancellation_policy'.tr
                                                  : 'no_data_found'.tr),
                      FooterView(
                          child: Ink(
                        width: Dimensions.webMaxWidth,
                        color: Theme.of(context).cardColor,
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // ResponsiveHelper.isDesktop(context) ? Container(
                              //   height: 50, alignment: Alignment.center, color: Theme.of(context).cardColor, width: Dimensions.webMaxWidth,
                              //   child: SelectableText(widget.htmlType == HtmlType.termsAndCondition ? 'terms_conditions'.tr
                              //       : widget.htmlType == HtmlType.aboutUs ? 'about_us'.tr : widget.htmlType == HtmlType.privacyPolicy
                              //       ? 'privacy_policy'.tr : widget.htmlType == HtmlType.shippingPolicy ? 'shipping_policy'.tr
                              //       : widget.htmlType == HtmlType.refund ? 'refund_policy'.tr :  widget.htmlType == HtmlType.cancellation
                              //       ? 'cancellation_policy'.tr : 'no_data_found'.tr,
                              //     style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                              //   ),
                              // ) : const SizedBox(),

                              (splashController.htmlText!.contains('<ol>') ||
                                      splashController.htmlText!
                                          .contains('<ul>'))
                                  ? HtmlWidget(
                                      splashController.htmlText ?? '',
                                      key: Key(widget.htmlType.toString()),
                                      isSelectable: true,
                                      onTapUrl: (String url) {
                                        return launchUrlString(url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                    )
                                  : SelectionArea(
                                      focusNode: FocusNode(),
                                      key: Key(widget.htmlType.toString()),
                                      child: Html(
                                          data: splashController.htmlText ?? '',
                                          key: Key(widget.htmlType.toString()),
                                          shrinkWrap: true,
                                          onLinkTap:
                                              (url, attributes, element) {
                                            if (url!.startsWith('www.')) {
                                              url = 'https://$url';
                                            }
                                            if (kDebugMode) {
                                              print('Redirect to url: $url');
                                            }
                                            html.window.open(url, "_blank");
                                          }),
                                    ),
                              //     SelectableHtml(
                              //   data: splashController.htmlText, shrinkWrap: true,
                              //   onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, element) {
                              //     if(url!.startsWith('www.')) {
                              //       url = 'https://$url';
                              //     }
                              //     if (kDebugMode) {
                              //       print('Redirect to url: $url');
                              //     }
                              //     html.window.open(url, "_blank");
                              //   },
                              // ),
                            ]),
                      ))
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        );
      }),
    );
  }
}
