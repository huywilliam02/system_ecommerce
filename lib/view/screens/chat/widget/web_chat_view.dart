
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce/controller/chat_controller.dart';
import 'package:citgroupvn_ecommerce/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce/controller/user_controller.dart';
import 'package:citgroupvn_ecommerce/data/model/body/notification_body.dart';
import 'package:citgroupvn_ecommerce/data/model/response/conversation_model.dart';
import 'package:citgroupvn_ecommerce/util/app_constants.dart';
import 'package:citgroupvn_ecommerce/util/dimensions.dart';
import 'package:citgroupvn_ecommerce/util/images.dart';
import 'package:citgroupvn_ecommerce/util/styles.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce/view/base/footer_view.dart';
import 'package:citgroupvn_ecommerce/view/base/not_logged_in_screen.dart';
import 'package:citgroupvn_ecommerce/view/base/paginated_list_view.dart';
import 'package:citgroupvn_ecommerce/view/base/web_search_field.dart';
import 'package:citgroupvn_ecommerce/view/screens/chat/widget/chatting_shimmer.dart';
import 'package:citgroupvn_ecommerce/view/screens/chat/widget/message_bubble.dart';
import 'package:citgroupvn_ecommerce/view/screens/chat/widget/web_conversation_list_view.dart';


class WebChatView extends StatefulWidget {
  final ScrollController scrollController;
  final ConversationsModel? conversation;
  final ChatController chatController;
  final TextEditingController searchController;
  final Function initCall;

  const WebChatView({
    Key? key, required this.scrollController, required this.conversation, required this.chatController, required this.searchController, required this.initCall,
  }) : super(key: key);

  @override
  State<WebChatView> createState() => _WebChatViewState();
}

class _WebChatViewState extends State<WebChatView> with TickerProviderStateMixin{
  final TextEditingController _inputMessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerChat = ScrollController();
  final ScrollController _scrollController1 = ScrollController();
  late TabController _tabController;
  User? user;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          color: Theme.of(context).primaryColor.withOpacity(0.10),
          child: Center(child: Text('live_chat'.tr, style: robotoMedium)),
        ),

        Expanded(child: Scrollbar(controller: widget.scrollController, child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const BouncingScrollPhysics(),
          child: Get.find<AuthController>().isLoggedIn() ? FooterView(child: SizedBox(
            width: Dimensions.webMaxWidth,
            child:  Row(
              children: [

                /// Conversation List
                Container(
                  width: 415,
                  height: 570,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.04)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text('messages'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      /// Search
                      (Get.find<AuthController>().isLoggedIn() && widget.conversation != null && widget.conversation?.conversations != null
                      && widget.chatController.conversationModel!.conversations!.isNotEmpty) ? Center(child: SizedBox(width: Dimensions.webMaxWidth, child: WebSearchField(
                        prefixWidget: widget.chatController.searchConversationModel != null ? null: Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeSmall),
                          child: Image.asset(Images.searchIcon, height: 18, width: 18,),
                        ),
                        controller: widget.searchController,
                        hint: 'search_'.tr,
                        suffixIcon: widget.chatController.searchConversationModel != null ? Icons.close : null,

                        onSubmit: (String text) {
                          if(widget.searchController.text.trim().isNotEmpty) {
                            widget.chatController.searchConversation(widget.searchController.text.trim());
                          }else {
                            showCustomSnackBar('write_something'.tr);
                          }
                        },
                        iconPressed: () {
                          if(widget.chatController.searchConversationModel != null) {
                            widget.searchController.text = '';
                            widget.chatController.removeSearchMode();
                          }else {
                            if(widget.searchController.text.trim().isNotEmpty) {
                              widget.chatController.searchConversation(widget.searchController.text.trim());
                            }else {
                              showCustomSnackBar('write_something'.tr);
                            }
                          }
                        },
                      ))) : const SizedBox(),

                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              /// admin conversationList

                              InkWell(
                                onTap: () {
                                  Get.find<ChatController>().getMessages(1, NotificationBody(
                                    type: 'admin',
                                    notificationType: NotificationType.message,
                                    adminId: 0,
                                    restaurantId: null,
                                    deliverymanId: null,
                                  ), user, 0, firstLoad: true);
                                  if(Get.find<UserController>().userInfoModel == null || Get.find<UserController>().userInfoModel!.userInfo == null) {
                                    Get.find<UserController>().getUserInfo();
                                  }
                                  widget.chatController.setNotificationBody(
                                    NotificationBody(
                                      type: 'admin',
                                      notificationType: NotificationType.message,
                                      adminId: 0,
                                      restaurantId: null,
                                      deliverymanId: null,
                                      conversationId: 0,
                                      image: '${Get.find<SplashController>().configModel!.baseUrls!.businessLogoUrl}/${Get.find<SplashController>().configModel!.logo}',
                                      name: '${Get.find<SplashController>().configModel!.businessName}',
                                      receiverType: 'admin',
                                    ),
                                  );

                                  widget.chatController.setSelectedIndex(-1);
                                },
                                child: Builder(
                                  builder: (context) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        color: widget.chatController.selectedIndex == -1 ? Theme.of(context).primaryColor.withOpacity(0.10) : Theme.of(context).cardColor,
                                      ),
                                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                      child: Column(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                          child: Row(children: [
                                            ClipOval(child: CustomImage(
                                              height: 50, width: 50,
                                              image: '${Get.find<SplashController>().configModel!.baseUrls!.businessLogoUrl}/${Get.find<SplashController>().configModel!.logo}',
                                            )),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),

                                            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                                              Text(
                                                '${Get.find<SplashController>().configModel!.businessName}', style: robotoMedium,
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                            ])),
                                          ]),
                                        ),
                                      ]),
                                    );
                                  }
                                ),
                              ),
                              Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),

                              /// TabBar
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  indicatorColor: Theme.of(context).primaryColor,
                                  labelColor: Theme.of(context).primaryColor,
                                  unselectedLabelColor: Theme.of(context).disabledColor,
                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  unselectedLabelStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  tabs: [
                                    Tab(text: 'store'.tr),
                                    Tab(text: 'delivery_man'.tr),
                                  ],
                                  onTap: (int index){
                                    if(index == 0){
                                      widget.chatController.setType('vendor');
                                      widget.chatController.setTabSelect();
                                    } else {
                                      widget.chatController.setType('delivery_man');
                                      widget.chatController.setTabSelect();
                                    }
                                  },
                                ),
                              ),


                              /// TabBarView
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: TabBarView(
                                  controller: _tabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [

                                    // Todo: have to modify according to modified api [api is not ready yet]
                                    /// Store
                                    WebConversationListView(
                                      chatController: widget.chatController,
                                      conversation: widget.conversation,
                                      scrollController: _scrollController1,
                                      type: 'vendor',
                                    ),

                                    /// Delivery Man
                                    WebConversationListView(
                                      chatController: widget.chatController,
                                      conversation: widget.conversation,
                                      scrollController: _scrollController1,
                                      type: 'delivery_man',
                                    ),

                                  ],
                                ),
                              ),
                            ],

                          ),
                        ),
                      ),
                    ),

                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeLarge),

                /// ChatView
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 569,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: ShapeDecoration(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.04)),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Column(children: [

                      /// Header
                     if(widget.chatController.notificationBody != null) Container(
                       padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                        child: Column(
                          children: [

                            Row(children: [

                              ClipOval(child: CustomImage(
                                height: 50, width: 50,
                                image: widget.chatController.notificationBody!.image!,
                              )),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Row(
                                  children: [
                                    
                                    Flexible(
                                      child: Text(
                                        widget.chatController.notificationBody!.name!, style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    
                                    Text('(${widget.chatController.notificationBody!.receiverType!.tr})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Text(
                                  widget.chatController.notificationBody!.receiverType!.tr,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                                ),
                              ])),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Divider(color: Theme.of(context).disabledColor.withOpacity(.5)),
                            
                          ],
                        ),
                      ),

                      /// Chat
                      Expanded(child: widget.chatController.notificationBody != null ? widget.chatController.messageModel != null ? widget.chatController.messageModel!.messages!.isNotEmpty ? SingleChildScrollView(
                        controller: _scrollControllerChat,
                        reverse: true,
                        child: PaginatedListView(
                          scrollController: _scrollControllerChat,
                          reverse: true,
                          totalSize: widget.chatController.messageModel != null ? widget.chatController.messageModel!.totalSize : null,
                          offset: widget.chatController.messageModel != null ? widget.chatController.messageModel!.offset : null,
                          onPaginate: (int? offset) async => await widget.chatController.getMessages(
                            offset!, NotificationBody(
                            type: widget.chatController.notificationBody!.type,
                            notificationType: NotificationType.message,
                            adminId: widget.chatController.notificationBody!.type == AppConstants.admin ? 0 : null,
                            restaurantId: widget.chatController.notificationBody!.type == AppConstants.vendor ? user?.id : null,
                            deliverymanId: widget.chatController.notificationBody!.type == AppConstants.deliveryMan ? user?.id : null,
                          ), user, widget.chatController.notificationBody!.conversationId,
                          ),
                          itemView: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: widget.chatController.messageModel!.messages!.length,
                            itemBuilder: (context, index) {
                              return MessageBubble(
                                message: widget.chatController.messageModel!.messages![index],
                                user: widget.chatController.messageModel!.conversation!.receiver,
                                userType: widget.chatController.notificationBody!.adminId != null ? AppConstants.admin
                                    : widget.chatController.notificationBody!.deliverymanId != null ? AppConstants.deliveryMan : AppConstants.vendor,
                              );
                            },
                          ),
                        ),
                      ) : Center(child: Text('no_message_found'.tr)) : const ChattingShimmer() :  Center(child: Text('no_conversation_selected'.tr))),


                      /// Message Input
                      if(widget.chatController.notificationBody != null) Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(.2)),
                        ),

                        child: Column(children: [

                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                child: Column(
                                  children: [

                                    TextField(
                                      inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                                      controller: _inputMessageController,
                                      textCapitalization: TextCapitalization.sentences,
                                      style: robotoRegular,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'start_a_new_message'.tr,
                                        hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                                      ),
                                      onSubmitted: (String newText) {
                                        if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                          Get.find<ChatController>().toggleSendButtonActivity();
                                        }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                          Get.find<ChatController>().toggleSendButtonActivity();
                                        }
                                      },
                                      onChanged: (String newText) {
                                        if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                                          Get.find<ChatController>().toggleSendButtonActivity();
                                        }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                                          Get.find<ChatController>().toggleSendButtonActivity();
                                        }
                                      },
                                    ),

                                    GetBuilder<ChatController>(builder: (chatController) {
                                      return chatController.chatImage.isNotEmpty ? SizedBox(height: 100,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: chatController.chatImage.length,
                                            itemBuilder: (BuildContext context, index){
                                              return  chatController.chatImage.isNotEmpty ? Padding(
                                                padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
                                                child: Stack(children: [

                                                  Container(width: 100, height: 100,
                                                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                                    child: ClipRRect(
                                                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                                      child: Image.memory(
                                                        chatController.chatRawImage[index], width: 100, height: 100, fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),

                                                  Positioned(top:0, right:0,
                                                    child: InkWell(
                                                      onTap : () => chatController.removeImage(index, _inputMessageController.text.trim()),
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(4.0),
                                                          child: Icon(Icons.clear, color: Colors.red, size: 15),
                                                        ),
                                                      ),
                                                    ),
                                                  )],
                                                ),
                                              ) : const SizedBox();
                                            }),
                                      ) : const SizedBox();
                                    }),

                                  ],
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: () async {
                                Get.find<ChatController>().pickImage(false);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall),
                                child: Image.asset(Images.image, width: 25, height: 25, color: widget.chatController.chatImage.isNotEmpty ? Theme.of(context).primaryColor : Theme.of(context).hintColor,),
                              ),
                            ),

                            GetBuilder<ChatController>(builder: (chatController) {
                              return chatController.isLoading ? const Padding(
                                padding: EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
                                child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()),
                              ) : InkWell(
                                onTap: () async {
                                  if(chatController.isSendButtonActive) {
                                    await chatController.sendMessage(
                                      message: _inputMessageController.text, notificationBody: chatController.notificationBody,
                                      conversationID: chatController.notificationBody!.conversationId, index: chatController.notificationBody!.index,
                                    );
                                    _inputMessageController.clear();
                                    await Get.find<ChatController>().getConversationList(1, type: chatController.type!);
                                  }else {
                                    showCustomSnackBar('write_something'.tr);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
                                  child: Image.asset(
                                    Images.sendIconWeb, width: 25, height: 25,
                                    color: chatController.isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                  ),
                                ),
                              );
                            }
                            ),

                          ]),
                        ]),
                      ),
                    ]),
                  ),
                )



              ],
            ),

          )) :  NotLoggedInScreen(callBack: (value){
            widget.initCall();
            setState(() {});
          }),
        )))
      ],
    );
  }
}
