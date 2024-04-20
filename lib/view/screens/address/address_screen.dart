import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_app_bar.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/menu_drawer.dart';
import 'package:citgroupvn_ecommerce/view/base/no_data_screen.dart';
import 'package:citgroupvn_ecommerce/view/base/not_logged_in_screen.dart';
import 'package:citgroupvn_ecommerce/view/base/web_page_title_widget.dart';
import 'package:citgroupvn_ecommerce/view/screens/address/widget/address_confirmation_dialogue.dart';
import 'package:citgroupvn_ecommerce/view/screens/address/widget/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<LocationController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return GetBuilder<LocationController>(
      builder: (locationController) {
        return Scaffold(
          appBar: CustomAppBar(title: 'my_address'.tr),
          endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
          floatingActionButton: ResponsiveHelper.isDesktop(context) || !isLoggedIn ? null : (locationController.addressList != null
          && locationController.addressList!.isEmpty) ? null : FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
            child: Icon(Icons.add, color: Theme.of(context).cardColor),
          ),
          floatingActionButtonLocation: ResponsiveHelper.isDesktop(context) ? FloatingActionButtonLocation.centerFloat : null,
          body: Container(
            height: context.height,
            decoration: BoxDecoration(image: DecorationImage(
                image: AssetImage(ResponsiveHelper.isDesktop(context) ? Images.addressCity : Images.city),
                alignment: ResponsiveHelper.isDesktop(context) ? Alignment.center : Alignment.bottomCenter,
              fit: BoxFit.fitWidth,
            ),

            ),
            child: isLoggedIn ? GetBuilder<LocationController>(builder: (locationController) {
              return RefreshIndicator(
                onRefresh: () async {
                  await locationController.getAddressList();
                },
                child: Scrollbar(controller: scrollController, child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      WebScreenTitleWidget(title: 'address'.tr),
                      Center(child: FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(
                            children: [
                              ResponsiveHelper.isDesktop(context) ? const SizedBox( height: Dimensions.paddingSizeSmall) : const SizedBox(),

                              // locationController.addressList != null ? locationController.addressList!.isNotEmpty ? ListView.builder(
                              //   padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              //   itemCount: locationController.addressList!.length,
                              //   physics: const NeverScrollableScrollPhysics(),
                              //   shrinkWrap: true,
                              //   itemBuilder: (context, index) {
                              //     return AddressWidget(
                              //       address: locationController.addressList![index], fromAddress: true,
                              //       onTap: () {
                              //         Get.toNamed(RouteHelper.getMapRoute(locationController.addressList![index], 'address', false));
                              //       },
                              //       onEditPressed: () {
                              //         Get.toNamed(RouteHelper.getEditAddressRoute(locationController.addressList![index]));
                              //       },
                              //       onRemovePressed: () {
                              //         if(Get.isSnackbarOpen) {
                              //           Get.back();
                              //         }
                              //         Get.dialog(AddressConfirmDialogue(
                              //           icon: Images.locationConfirm,
                              //           title: 'are_you_sure'.tr,
                              //           description: 'you_want_to_delete_this_location'.tr,
                              //           onYesPressed: () {
                              //             locationController.deleteUserAddressByID(locationController.addressList![index].id, index).then((response) {
                              //               Get.back();
                              //               showCustomSnackBar(response.message, isError: !response.isSuccess);
                              //             });
                              //           }),
                              //         );
                              //       },
                              //     );
                              //   },
                              // ) : NoDataScreen(text: 'no_saved_address_found'.tr, fromAddress: true) : const Center(child: CircularProgressIndicator()),

                              locationController.addressList != null ? locationController.addressList!.isNotEmpty ?
                              Padding(
                                padding: ResponsiveHelper.isMobile(context) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: Dimensions.paddingSizeLarge,
                                    mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? 4 : 4.8,
                                    crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 3,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: ResponsiveHelper.isDesktop(context) ? (locationController.addressList!.length + 1)  : locationController.addressList!.length ,
                                  itemBuilder: (context, index) {
                                    return (ResponsiveHelper.isDesktop(context) && (index == locationController.addressList!.length)) ?
                                    InkWell(
                                      onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                        decoration:  BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                                            const SizedBox(height: Dimensions.paddingSizeSmall),
                                            Text('add_new_address'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                                          ],
                                        )
                                      ),
                                    ) :
                                    AddressWidget(
                                      address: locationController.addressList![index], fromAddress: true,
                                      onTap: () {
                                        Get.toNamed(RouteHelper.getMapRoute(locationController.addressList![index], 'address', false));
                                      },
                                      onEditPressed: () {
                                        Get.toNamed(RouteHelper.getEditAddressRoute(locationController.addressList![index]));
                                      },
                                      onRemovePressed: () {
                                        if(Get.isSnackbarOpen) {
                                          Get.back();
                                        }
                                        Get.dialog(AddressConfirmDialogue(
                                          icon: Images.locationConfirm,
                                          title: 'are_you_sure'.tr,
                                          description: 'you_want_to_delete_this_location'.tr,
                                          onYesPressed: () {
                                            locationController.deleteUserAddressByID(locationController.addressList![index].id, index).then((response) {
                                              Get.back();
                                              showCustomSnackBar(response.message, isError: !response.isSuccess);
                                            });
                                          }),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ) : NoDataScreen(text: 'no_saved_address_found'.tr, fromAddress: true) : const Center(child: CircularProgressIndicator()),
                            ],
                          ),
                        ),
                      ))
                    ],
                  ),
                )),
              );
            }) :  NotLoggedInScreen(callBack: (value) {
              initCall();
              setState(() {});
            }),
          ),
        );
      }
    );
  }
}
