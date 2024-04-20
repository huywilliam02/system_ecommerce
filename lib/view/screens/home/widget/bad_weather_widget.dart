import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/location_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/zone_response_model.dart';
import 'package:citgroupvn_ecommerce/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
class BadWeatherWidget extends StatefulWidget {
  const BadWeatherWidget({Key? key}) : super(key: key);

  @override
  State<BadWeatherWidget> createState() => _BadWeatherWidgetState();
}

class _BadWeatherWidgetState extends State<BadWeatherWidget> {
  bool _showAlert = true;
  String? _message;
  @override
  void initState() {
    super.initState();

    ZoneData? zoneData;
    for (var data in Get.find<LocationController>().getUserAddress()!.zoneData!) {
      if(data.id == Get.find<LocationController>().getUserAddress()!.zoneId){
        if(data.increaseDeliveryFeeStatus == 1 && data.increaseDeliveryFeeMessage != null){
          zoneData = data;
        }
      }
    }

    if(zoneData != null){
      _showAlert = zoneData.increaseDeliveryFeeStatus == 1;
      _message = zoneData.increaseDeliveryFeeMessage;
    }else{
      _showAlert = false;
    }

  }

  @override
  Widget build(BuildContext context) {

    return _showAlert && _message != null && _message!.isNotEmpty ? Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).primaryColor.withOpacity(0.7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
      child: Row(
        children: [
          Image.asset(Images.weather, height: 50, width: 50),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Text(
              _message!,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
          )),
        ],
      ),
    ) : const SizedBox();
  }
}
