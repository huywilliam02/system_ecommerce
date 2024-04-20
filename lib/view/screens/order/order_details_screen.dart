import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:citgroupvn_ecommerce_store/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/order_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/body/notification_body.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/conversation_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/order_details_model.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce_store/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce_store/helper/price_converter.dart';
import 'package:citgroupvn_ecommerce_store/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce_store/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_store/util/app_constants.dart';
import 'package:citgroupvn_ecommerce_store/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_store/util/images.dart';
import 'package:citgroupvn_ecommerce_store/util/styles.dart';
import 'package:citgroupvn_ecommerce_store/view/base/confirmation_dialog.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_button.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_store/view/base/input_dialog.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/invoice_print_screen.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/amount_input_dialogue.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/camera_button_sheet.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/cancellation_dialogue.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/collect_money_delivery_sheet.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/dialogue_image.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/order_item_widget.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/slider_button.dart';
import 'package:citgroupvn_ecommerce_store/view/screens/order/widget/verify_delivery_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final bool isRunningOrder;
  final bool fromNotification;
  const OrderDetailsScreen({Key? key, required this.orderId, required this.isRunningOrder, this.fromNotification = false}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with WidgetsBindingObserver {
  late Timer _timer;
  bool selfDelivery = false;

  Future<void> loadData() async {

    if(Get.find<AuthController>().profileModel == null) {
      Get.find<AuthController>().getProfile();
    }
    Get.find<OrderController>().pickPrescriptionImage(isRemove: true, isCamera: false);
    await Get.find<OrderController>().getOrderDetails(widget.orderId); ///order

    Get.find<OrderController>().getOrderItemsDetails(widget.orderId); ///order details

    if(Get.find<OrderController>().showDeliveryImageField){
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }

    _startApiCalling();
  }

  void _startApiCalling() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderDetails(widget.orderId);
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    Get.find<OrderController>().clearPreviousData();
    loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startApiCalling();
    }else if(state == AppLifecycleState.paused){
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);

    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool? cancelPermission = Get.find<SplashController>().configModel!.canceledByStore;
    if(Get.find<AuthController>().profileModel != null) {
      selfDelivery = Get.find<AuthController>().profileModel!.stores![0].selfDeliverySystem == 1;
    }

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
        appBar: CustomAppBar(title: 'order_details'.tr, onTap: (){
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        }),
        body: SafeArea(
          child: GetBuilder<OrderController>(builder: (orderController) {

            OrderModel? controllerOrderModel = orderController.orderModel;

            bool restConfModel = Get.find<SplashController>().configModel!.orderConfirmationModel != 'deliveryman';
            bool showSlider = controllerOrderModel != null ? (controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away' || restConfModel || selfDelivery))
                || controllerOrderModel.orderStatus == 'confirmed' || controllerOrderModel.orderStatus == 'processing'
                || (controllerOrderModel.orderStatus == 'accepted' && controllerOrderModel.confirmed != null)
                || (controllerOrderModel.orderStatus == 'handover' && (selfDelivery || controllerOrderModel.orderType == 'take_away')) : false;
            bool showBottomView = controllerOrderModel != null ? showSlider || controllerOrderModel.orderStatus == 'picked_up' || widget.isRunningOrder : false;
            bool showDeliveryConfirmImage = orderController.showDeliveryImageField;

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
              if(order.orderType == 'delivery') {
                deliveryCharge = order.deliveryCharge;
                dmTips = order.dmTips;
                isPrescriptionOrder = order.prescriptionOrder;
              }
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

            return (orderController.orderDetailsModel != null && controllerOrderModel != null) ? Column(children: [

              Expanded(child: Scrollbar(child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Center(child: SizedBox(width: 1170, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Row(children: [
                    Text('${'order_id'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(order!.id.toString(), style: robotoMedium),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    const Expanded(child: SizedBox()),
                    const Icon(Icons.watch_later, size: 17),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(
                      DateConverter.dateTimeStringToDateTime(order.createdAt!),
                      style: robotoRegular,
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  order.scheduled == 1 ? Row(children: [
                    Text('${'scheduled_at'.tr}:', style: robotoRegular),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(DateConverter.dateTimeStringToDateTime(order.scheduleAt!), style: robotoMedium),
                  ]) : const SizedBox(),
                  SizedBox(height: order.scheduled == 1 ? Dimensions.paddingSizeSmall : 0),

                  Row(children: [
                    Text(order.orderType!.tr, style: robotoMedium),
                    const Expanded(child: SizedBox()),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Text(
                        order.paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery'.tr
                            : order.paymentMethod == 'wallet' ? 'wallet_payment'
                            : order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr
                            : 'digital_payment'.tr,
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                      ),
                    ),
                  ]),
                  const Divider(height: Dimensions.paddingSizeLarge),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: Row(children: [
                      Text('${'item'.tr}:', style: robotoRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        orderController.orderDetailsModel!.length.toString(),
                        style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const Expanded(child: SizedBox()),
                      Container(height: 7, width: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(
                        order.orderStatus == 'delivered' ? '${'delivered_at'.tr} ${order.delivered != null ? DateConverter.dateTimeStringToDateTime(order.delivered!) : ''}'
                            : order.orderStatus!.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                    ]),
                  ),

                  Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation!
                  ? Column(children: [
                    const Divider(height: Dimensions.paddingSizeLarge),

                    Row(children: [
                      Text('${'cutlery'.tr}: ', style: robotoRegular),
                      const Expanded(child: SizedBox()),

                      Text(
                        order.cutlery! ? 'yes'.tr : 'no'.tr,
                        style: robotoRegular,
                      ),
                    ]),
                  ]) : const SizedBox(),

                  order.unavailableItemNote != null ? Column(
                    children: [
                      const Divider(height: Dimensions.paddingSizeLarge),

                      Row(children: [
                        Text('${'unavailable_item_note'.tr}: ', style: robotoMedium),

                        Text(
                          order.unavailableItemNote!,
                          style: robotoRegular,
                        ),
                      ]),
                    ],
                  ) : const SizedBox(),

                  order.deliveryInstruction != null ? Column(children: [
                    const Divider(height: Dimensions.paddingSizeLarge),

                    Row(children: [
                      Text('${'delivery_instruction'.tr}: ', style: robotoMedium),

                      Text(
                        order.deliveryInstruction!,
                        style: robotoRegular,
                      ),
                    ]),
                  ]) : const SizedBox(),
                  SizedBox(height: order.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

                  const Divider(height: Dimensions.paddingSizeLarge),

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orderController.orderDetailsModel!.length,
                    itemBuilder: (context, index) {
                      return OrderItemWidget(order: order, orderDetails: orderController.orderDetailsModel![index]);
                    },
                  ),

                  (order.orderNote  != null && order.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('additional_note'.tr, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      width: 1170,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(width: 1, color: Theme.of(context).disabledColor),
                      ),
                      child: Text(
                        order.orderNote!,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]) : const SizedBox(),

                  (Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachment != null
                  && order.orderAttachment!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('prescription'.tr, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1,
                          crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 5,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.orderAttachment!.length,
                        itemBuilder: (BuildContext context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => openDialog(context, '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderAttachment![index]}'),
                              child: Center(child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: CustomImage(
                                  image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderAttachment![index]}',
                                  width: 100, height: 100,
                                ),
                              )),
                            ),
                          );
                        }),

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]) : const SizedBox(),

                  (controllerOrderModel.orderStatus == 'delivered' && order.orderProof != null
                  && order.orderProof!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                        itemCount: order.orderProof!.length,
                        itemBuilder: (BuildContext context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => openDialog(context, '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderProof![index]}'),
                              child: Center(child: ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: CustomImage(
                                  image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderProof![index]}',
                                  width: 100, height: 100,
                                ),
                              )),
                            ),
                          );
                        }),

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ]) : const SizedBox(),

                  Text('customer_details'.tr, style: robotoRegular),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  order.deliveryAddress != null ? Row(children: [
                    SizedBox(
                      height: 35, width: 35,
                      child: ClipOval(child: CustomImage(
                        image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${order.customer != null ?order.customer!.image : ''}',
                        height: 35, width: 35, fit: BoxFit.cover,
                      )),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        order.deliveryAddress!.contactPersonName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      Text(
                        order.deliveryAddress!.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),

                      Wrap(children: [
                        (order.deliveryAddress!.streetNumber != null && order.deliveryAddress!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${order.deliveryAddress!.streetNumber!}, ',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                        ) : const SizedBox(),

                        (order.deliveryAddress!.house != null && order.deliveryAddress!.house!.isNotEmpty) ? Text('${'house'.tr}: ${order.deliveryAddress!.house!}, ',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                        ) : const SizedBox(),

                        (order.deliveryAddress!.floor != null && order.deliveryAddress!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${order.deliveryAddress!.floor!}' ,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                        ) : const SizedBox(),
                      ]),

                    ])),

                    (order.orderType == 'take_away' && (order.orderStatus == 'pending' || order.orderStatus == 'confirmed' || order.orderStatus == 'processing')) ? TextButton.icon(
                      onPressed: () async {
                        String url ='https://www.google.com/maps/dir/?api=1&destination=${order.deliveryAddress!.latitude}'
                            ',${order.deliveryAddress!.longitude}&mode=d';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url, mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('unable_to_launch_google_map'.tr);
                        }
                      },
                      icon: const Icon(Icons.directions), label: Text('direction'.tr),
                    ) : const SizedBox(),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && Get.find<AuthController>().modulePermission!.chat!
                    && order.orderStatus != 'canceled' && order.orderStatus != 'refunded') ? order.isGuest! ? const SizedBox() : TextButton.icon(
                      onPressed: () async {
                        _timer.cancel();
                        await Get.toNamed(RouteHelper.getChatRoute(
                          notificationBody: NotificationBody(
                            orderId: order.id, customerId: order.customer!.id,
                          ),
                          user: User(
                            id: order.customer!.id, fName: order.customer!.fName,
                            lName: order.customer!.lName, image: order.customer!.image,
                          ),
                        ));
                        _startApiCalling();
                      },
                      icon: Icon(Icons.message, color: Theme.of(context).primaryColor, size: 20),
                      label: Text(
                        'chat'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ) : const SizedBox(),
                  ]) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  order.deliveryMan != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text('delivery_man'.tr, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(children: [

                      ClipOval(child: CustomImage(
                        image: order.deliveryMan != null ?'${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${order.deliveryMan!.image}' : '',
                        height: 35, width: 35, fit: BoxFit.cover,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                        ),
                        Text(
                          order.deliveryMan!.email!, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                      ])),

                      (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed'
                      && controllerOrderModel.orderStatus != 'canceled' && controllerOrderModel.orderStatus != 'refunded') ? TextButton.icon(
                        onPressed: () async {
                          if(await canLaunchUrlString('tel:${order.deliveryMan!.phone ?? '' }')) {
                            launchUrlString('tel:${order.deliveryMan!.phone ?? '' }', mode: LaunchMode.externalApplication);
                          }else {
                            showCustomSnackBar('${'can_not_launch'.tr} ${order.deliveryMan!.phone ?? ''}');
                          }
                        },
                        icon: Icon(Icons.call, color: Theme.of(context).primaryColor, size: 20),
                        label: Text(
                          'call'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                        ),
                      ) : const SizedBox(),

                      (controllerOrderModel.orderStatus != 'delivered' && controllerOrderModel.orderStatus != 'failed' && controllerOrderModel.orderStatus != 'canceled'
                      && controllerOrderModel.orderStatus != 'refunded' && Get.find<AuthController>().modulePermission!.chat!) ? TextButton.icon(
                        onPressed: () async {
                          _timer.cancel();
                          await Get.toNamed(RouteHelper.getChatRoute(
                            notificationBody: NotificationBody(
                              orderId: controllerOrderModel.id, deliveryManId: order.deliveryMan!.id,
                            ),
                            user: User(
                              id: controllerOrderModel.deliveryMan!.id, fName: controllerOrderModel.deliveryMan!.fName,
                              lName: controllerOrderModel.deliveryMan!.lName, image: controllerOrderModel.deliveryMan!.image,
                            ),
                          ));
                          _startApiCalling();
                        },
                        icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor, size: 20),
                        label: Text(
                          'chat'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                        ),
                      ) : const SizedBox(),

                    ]),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ]) : const SizedBox(),

                  // Total
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('item_price'.tr, style: robotoRegular),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      order.prescriptionOrder! ? IconButton(
                        constraints: const BoxConstraints(maxHeight: 36),
                        onPressed: () =>  Get.dialog(AmountInputDialogue(orderId: widget.orderId, isItemPrice: true, amount: itemsPrice), barrierDismissible: true),
                        icon: const Icon(Icons.edit, size: 16),
                      ) : const SizedBox(),
                      Text(PriceConverter.convertPrice(itemsPrice), style: robotoRegular),
                    ]),
                  ]),
                  const SizedBox(height: 10),

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

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('discount'.tr, style: robotoRegular),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      order.prescriptionOrder! ? IconButton(
                        constraints: const BoxConstraints(maxHeight: 36),
                        onPressed: () => Get.dialog(AmountInputDialogue(orderId: widget.orderId, isItemPrice: false, amount: discount), barrierDismissible: true),
                        icon: const Icon(Icons.edit, size: 16),
                      ) : const SizedBox(),
                      Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular),
                    ]),
                  ]),
                  const SizedBox(height: 10),

                  couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('coupon_discount'.tr, style: robotoRegular),
                    Text(
                      '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                      style: robotoRegular,
                    ),
                  ]) : const SizedBox(),
                  SizedBox(height: couponDiscount > 0 ? 10 : 0),

                  !taxIncluded ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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

                  order.paymentMethod == 'partial_payment' ? DottedBorder(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 1,
                    strokeCap: StrokeCap.butt,
                    dashPattern: const [8, 5],
                    padding: const EdgeInsets.all(0),
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(Dimensions.radiusDefault),
                    child: Ink(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      color: restConfModel ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
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
                          Text('paid_by_wallet'.tr, style: restConfModel ? robotoMedium : robotoRegular),
                          Text(
                            PriceConverter.convertPrice(order.payments![0].amount),
                            style: restConfModel ? robotoMedium : robotoRegular,
                          ),
                        ]),
                        const SizedBox(height: 10),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments![1].paymentMethod?.tr})', style: restConfModel ? robotoMedium : robotoRegular),
                          Text(
                            PriceConverter.convertPrice(order.payments![1].amount),
                            style: restConfModel ? robotoMedium : robotoRegular,
                          ),
                        ]),
                      ]),
                    ),
                  ) : const SizedBox(),

                  order.paymentMethod != 'partial_payment' ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('total_amount'.tr, style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                    )),
                    Text(
                      PriceConverter.convertPrice(total),
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                    ),
                  ]) : const SizedBox(),

                  showDeliveryConfirmImage && Get.find<SplashController>().configModel!.dmPictureUploadStatus! && controllerOrderModel.orderStatus != 'delivered' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text('completed_after_delivery_picture'.tr, style: robotoRegular),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                              Positioned(
                                right: 0, top: 0,
                                child: InkWell(
                                  onTap: () => orderController.removePrescriptionImage(index),
                                  child: const Padding(
                                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    child: Icon(Icons.delete_forever, color: Colors.red),
                                  ),
                                ),
                              ),
                            ]),
                          ) : const SizedBox();
                        },
                      ),
                    ),
                  ]) : const SizedBox(),

                ]))),
              ))),

              showDeliveryConfirmImage && controllerOrderModel.orderStatus != 'delivered' ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: CustomButton(
                  buttonText: 'complete_delivery'.tr,
                  onPressed: () {
                    if(Get.find<SplashController>().configModel!.orderDeliveryVerification!) {
                      orderController.sendDeliveredNotification(controllerOrderModel.id);

                      Get.bottomSheet(VerifyDeliverySheet(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true).then((isSuccess) {

                        if(isSuccess && controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery')){
                          Get.bottomSheet(CollectMoneyDeliverySheet(
                            orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                            orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                            cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                          ), isScrollControlled: true, isDismissible: false);
                        }
                      });
                    } else {
                      Get.bottomSheet(CollectMoneyDeliverySheet(
                        orderID: controllerOrderModel.id, verify: Get.find<SplashController>().configModel!.orderDeliveryVerification,
                        orderAmount: order.paymentMethod == 'partial_payment' ? order.payments![1].amount!.toDouble() : controllerOrderModel.orderAmount,
                        cod: controllerOrderModel.paymentMethod == 'cash_on_delivery' || (order.paymentMethod == 'partial_payment' && order.payments![1].paymentMethod == 'cash_on_delivery'),
                      ), isScrollControlled: true);
                    }

                  },
                ),
              ) : showBottomView ? (controllerOrderModel.orderStatus == 'picked_up') ? Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(width: 1),
                ),
                alignment: Alignment.center,
                child: Text('item_is_on_the_way'.tr, style: robotoMedium),
              ) : showSlider ? (controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away'
              || restConfModel || selfDelivery) && cancelPermission!) ? Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(children: [

                  Expanded(child: TextButton(
                    /*onPressed: () => Get.dialog(ConfirmationDialog(
                      icon: Images.warning, title: 'are_you_sure_to_cancel'.tr, description: 'you_want_to_cancel_this_order'.tr,
                      onYesPressed: () {
                        orderController.updateOrderStatus(widget.orderId, AppConstants.CANCELED, back: true);
                      },
                    ), barrierDismissible: false),*/
                    onPressed: (){
                      orderController.setOrderCancelReason('');
                      Get.dialog(CancellationDialogue(orderId: order.id));
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
                        icon: Images.warning, title: 'are_you_sure_to_confirm'.tr, description: 'you_want_to_confirm_this_order'.tr,
                        onYesPressed: () {
                          orderController.updateOrderStatus(widget.orderId, AppConstants.confirmed, back: true);
                        },
                      ), barrierDismissible: false);
                    },
                  )),

                ]),
              ) : SliderButton(
                action: () {

                  if(controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away'
                      || restConfModel || selfDelivery))  {
                    Get.dialog(ConfirmationDialog(
                      icon: Images.warning, title: 'are_you_sure_to_confirm'.tr, description: 'you_want_to_confirm_this_order'.tr,
                      onYesPressed: () {
                        orderController.updateOrderStatus(widget.orderId, AppConstants.confirmed, back: true);
                      },
                      onNoPressed: () {
                        if(cancelPermission!) {
                          orderController.updateOrderStatus(widget.orderId, AppConstants.canceled, back: true);
                        }else {
                          Get.back();
                        }
                      },
                    ), barrierDismissible: false);
                  }

                  else if(controllerOrderModel.orderStatus == 'processing') {
                    Get.find<OrderController>().updateOrderStatus(widget.orderId, AppConstants.handover);
                  }

                  else if(controllerOrderModel.orderStatus == 'confirmed' || (controllerOrderModel.orderStatus == 'accepted'
                      && controllerOrderModel.confirmed != null)) {
                    debugPrint('accepted & confirm call----------------');
                    Get.dialog(InputDialog(
                      icon: Images.warning,
                      title: 'are_you_sure_to_confirm'.tr,
                      description: 'enter_processing_time_in_minutes'.tr, onPressed: (String? time){
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, AppConstants.processing, processingTime: time).then((success) {
                        Get.back();
                        if(success) {
                          Get.find<AuthController>().getProfile();
                          Get.find<OrderController>().getCurrentOrders();
                        }
                      });
                    },
                    ));
                  }

                  else if((controllerOrderModel.orderStatus == 'handover' && (controllerOrderModel.orderType == 'take_away' || selfDelivery))) {
                    if (Get.find<SplashController>().configModel!.orderDeliveryVerification! || controllerOrderModel.paymentMethod == 'cash_on_delivery') {
                      orderController.changeDeliveryImageStatus();
                      if(Get.find<SplashController>().configModel!.dmPictureUploadStatus!) {
                        Get.dialog(const DialogImage(), barrierDismissible: false);
                      }
                    } else {
                      Get.find<OrderController>().updateOrderStatus(controllerOrderModel.id, AppConstants.delivered);
                    }
                  }

                },
                label: Text(
                  (controllerOrderModel.orderStatus == 'pending' && (controllerOrderModel.orderType == 'take_away' || restConfModel || selfDelivery)) ? 'swipe_to_confirm_order'.tr
                      : (controllerOrderModel.orderStatus == 'confirmed' || (controllerOrderModel.orderStatus == 'accepted' && controllerOrderModel.confirmed != null))
                      ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText! ? 'swipe_to_cooking'.tr : 'swipe_to_process'.tr
                      : (controllerOrderModel.orderStatus == 'processing') ? 'swipe_if_ready_for_handover'.tr
                      : (controllerOrderModel.orderStatus == 'handover' && (controllerOrderModel.orderType == 'take_away' || selfDelivery)) ? 'swipe_to_deliver_order'.tr : '',
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

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(
                  onPressed: () {
                    Get.dialog(Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      child: InVoicePrintScreen(order: order, orderDetails: orderController.orderDetailsModel, isPrescriptionOrder: isPrescriptionOrder, dmTips: dmTips!),
                    ));
                  },
                  icon: Icons.local_print_shop,
                  buttonText: 'print_invoice'.tr,
                ),
              ),


            ]) : const Center(child: CircularProgressIndicator());
          }),
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
