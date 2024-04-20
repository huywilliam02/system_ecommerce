import 'package:citgroupvn_ecommerce/controller/item_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/order_details_model.dart';
import 'package:citgroupvn_ecommerce/data/model/response/order_model.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/screens/review/widget/deliver_man_review_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/review/widget/item_review_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateReviewScreen extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final DeliveryMan? deliveryMan;
  final int? orderID;
  const RateReviewScreen({Key? key, required this.orderDetailsList, required this.deliveryMan, required this.orderID}) : super(key: key);

  @override
  RateReviewScreenState createState() => RateReviewScreenState();
}

class RateReviewScreenState extends State<RateReviewScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: (widget.deliveryMan == null || widget.orderDetailsList.isEmpty) ? 1 : 2, initialIndex: 0, vsync: this);
    Get.find<ItemController>().initRatingData(widget.orderDetailsList);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: 'rate_review'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: Column(children: [
        Center(
          child: Container(
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).textTheme.bodyLarge!.color,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              labelStyle: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
              tabs: widget.orderDetailsList.isNotEmpty ? widget.deliveryMan != null ? [
                Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
                Tab(text: 'delivery_man'.tr),
              ] : [
                Tab(text: widget.orderDetailsList.length > 1 ? 'items'.tr : 'item'.tr),
              ] : [
                Tab(text: 'delivery_man'.tr),
              ],
            ),
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: widget.orderDetailsList.isNotEmpty ? widget.deliveryMan != null ? [
            ItemReviewWidget(orderDetailsList: widget.orderDetailsList),
            DeliveryManReviewWidget(deliveryMan: widget.deliveryMan, orderID: widget.orderID.toString()),
          ] : [
            ItemReviewWidget(orderDetailsList: widget.orderDetailsList),
          ] : [
            DeliveryManReviewWidget(deliveryMan: widget.deliveryMan, orderID: widget.orderID.toString()),
          ],
        )),

      ]),
    );
  }
}
