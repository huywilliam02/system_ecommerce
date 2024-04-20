import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citgroupvn_ecommerce/controller/parcel_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/screens/location/widget/location_search_dialog.dart';

class SearchLocationWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  final String? pickedAddress;
  final bool? isEnabled;
  final bool? isPickedUp;
  final bool? fromDialog;
  final String? hint;
  const SearchLocationWidget({Key? key, required this.mapController, required this.pickedAddress, required this.isEnabled, this.isPickedUp, this.hint, this.fromDialog = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.dialog(LocationSearchDialog(mapController: mapController, isPickedUp: isPickedUp));
        if(isEnabled != null) {
          Get.find<ParcelController>().setIsPickedUp(isPickedUp, true);
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: isEnabled != null ? Border.all(
            color: fromDialog! ? Theme.of(context).disabledColor : isEnabled! ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: isEnabled! ? 2 : 1,
          ) : null,
        ),
        child: Row(children: [
          (/*!fromDialog! &&*/ pickedAddress != null && pickedAddress!.isNotEmpty) ? Icon(
            Icons.location_on, size: 25,
            color: (isEnabled == null || isEnabled!) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
          ) : Text('search_location'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          Expanded(
            child: (pickedAddress != null && pickedAddress!.isNotEmpty) ? Text(
              pickedAddress!,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis,
            ) : Text(
              hint ?? '',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Icon(Icons.search, size: 25, color: fromDialog! ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color),
        ]),
      ),
    );
  }
}
