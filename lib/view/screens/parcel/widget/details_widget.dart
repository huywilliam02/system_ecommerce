import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/data/model/response/address_model.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';

class DetailsWidget extends StatelessWidget {
  final String title;
  final AddressModel? address;
  const DetailsWidget({Key? key, required this.title, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Text(title, style: robotoMedium),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

      Text(
        address!.contactPersonName ?? '',
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
      ),

      Text(
        address!.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),

      Wrap(children: [
        (address!.streetNumber != null && address!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${address!.streetNumber!}, ',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),

        (address!.house != null && address!.house!.isNotEmpty) ? Text('${'house'.tr}: ${address!.house!}, ',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),

        (address!.floor != null && address!.floor!.isNotEmpty) ? Text('${'floor'.tr}: ${address!.floor!}',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
        ) : const SizedBox(),
      ]),

      Text(
        address!.contactPersonNumber ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
      ),

    ]);
  }
}
