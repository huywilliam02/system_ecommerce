import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/wishlist_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';

class AddFavouriteView extends StatelessWidget {
  final Item item;
  final double? top, right;
  final double? left;
  const AddFavouriteView({Key? key, required this.item, this.top = 15, this.right = 15, this.left}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, right: right, left: left,
      child: GetBuilder<WishListController>(builder: (wishController) {
        bool isWished = wishController.wishItemIdList.contains(item.id);
        return InkWell(
          onTap: () {
            if(Get.find<AuthController>().isLoggedIn()) {
              isWished ? wishController.removeFromWishList(item.id, false)
                  : wishController.addToWishList(item, null, false);
            }else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
          },
          child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).primaryColor, size: 20),
        );
      }),
    );
  }
}
