import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/controller/wallet_controller.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/no_data_screen.dart';
import 'history_item.dart';

class WalletHistoryWidget extends StatelessWidget {
  final bool fromWallet;
  const WalletHistoryWidget({Key? key, required this.fromWallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(
      builder: (walletController) {
        List<PopupMenuEntry> entryList = [];
        String filterName = '';
        if(fromWallet){
          for(int i=0; i < walletController.walletFilterList.length; i++){
            entryList.add(PopupMenuItem<int>(value: i, child: Text(
              walletController.walletFilterList[i].title!.tr,
              style: robotoMedium.copyWith(
                color: walletController.walletFilterList[i].value == walletController.type
                    ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor,
              ),
            )));
            if(walletController.walletFilterList[i].value == walletController.type) {
              filterName = walletController.walletFilterList[i].title!.tr;
            } else if(walletController.type == 'all') {
              filterName = '';
            }
          }
        }

        return Column(children: [
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeExtraLarge),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  fromWallet ? 'wallet_history'.tr : 'point_history'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                fromWallet ? const SizedBox(height: Dimensions.paddingSizeExtraSmall) : const SizedBox(),

                fromWallet ? Text(
                  filterName,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ) : const SizedBox(),

              ]),

              fromWallet ? PopupMenuButton<dynamic>(
                offset: const Offset(-20, 20),
                itemBuilder: (BuildContext context) => entryList,
                onSelected: (dynamic value) {
                  walletController.setWalletFilerType(walletController.walletFilterList[value].value!);
                  walletController.getWalletTransactionList('1', false, fromWallet, walletController.type);
                },
                padding: const EdgeInsets.symmetric(horizontal: 2),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeExtraSmall, top: 2, bottom: 2),
                    child: Row(children: [
                      Text(
                        'filter'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),

                      const Icon(Icons.arrow_drop_down, size: 18),
                    ]),
                  ),
                ),
              ) : const SizedBox(),

            ]),
          ),
          walletController.transactionList != null ? walletController.transactionList!.isNotEmpty ? GridView.builder(
            key: UniqueKey(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 50,
              mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0.01,
              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 7 : 4.45,
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 1,
            ),
            physics:  const NeverScrollableScrollPhysics(),
            shrinkWrap:  true,
            itemCount: walletController.transactionList!.length ,
            padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
            itemBuilder: (context, index) {
              return HistoryItem(index: index, fromWallet: fromWallet, data: walletController.transactionList);
            },
          ) : NoDataScreen(text: 'no_data_found'.tr) : WalletShimmer(walletController: walletController),

          walletController.isLoading ? const Center(child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CircularProgressIndicator(),
          )) : const SizedBox(),


        ]);
      }
    );
  }
}


class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  const WalletShimmer({Key? key, required this.walletController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 3.8,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 1,
      ),
      physics:  const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount: 10,
      padding: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(height: 10, width: 50, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 70, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ]),
                ],
              ),
              Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge), child: Divider(color: Theme.of(context).disabledColor)),
            ],
            ),
          ),
        );
      },
    );
  }
}