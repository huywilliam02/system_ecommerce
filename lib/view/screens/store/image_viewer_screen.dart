import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:citgroupvn_ecommerce_store/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_store/controller/store_controller.dart';
import 'package:citgroupvn_ecommerce_store/data/model/response/item_model.dart';
import 'package:citgroupvn_ecommerce_store/view/base/custom_app_bar.dart';

class ImageViewerScreen extends StatelessWidget {
  final Item item;
  const ImageViewerScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<StoreController>().setImageIndex(0, false);
    List<String?> imageList = [];
    imageList.add(item.image);
    imageList.addAll(item.images!);
    final PageController pageController = PageController();

    return Scaffold(
      appBar: CustomAppBar(title: 'item_images'.tr),
      body: GetBuilder<StoreController>(builder: (storeController) {
        return Column(children: [

          Expanded(child: Stack(children: [

            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: Theme.of(context).cardColor),
              itemCount: imageList.length,
              pageController: pageController,
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage('${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${imageList[index]}'),
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: index.toString()),
                );
              },
              loadingBuilder: (context, event) => Center(child: SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator(
                value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ))),
              onPageChanged: (int index) => storeController.setImageIndex(index, true),
            ),

            storeController.imageIndex != 0 ? Positioned(
              left: 5, top: 0, bottom: 0,
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () {
                    if(storeController.imageIndex > 0) {
                      pageController.animateToPage(
                        storeController.imageIndex-1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Icon(Icons.chevron_left_outlined, size: 40),
                ),
              ),
            ) : const SizedBox(),

            storeController.imageIndex != imageList.length-1 ? Positioned(
              right: 5, top: 0, bottom: 0,
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () {
                    if(storeController.imageIndex < imageList.length) {
                      pageController.animateToPage(
                        storeController.imageIndex+1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Icon(Icons.chevron_right_outlined, size: 40),
                ),
              ),
            ) : const SizedBox(),

          ])),

        ]);
      }),
    );
  }
}