import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/screens/order/widget/guest_custom_stepper.dart';
import 'package:citgroupvn_ecommerce/view/screens/order/widget/traking_map_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
class GuestTrackOrderScreen extends StatefulWidget {
  final String orderId;
  final String number;
  const GuestTrackOrderScreen({Key? key, required this.orderId, required this.number}) : super(key: key);

  @override
  State<GuestTrackOrderScreen> createState() => _GuestTrackOrderScreenState();
}

class _GuestTrackOrderScreenState extends State<GuestTrackOrderScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<OrderController>().trackOrder(widget.orderId, null, false, contactNumber: widget.number, fromGuestInput: true);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      appBar: CustomAppBar(title: 'track_order'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: Column(children: [
        Expanded(child: GetBuilder<OrderController>(builder: (orderController) {
          String? status;
          if(orderController.trackModel != null) {
            status = orderController.trackModel?.orderStatus;
          }
          OrderModel? order = orderController.trackModel;
          return SingleChildScrollView(
            physics: isDesktop ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
            child: FooterView(
              child: Container(
                margin: isDesktop ? EdgeInsets.symmetric(horizontal: (width - 1170) / 2, vertical: 50) : null,
                decoration: isDesktop ? BoxDecoration(
                  color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
                ) : null,
                child: SingleChildScrollView(
                  physics: isDesktop ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: orderController.trackModel != null ? Column(children: [
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('your_order'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),

                          Text(' #${orderController.trackModel?.id}', style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor,
                          )),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Column(children: [
                          GuestCustomStepper(
                            title: 'order_placed'.tr,
                            isComplete: status == AppConstants.pending
                                || status == AppConstants.confirmed
                                || status == AppConstants.processing
                                || status == AppConstants.pickedUp
                                || status == AppConstants.handover
                                || status == AppConstants.delivered
                                || status == AppConstants.accepted,
                            isActive: status == AppConstants.pending,
                            haveTopBar: false,
                            statusImage: Images.trackOrderPlace,
                            subTitle: DateConverter.dateTimeStringToDateTime(order!.scheduleAt!),
                          ),

                          GuestCustomStepper(
                            title: 'order_accepted'.tr,
                            isComplete: status == AppConstants.confirmed
                                || status == AppConstants.processing
                                || status == AppConstants.pickedUp
                                || status == AppConstants.handover
                                || status == AppConstants.delivered
                                || status == AppConstants.accepted,
                            isActive: status == AppConstants.confirmed || status == AppConstants.accepted,
                            statusImage: Images.trackOrderAccept,
                          ),

                          GuestCustomStepper(
                            title: 'preparing_item'.tr,
                            isComplete: status == AppConstants.processing
                                || status == AppConstants.pickedUp
                                || status == AppConstants.handover
                                ||status == AppConstants.delivered,
                            isActive: status == AppConstants.processing,
                            statusImage: Images.trackOrderPreparing,
                          ),

                          GuestCustomStepper(
                            title: 'order_is_on_the_way'.tr,
                            isComplete: status == AppConstants.handover
                                || status == AppConstants.pickedUp
                                || status == AppConstants.delivered,
                            statusImage: Images.trackOrderOnTheWay,
                            isActive: status == AppConstants.handover,
                            subTitle: 'your_delivery_man_is_coming'.tr,
                            trailing: orderController.trackModel?.deliveryMan?.phone != null ? InkWell(
                              onTap: () async {

                                if(await canLaunchUrlString('tel:${orderController.trackModel?.deliveryMan?.phone}')) {
                                  launchUrlString('tel:${orderController.trackModel?.deliveryMan?.phone}');
                                }else {
                                  showCustomSnackBar('${'can_not_launch'.tr} ${orderController.trackModel?.deliveryMan?.phone}');
                                }

                              },
                              child: const Icon(Icons.phone_in_talk),
                            ) : const SizedBox(),
                          ),

                          GuestCustomStepper(
                            title: 'order_delivered'.tr,
                            isComplete: status == AppConstants.delivered,
                            isActive: status == AppConstants.delivered,
                            statusImage: Images.trackOrderDelivered,
                            child: orderController.trackModel?.deliveryMan != null ? TrackingMapWidget(
                              track: orderController.trackModel,
                            ) : const SizedBox(),
                          ),
                        ]),
                      ]) : const Center(child: Padding(
                        padding: EdgeInsets.only(top: 200.0, bottom: 200),
                        child: CircularProgressIndicator(),
                      )),
                    ),

                    // const SizedBox(height: 50),

                    isDesktop ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraLarge),
                      child: CustomButton(
                        buttonText: 'view_details'.tr,
                        width: 300,
                        onPressed: () {
                          Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(widget.orderId), contactNumber: widget.number),);
                        },
                      ),
                    ) : const SizedBox(),

                  ]),
                ),
              ),
            ),
          );
        })),

        !isDesktop ? SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: CustomButton(
            buttonText: 'view_details'.tr,
            onPressed: () {
              Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(widget.orderId), contactNumber: widget.number),);
            },
          ),
        )) : const SizedBox(),
      ]),
    );
  }
}
