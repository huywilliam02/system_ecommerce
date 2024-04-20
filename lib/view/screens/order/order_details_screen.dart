import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/body/notification_body.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/conversation_model.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/order_details_model.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/util/app_constants.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/images.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/widget/camera_button_sheet.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/widget/cancellation_dialogue.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/widget/collect_money_delivery_sheet.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/widget/order_item_widget.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/widget/verify_delivery_sheet.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/widget/info_card.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/order/widget/slider_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  const OrderDetailsScreen({Key? key, required this.orderId, required this.isRunningOrder, required this.orderIndex, this.fromNotification = false}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {
  Timer? _timer;

  void _startApiCalling(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(widget.orderId!);
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>().pickPrescriptionImage(isRemove: true, isCamera: false);
    await Get.find<OrderController>().getOrderWithId(widget.orderId);
    Get.find<OrderController>().getOrderDetails(widget.orderId, Get.find<OrderController>().orderModel!.orderType == 'parcel');
    if(Get.find<OrderController>().showDeliveryImageField){
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startApiCalling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    bool? cancelPermission = Get.find<SplashController>().configModel!.canceledByDeliveryman;
    bool selfDelivery = Get.find<AuthController>().profileModel!.type != 'zone_wise';

    return WillPopScope(
      onWillPop: () async{
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return true;
        } else {
          Get.back();
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBar(title: 'order_details'.tr, onBackPressed: (){
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        }),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: GetBuilder<OrderController>(builder: (orderController) {

              OrderModel? controllerOrderModel = orderController.orderModel;

              bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';

              bool? parcel, processing, accepted, confirmed, handover, pickedUp, cod, wallet, partialPay, offlinePay;

              late bool showBottomView;
              late bool showSlider;
              bool showDeliveryConfirmImage = false;

              double? deliveryCharge = 0;
              double itemsPrice = 0;
              double? discount = 0;
              double? couponDiscount = 0;
              double? tax = 0;
              double addOns = 0;
              double? dmTips = 0;
              double additionalCharge = 0;
              bool? isPrescriptionOrder = false;
              bool? taxIncluded = false;
              OrderModel? order = controllerOrderModel;
              if(order != null && orderController.orderDetailsModel != null) {
                deliveryCharge = order.deliveryCharge;
                dmTips = order.dmTips;
                isPrescriptionOrder = order.prescriptionOrder;
                discount = order.storeDiscountAmount! + order.flashAdminDiscountAmount! + order.flashStoreDiscountAmount!;
                tax = order.totalTaxAmount;
                taxIncluded = order.taxStatus;
                additionalCharge = order.additionalCharge!;
                couponDiscount = order.couponDiscountAmount;
                if(isPrescriptionOrder!){
                  double orderAmount = order.orderAmount ?? 0;
                  itemsPrice = (orderAmount + discount) - ((taxIncluded! ? 0 : tax!) + deliveryCharge!) - dmTips!;
                }else {
                  for (OrderDetailsModel orderDetails in orderController.orderDetailsModel!) {
                    for (AddOn addOn in orderDetails.addOns!) {
                      addOns = addOns + (addOn.price! * addOn.quantity!);
                    }
                    itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
                  }
                }
              }
              double subTotal = itemsPrice + addOns;
              double total = itemsPrice + addOns - discount+ (taxIncluded! ? 0 : tax!) + deliveryCharge! - couponDiscount! + dmTips! + additionalCharge;

              if(controllerOrderModel != null){
                parcel = controllerOrderModel.orderType == 'parcel';
                processing = controllerOrderModel.orderStatus == AppConstants.processing;
                accepted = controllerOrderModel.orderStatus == AppConstants.accepted;
                confirmed = controllerOrderModel.orderStatus == AppConstants.confirmed;
                handover = controllerOrderModel.orderStatus == AppConstants.handover;
                pickedUp = controllerOrderModel.orderStatus == AppConstants.pickedUp;
                cod = controllerOrderModel.paymentMethod == 'cash_on_delivery';
                wallet = controllerOrderModel.paymentMethod == 'wallet';
                partialPay = controllerOrderModel.paymentMethod == 'partial_payment';
                offlinePay = controllerOrderModel.paymentMethod == 'offline_payment';

                showDeliveryConfirmImage = pickedUp && Get.find<SplashController>().configModel!.dmPictureUploadStatus!;
                bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';
                showBottomView = (parcel && accepted) || accepted || confirmed || processing || handover
                    || pickedUp || (widget.isRunningOrder ?? true);
                showSlider = (cod && accepted && !restConfModel && !selfDelivery) || handover || pickedUp
                    || (parcel && accepted);
              }

              return (orderController.orderDetailsModel != null && controllerOrderModel != null) ? Column(children: [

                Expanded(child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(children: [

                    Row(children: [
                      Text('${parcel! ? 'delivery_id'.tr : 'order_id'.tr}:', style: robotoRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(controllerOrderModel.id.toString(), style: robotoMedium),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      const Expanded(child: SizedBox()),
                      Container(height: 7, width: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        controllerOrderModel.orderStatus!.tr,
                        style: robotoRegular,
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Row(children: [
                      Text('${parcel ? 'charge_payer'.tr : 'item'.tr}:', style: robotoRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        parcel ? controllerOrderModel.chargePayer!.tr : orderController.orderDetailsModel!.length.toString(),
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const Expanded(child: SizedBox()),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          cod! ? 'cod'.tr : wallet! ? 'wallet'.tr : partialPay! ? 'partially_pay'.tr : offlinePay! ? 'offline_payment'.tr : 'digitally_paid'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ]),

                    orderController.orderDetailsModel!.isNotEmpty && orderController.orderDetailsModel![0].itemDetails != null && orderController.orderDetailsModel![0].itemDetails!.moduleType == 'food'
                    ? Column(children: [
                      const Divider(height: Dimensions.paddingSizeLarge),

                      Row(children: [
                        Text('${'cutlery'.tr}: ', style: robotoRegular),
                        const Expanded(child: SizedBox()),

                        Text(
                          controllerOrderModel.cutlery! ? 'yes'.tr : 'no'.tr,
                          style: robotoRegular,
                        ),
                      ]),
                    ]) : const SizedBox(),

                    controllerOrderModel.unavailableItemNote != null ? Column(
                      children: [
                        const Divider(height: Dimensions.paddingSizeLarge),

                        Row(children: [
                          Text('${'unavailable_item_note'.tr}: ', style: robotoMedium),

                          Text(
                            controllerOrderModel.unavailableItemNote!,
                            style: robotoRegular,
                          ),
                        ]),
                      ],
                    ) : const SizedBox(),

                    controllerOrderModel.deliveryInstruction != null ? Column(children: [
                      const Divider(height: Dimensions.paddingSizeLarge),

                      Row(children: [
                        Text('${'delivery_instruction'.tr}: ', style: robotoMedium),

                        Text(
                          controllerOrderModel.deliveryInstruction!,
                          style: robotoRegular,
                        ),
                      ]),
                    ]) : const SizedBox(),
                    SizedBox(height: controllerOrderModel.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

                    const Divider(height: Dimensions.paddingSizeLarge),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    InfoCard(
                      title: parcel ? 'sender_details'.tr : 'store_details'.tr,
                      address: parcel ? controllerOrderModel.deliveryAddress : DeliveryAddress(address: controllerOrderModel.storeAddress),
                      image: parcel ? '' : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${controllerOrderModel.storeLogo}',
                      name: parcel ? controllerOrderModel.deliveryAddress!.contactPersonName : controllerOrderModel.storeName,
                      phone: parcel ? controllerOrderModel.deliveryAddress!.contactPersonNumber : controllerOrderModel.storePhone,
                      latitude: parcel ? controllerOrderModel.deliveryAddress!.latitude : controllerOrderModel.storeLat,
                      longitude: parcel ? controllerOrderModel.deliveryAddress!.longitude : controllerOrderModel.storeLng,
                      showButton: (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                          && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded'),
                      isStore: true,
                      messageOnTap: () => Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: NotificationBody(
                          orderId: controllerOrderModel.id, vendorId: controllerOrderModel.storeId,
                        ),
                        user: User(
                          id: controllerOrderModel.storeId, fName: controllerOrderModel.storeName,
                          image: controllerOrderModel.storeLogo,
                        ),
                      )),
                      order: order!,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    InfoCard(
                      title: parcel ? 'receiver_details'.tr : 'customer_contact_details'.tr,
                      address: parcel ? controllerOrderModel.receiverDetails : controllerOrderModel.deliveryAddress,
                      image: parcel ? '' : controllerOrderModel.customer != null ? '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${controllerOrderModel.customer!.image}' : '',
                      name: parcel ? controllerOrderModel.receiverDetails!.contactPersonName : controllerOrderModel.deliveryAddress!.contactPersonName,
                      phone: parcel ? controllerOrderModel.receiverDetails!.contactPersonNumber : controllerOrderModel.deliveryAddress!.contactPersonNumber,
                      latitude: parcel ? controllerOrderModel.receiverDetails!.latitude : controllerOrderModel.deliveryAddress!.latitude,
                      longitude: parcel ? controllerOrderModel.receiverDetails!.longitude : controllerOrderModel.deliveryAddress!.longitude,
                      showButton: controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                          && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded',
                      isStore: parcel ? false : true,
                      messageOnTap: () => Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: NotificationBody(
                          orderId: controllerOrderModel.id, customerId: controllerOrderModel.customer!.id,
                        ),
                        user: User(
                          id: controllerOrderModel.customer!.id, fName: controllerOrderModel.customer!.fName,
                          lName: controllerOrderModel.customer!.lName, image: controllerOrderModel.customer!.image,
                        ),
                      )),
                      order: order,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    parcel ? Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 200]!, spreadRadius: 1, blurRadius: 5)],
                      ),
                      child: controllerOrderModel.parcelCategory != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('parcel_category'.tr, style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Row(children: [
                          ClipOval(child: CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${controllerOrderModel.parcelCategory!.image}',
                            height: 35, width: 35, fit: BoxFit.cover,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              controllerOrderModel.parcelCategory!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            Text(
                              controllerOrderModel.parcelCategory!.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                          ])),
                        ]),
                      ]) : SizedBox(
                        width: context.width,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('parcel_category'.tr, style: robotoRegular),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text('no_parcel_category_data_found'.tr, style: robotoMedium),
                        ]),
                      ),
                    ) : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderController.orderDetailsModel!.length,
                      itemBuilder: (context, index) {
                        return OrderItemWidget(order: controllerOrderModel, orderDetails: orderController.orderDetailsModel![index]);
                      },
                    ),

                    (controllerOrderModel.orderNote  != null && controllerOrderModel.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('additional_note'.tr, style: robotoRegular),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Container(
                        width: 1170,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                        ),
                        child: Text(
                          controllerOrderModel.orderNote!,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      (Get.find<SplashController>().getModule(controllerOrderModel.moduleType).orderAttachment!
                      && controllerOrderModel.orderAttachment != null && controllerOrderModel.orderAttachment!.isNotEmpty)
                      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('prescription'.tr, style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Center(child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${controllerOrderModel.orderAttachment}',
                            width: 200,
                          ),
                        )),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                      ]) : const SizedBox(),

                    ]) : const SizedBox(),

                    (controllerOrderModel.orderStatus == 'delivered' && controllerOrderModel.orderProof != null
                    && controllerOrderModel.orderProof!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('order_proof'.tr, style: robotoRegular),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.5,
                            crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 5,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controllerOrderModel.orderProof!.length,
                          itemBuilder: (BuildContext context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => openDialog(context, '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${controllerOrderModel.orderProof![index]}'),
                                child: Center(child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  child: CustomImage(
                                    image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${controllerOrderModel.orderProof![index]}',
                                    width: 100, height: 100,
                                  ),
                                )),
                              ),
                            );
                          }),

                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ]) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    !parcel ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('item_price'.tr, style: robotoRegular),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        // order.prescriptionOrder ? IconButton(
                        //   constraints: const BoxConstraints(maxHeight: 36),
                        //   onPressed: () =>  Get.dialog(AmountInputDialogue(orderId: widget.orderId, isItemPrice: true, amount: itemsPrice), barrierDismissible: true),
                        //   icon: const Icon(Icons.edit, size: 16),
                        // ) : const SizedBox(),
                        Text(PriceConverter.convertPrice(itemsPrice), style: robotoRegular),
                      ]),
                    ]) : const SizedBox(),
                    SizedBox(height: !parcel ? 10 : 0),

                    Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('addons'.tr, style: robotoRegular),
                        Text('(+) ${PriceConverter.convertPrice(addOns)}', style: robotoRegular),
                      ],
                    ) : const SizedBox(),

                    Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Divider(
                      thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5),
                    ) : const SizedBox(),

                    Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${'subtotal'.tr} ${taxIncluded ? '(${'tax_included'.tr})' : ''}', style: robotoMedium),
                        Text(PriceConverter.convertPrice(subTotal), style: robotoMedium),
                      ],
                    ) : const SizedBox(),
                    SizedBox(height: Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? 10 : 0),

                    !parcel ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('discount'.tr, style: robotoRegular),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        // order.prescriptionOrder! ? IconButton(
                        //   constraints: const BoxConstraints(maxHeight: 36),
                        //   onPressed: () => Get.dialog(AmountInputDialogue(orderId: widget.orderId, isItemPrice: false, amount: discount), barrierDismissible: true),
                        //   icon: const Icon(Icons.edit, size: 16),
                        // ) : const SizedBox(),
                        Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular),
                      ]),
                    ]) : const SizedBox(),
                    SizedBox(height: !parcel ? 10 : 0),

                    couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('coupon_discount'.tr, style: robotoRegular),
                      Text(
                        '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                        style: robotoRegular,
                      ),
                    ]) : const SizedBox(),
                    SizedBox(height: couponDiscount > 0 ? 10 : 0),

                    !taxIncluded && !parcel ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('vat_tax'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(tax)}', style: robotoRegular),
                    ]) : const SizedBox(),
                    SizedBox(height: taxIncluded ? 0 : 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('delivery_man_tips'.tr, style: robotoRegular),
                        Text('(+) ${PriceConverter.convertPrice(dmTips)}', style: robotoRegular),
                      ],
                    ),
                    const SizedBox(height: 10),

                    (order.additionalCharge != null && order.additionalCharge! > 0) ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(Get.find<SplashController>().configModel!.additionalChargeName!, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(order.additionalCharge)}', style: robotoRegular, textDirection: TextDirection.ltr),
                    ]) : const SizedBox(),
                    (order.additionalCharge != null && order.additionalCharge! > 0) ? const SizedBox(height: 10) : const SizedBox(),

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('delivery_fee'.tr, style: robotoRegular),
                      Text('(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular),
                    ]),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                    ),

                    partialPay! ? DottedBorder(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [8, 5],
                      padding: const EdgeInsets.all(0),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(Dimensions.radiusDefault),
                      child: Ink(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        color: !restConfModel ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
                        child: Column(children: [

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('total_amount'.tr, style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                            )),
                            Text(
                              PriceConverter.convertPrice(total),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                          ]),
                          const SizedBox(height: 10),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('paid_by_wallet'.tr, style: !restConfModel ? robotoMedium : robotoRegular),
                            Text(
                              PriceConverter.convertPrice(order.payments![0].amount),
                              style: !restConfModel ? robotoMedium : robotoRegular,
                            ),
                          ]),
                          const SizedBox(height: 10),

                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments![1].paymentMethod?.tr})', style: !restConfModel ? robotoMedium : robotoRegular),
                            Text(
                              PriceConverter.convertPrice(order.payments![1].amount),
                              style: !restConfModel ? robotoMedium : robotoRegular,
                            ),
                          ]),
                        ]),
                      ),
                    ) : const SizedBox(),
                    SizedBox(height: partialPay ? 20 : 0),

                    !partialPay ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('total_amount'.tr, style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                      )),
                      Text(
                        PriceConverter.convertPrice(total),
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                      ),
                    ]) : const SizedBox(),

                  ]),
                )),

                showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('completed_after_delivery_picture'.tr, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: orderController.pickedPrescriptions.length+1,
                        itemBuilder: (context, index) {
                          XFile? file = index == orderController.pickedPrescriptions.length ? null : orderController.pickedPrescriptions[index];
                          if(index < 5 && index == orderController.pickedPrescriptions.length) {
                            return InkWell(
                              onTap: () {
                                Get.bottomSheet(const CameraButtonSheet());
                              },
                              child: Container(
                                height: 60, width: 60, alignment: Alignment.center, decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                                child:  Icon(Icons.camera_alt_sharp, color: Theme.of(context).primaryColor, size: 32),
                              ),
                            );
                          }
                          return file != null ? Container(
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                child: GetPlatform.isWeb ? Image.network(
                                  file.path, width: 60, height: 60, fit: BoxFit.cover,
                                ) : Image.file(
                                  File(file.path), width: 60, height: 60, fit: BoxFit.cover,
                                ),
                              ),
                              // Positioned(
                              //   right: 0, top: 0,
                              //   child: InkWell(
                              //     onTap: () => orderController.removePrescriptionImage(index),
                              //     child: const Padding(
                              //       padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                              //       child: Icon(Icons.delete_forever, color: Colors.red),
                              //     ),
                              //   ),
                              // ),
                            ]),
                          ) : const SizedBox();
                        },
                      ),
                    ),
                  ]),
                ) : const SizedBox(),

                showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? CustomButton(
                  buttonText: 'complete_delivery'.tr,
                  onPressed: () {
                    print('==jjjj=== : ${Get.find<SplashController>().configModel!.orderDeliveryVerification!}');
                    if(Get.find<SplashController>().configModel!.orderDeliveryVerification!){
                      orderController.sendDeliveredNotification(controllerOrderModel.id);

                      Get.bottomSheet(VerifyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: partialPay! ? controllerOrderModel.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: cod! || (partialPay && controllerOrderModel.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true).then((isSuccess) {

                        if(isSuccess && (cod! || (partialPay! && controllerOrderModel.payments![1].paymentMethod == 'cash_on_delivery'))){
                          Get.bottomSheet(CollectMoneyDeliverySheet(
                            currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: partialPay! ? controllerOrderModel.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: cod || (partialPay && controllerOrderModel.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true, isDismissible: false);
                        }
                      });
                    } else{
                      Get.bottomSheet(CollectMoneyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: partialPay! ? controllerOrderModel.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: cod! || (partialPay && controllerOrderModel.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true);
                    }

                  },
                ) : showBottomView ? ((accepted! && !parcel && (!cod || restConfModel || selfDelivery))
                 || processing! || confirmed!) ? Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    processing! ? 'order_is_preparing'.tr : 'order_waiting_for_process'.tr,
                    style: robotoMedium,
                  ),
                ) : showSlider ? ((cod && accepted && !restConfModel && cancelPermission! && !selfDelivery)
                || (parcel && accepted && cancelPermission!)) ? Row(children: [

                  Expanded(child: TextButton(
                    onPressed: () {
                      orderController.setOrderCancelReason('');
                      Get.dialog(CancellationDialogue(orderId: widget.orderId));
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(1170, 40), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!),
                      ),
                    ),
                    child: Text('cancel'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize: Dimensions.fontSizeLarge,
                    )),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: CustomButton(
                    buttonText: 'confirm'.tr, height: 40,
                    onPressed: () {
                      Get.dialog(ConfirmationDialog(
                        icon: Images.warning, title: 'are_you_sure_to_confirm'.tr,
                        description: parcel! ? 'you_want_to_confirm_this_delivery'.tr : 'you_want_to_confirm_this_order'.tr,
                        onYesPressed: () {
                          if((Get.find<SplashController>().configModel!.orderDeliveryVerification! || cod!) && !parcel!) {
                            orderController.updateOrderStatus(
                              controllerOrderModel, parcel ? AppConstants.handover : AppConstants.confirmed, back: true,
                            );
                          }
                          else if(parcel! && cod! && controllerOrderModel.chargePayer != 'sender') {
                            if(Get.find<SplashController>().configModel!.orderDeliveryVerification!) {
                              Get.bottomSheet(VerifyDeliverySheet(
                                currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                                orderAmount: controllerOrderModel.orderAmount, cod: cod,
                              ), isScrollControlled: true);
                            } else {
                              orderController.updateOrderStatus(controllerOrderModel, AppConstants.delivered);
                            }
                          }
                          else if(parcel && controllerOrderModel.chargePayer == 'sender' && cod!) {
                            if(Get.find<SplashController>().configModel!.orderDeliveryVerification!) {
                              Get.bottomSheet(VerifyDeliverySheet(
                                currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                                orderAmount: controllerOrderModel.orderAmount, cod: cod, isSenderPay: true, isParcel: parcel,
                              ), isScrollControlled: true);
                            } else {
                              orderController.updateOrderStatus(controllerOrderModel, AppConstants.pickedUp);
                            }
                          }
                        },
                      ), barrierDismissible: false);
                    },
                  )),

                ]) : SliderButton(
                  action: () {

                    if((cod! && accepted! && !restConfModel && !selfDelivery) || (parcel! && accepted!)) {

                      if(orderController.isLoading) {
                        orderController.initLoading();
                      }
                      Get.dialog(ConfirmationDialog(
                        icon: Images.warning, title: 'are_you_sure_to_confirm'.tr,
                        description: parcel! ? 'you_want_to_confirm_this_delivery'.tr : 'you_want_to_confirm_this_order'.tr,
                        onYesPressed: () {
                          orderController.updateOrderStatus(
                            controllerOrderModel, parcel! ? AppConstants.handover : AppConstants.confirmed, back: true,
                          );
                        },
                      ), barrierDismissible: false);
                    }

                  else if(pickedUp!) {
                    if(parcel && cod && controllerOrderModel.chargePayer != 'sender') {
                      Get.bottomSheet(VerifyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: controllerOrderModel.orderAmount, cod: cod,
                      ), isScrollControlled: true);
                    }
                    else if((Get.find<SplashController>().configModel!.orderDeliveryVerification! || cod) && !parcel){
                      Get.bottomSheet(VerifyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: controllerOrderModel.orderAmount, cod: cod,
                      ), isScrollControlled: true);
                    }
                    else if(!cod && parcel && controllerOrderModel.chargePayer == 'sender'){
                      Get.bottomSheet(VerifyDeliverySheet(
                        currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: controllerOrderModel.orderAmount, cod: cod,
                      ), isScrollControlled: true);
                    }
                    else {
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel, AppConstants.delivered);
                    }
                  }

                  else if(parcel && controllerOrderModel.chargePayer == 'sender' && cod){
                    Get.bottomSheet(VerifyDeliverySheet(
                      currentOrderModel: controllerOrderModel, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                      orderAmount: controllerOrderModel.orderAmount, cod: cod, isSenderPay: true, isParcel: parcel,
                    ), isScrollControlled: true);
                  }

                  else if(handover!) {
                    if(Get.find<AuthController>().profileModel!.active == 1) {
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel, AppConstants.pickedUp);
                    }else {
                      showCustomSnackBar('make_yourself_online_first'.tr);
                    }
                  }

                  },
                  label: Text(
                    (parcel && accepted) ? 'swipe_to_confirm_delivery'.tr
                        : (cod && accepted && !restConfModel && !selfDelivery) ? 'swipe_to_confirm_order'.tr
                        : pickedUp! ? parcel ? 'swipe_to_deliver_parcel'.tr
                        : 'swipe_to_deliver_order'.tr : handover! ? parcel ? 'swipe_to_pick_up_parcel'.tr
                        : 'swipe_to_pick_up_order'.tr : '',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                  ),
                  dismissThresholds: 0.5, dismissible: false, shimmer: true,
                  width: 1170, height: 60, buttonSize: 50, radius: 10,
                  icon: Center(child: Icon(
                    Get.find<LocalizationController>().isLtr ? Icons.double_arrow_sharp : Icons.keyboard_arrow_left,
                    color: Colors.white, size: 20.0,
                  )),
                  isLtr: Get.find<LocalizationController>().isLtr,
                  boxShadow: const BoxShadow(blurRadius: 0),
                  buttonColor: Theme.of(context).primaryColor,
                  backgroundColor: const Color(0xffF4F7FC),
                  baseColor: Theme.of(context).primaryColor,
                ) : const SizedBox() : const SizedBox(),

              ]) : const Center(child: CircularProgressIndicator());
            }),
          ),
        ),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.cancel, color: Colors.red),
          )),

        ]),
      );
    },
  );
}
