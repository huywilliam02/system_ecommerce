import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/chat_controller.dart';
import 'package:citgroupvn_ecommerce/controller/localization_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/notification_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/conversation_model.dart';
import 'package:citgroupvn_ecommerce/helper/date_converter.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_ink_well.dart';
import 'package:citgroupvn_ecommerce/view/base/paginated_list_view.dart';

class WebConversationListView extends StatefulWidget {
  final ScrollController scrollController;
  final ConversationsModel? conversation;
  final ChatController chatController;
  final String type;

  const WebConversationListView({Key? key, required this.scrollController, required this.conversation, required this.chatController, required this.type, }) : super(key: key);

  @override
  State<WebConversationListView> createState() => _WebConversationListViewState();
}

class _WebConversationListViewState extends State<WebConversationListView> {

  @override
  void initState() {
    super.initState();

    // Get.find<ChatController>().setType(widget.type);
    Get.find<ChatController>().getConversationList(1, type: widget.type);
  }

  @override
  Widget build(BuildContext context) {

    User? user;
    return (widget.conversation != null && widget.conversation?.conversations != null) ? widget.conversation!.conversations!.isNotEmpty ? RefreshIndicator(
        onRefresh: () async {
        await Get.find<ChatController>().getConversationList(1, type: widget.type);
      },
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: SizedBox(width: Dimensions.webMaxWidth, child: PaginatedListView(
          scrollController: widget.scrollController,
          onPaginate: (int? offset) => widget.chatController.getConversationList(offset!),
          totalSize: widget.conversation!.totalSize,
          offset: widget.conversation!.offset,
          enabledPagination: widget.chatController.searchConversationModel == null,
          itemView: ListView.builder(
            itemCount: widget.conversation!.conversations!.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {

              String? type;
              if(widget.conversation!.conversations![index]!.senderType == AppConstants.user
                  || widget.conversation?.conversations![index]!.senderType == AppConstants.customer) {
                user = widget.conversation?.conversations![index]!.receiver;
                type = widget.conversation?.conversations![index]!.receiverType;
              }else {
                user = widget.conversation?.conversations![index]!.sender;
                type = widget.conversation?.conversations![index]!.senderType;
              }

              String? baseUrl = '';
              if(type == AppConstants.vendor) {
                baseUrl = Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl;
              }else if(type == AppConstants.deliveryMan) {
                baseUrl = Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl;
              }else if(type == AppConstants.admin){
                baseUrl = Get.find<SplashController>().configModel!.baseUrls!.businessLogoUrl;
              }

              return Column(
                children: [

                  Container(
                    decoration: BoxDecoration(
                      color: (widget.chatController.selectedIndex == index && widget.chatController.type == type) ? Theme.of(context).primaryColor.withOpacity(0.10) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: CustomInkWell(
                      onTap: () {
                        String? type;
                        if(widget.conversation!.conversations![index]!.senderType == AppConstants.user
                            || widget.conversation?.conversations![index]!.senderType == AppConstants.customer) {
                          user = widget.conversation?.conversations![index]!.receiver;
                          type = widget.conversation?.conversations![index]!.receiverType;
                        }else {
                          user = widget.conversation?.conversations![index]!.sender;
                          type = widget.conversation?.conversations![index]!.senderType;
                        }

                        String? baseUrl = '';
                        if(type == AppConstants.vendor) {
                          baseUrl = Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl;
                        }else if(type == AppConstants.deliveryMan) {
                          baseUrl = Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl;
                        }else if(type == AppConstants.admin){
                          baseUrl = Get.find<SplashController>().configModel!.baseUrls!.businessLogoUrl;
                        }

                        if(Get.find<AuthController>().isLoggedIn()) {
                          Get.find<ChatController>().getMessages(1, NotificationBody(
                            type: widget.conversation!.conversations![index]!.senderType,
                            notificationType: NotificationType.message,
                            adminId: type == AppConstants.admin ? 0 : null,
                            restaurantId: type == AppConstants.vendor ? user?.id : null,
                            deliverymanId: type == AppConstants.deliveryMan ? user?.id : null,

                          ), user, widget.conversation?.conversations![index]!.id, firstLoad: true);
                          if(Get.find<UserController>().userInfoModel == null || Get.find<UserController>().userInfoModel!.userInfo == null) {
                            Get.find<UserController>().getUserInfo();
                          }
                          widget.chatController.setNotificationBody(
                            NotificationBody(
                              type: widget.conversation!.conversations![index]!.senderType,
                              notificationType: NotificationType.message,
                              adminId: type == AppConstants.admin ? 0 : null,
                              restaurantId: type == AppConstants.vendor ? user?.id : null,
                              deliverymanId: type == AppConstants.deliveryMan ? user?.id : null,
                              conversationId: widget.conversation?.conversations![index]!.id,
                              index: index,
                              image: '$baseUrl/${user != null ? user?.image : ''}',
                              name:  '${user?.fName} ${user?.lName}',
                              receiverType: type,
                            ),
                          );

                          widget.chatController.setSelectedIndex(index);

                        }

                      },
                      highlightColor: Theme.of(context).colorScheme.background.withOpacity(0.1),
                      radius: Dimensions.radiusSmall,
                      child: Stack(children: [
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            ClipOval(child: CustomImage(
                              height: 50, width: 50,
                              image: '$baseUrl/${user != null ? user?.image : ''}',
                            )),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                              user != null ? Text(
                                '${user?.fName} ${user?.lName}', style: robotoMedium,
                              ) : Text('${type!.tr} ${'deleted'.tr}', style: robotoMedium),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              widget.conversation!.conversations![index]!.lastMessage != null ? Text(
                                widget.conversation!.conversations![index]!.lastMessage!.message ?? '',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                              ) : const SizedBox(),
                            ])),
                          ]),
                        ),

                        Positioned(
                          right: Get.find<LocalizationController>().isLtr ? 5 : null, top: 15, left: Get.find<LocalizationController>().isLtr ? null : 5,
                          child: Text(
                            DateConverter.convertOnlyTodayTime(widget.conversation!.conversations![index]!.lastMessageTime!),
                            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall),
                          ),
                        ),

                        GetBuilder<UserController>(builder: (userController) {
                          return (userController.userInfoModel != null && userController.userInfoModel!.userInfo != null
                              && widget.conversation!.conversations![index]!.lastMessage!.senderId != userController.userInfoModel!.userInfo!.id
                              && widget.conversation!.conversations![index]!.unreadMessageCount! > 0) ? Positioned(right: Get.find<LocalizationController>().isLtr ? 5 : null, bottom: 8, left: Get.find<LocalizationController>().isLtr ? null : 5,
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                              child: Text(
                                widget.conversation!.conversations![index]!.unreadMessageCount.toString(),
                                style: robotoMedium.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeExtraSmall),
                              ),
                            ),
                          ) : const SizedBox();
                        }),

                      ]),
                    ),
                  ),

                  index + 1 == widget.conversation!.conversations!.length ? const SizedBox() : Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),

                ],
              );
            },
          ),
        )),
      ),
    ) : Center(child: Text('no_conversation_found'.tr)) : const ConversationShimmer();
  }
}

class ConversationShimmer extends StatelessWidget {
  const ConversationShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                children: [

                  Row(children: [

                    ClipOval(child: Container(height: 50, width: 50, color: Colors.grey[300])),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Container(height: 10, width: Get.width * 0.5, color: Colors.grey[300]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Container(height: 10, width: Get.width * 0.3, color: Colors.grey[300]),

                    ])),
                  ]),

                  Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),

                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
