import 'package:flutter/material.dart';
import 'package:citgroupvn_ecommerce/controller/parcel_controller.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';

class ServiceInfoList extends StatelessWidget {
  final ParcelController parcelController;
  const ServiceInfoList({Key? key, required this.parcelController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String>? title;
    List<String>? subTitle;
    if(parcelController.videoContentDetails != null) {
      title = [];
      subTitle = [];
      for(int i=0; i<parcelController.videoContentDetails!.bannerContents!.length; i++) {
        if(i%2 == 0){
          title.add(parcelController.videoContentDetails!.bannerContents![i].value ?? '');
        } else {
          subTitle.add(parcelController.videoContentDetails!.bannerContents![i].value ?? '');
        }
      }
    }
    return parcelController.videoContentDetails != null ? ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: title!.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(children: [
            Container(
              height: 14, width: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            Text(title![index], style: robotoBold),
          ]),

          Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 22.5),
            margin: const EdgeInsets.only(left: 7),
            decoration: BoxDecoration(
              border: index == title.length - 1 ? null : Border(left: BorderSide(width: 1, color: Theme.of(context).disabledColor))),
            child: Text(
              subTitle![index],
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
              textAlign: TextAlign.justify,
            ),
          ),
        ]);
      },
    ) : const SizedBox();
  }
}
