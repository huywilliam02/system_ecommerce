import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/chat_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/splash_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/body/notification_body.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/conversation_model.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/responsive_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/helper/route_helper.dart';
import 'package:citgroupvn_ecommerce_delivery/util/app_constants.dart';
import 'package:citgroupvn_ecommerce_delivery/util/dimensions.dart';
import 'package:citgroupvn_ecommerce_delivery/util/images.dart';
import 'package:citgroupvn_ecommerce_delivery/util/styles.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_image.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/custom_snackbar.dart';
import 'package:citgroupvn_ecommerce_delivery/view/base/paginated_list_view.dart';
import 'package:citgroupvn_ecommerce_delivery/view/screens/chat/widget/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final NotificationBody? notificationBody;
  final User? user;
  final int? conversationId;
  final bool fromNotification;
  const ChatScreen({Key? key, required this.notificationBody, required this.user, this.conversationId, this.fromNotification = false}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<ChatController>().getMessages(1, widget.notificationBody!, widget.user, widget.conversationId, firstLoad: true);

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatController) {
      String? baseUrl = '';
      if(widget.notificationBody!.customerId != null) {
        baseUrl = Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl;
      }else {
        baseUrl = Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl;
      }
      return WillPopScope(
        onWillPop: () async{
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
            return true;
          } else {
            Get.back();
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(onPressed: () {
                if(widget.fromNotification){
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }else{
                  Get.back();
                }
              },
                  icon: const Icon(Icons.arrow_back_ios_rounded)),
              title: Text(
                chatController.messageModel != null ? '${chatController.messageModel!.conversation!.receiver!.fName ?? ''}'
                    ' ${chatController.messageModel!.conversation!.receiver!.lName ?? ''}' : 'receiver_name'.tr,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 40, height: 40, alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(width: 2,color: Theme.of(context).cardColor),
                      color: Theme.of(context).cardColor,
                    ),
                    child: ClipOval(child: CustomImage(
                      image:'$baseUrl'
                          '/${chatController.messageModel != null ? chatController.messageModel!.conversation!.receiver!.image : ''}',
                      fit: BoxFit.cover, height: 40, width: 40,
                    )),
                  ),
                )
              ]),

          body: _isLoggedIn ? SafeArea(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [

                  Expanded(child: chatController.messageModel != null ? chatController.messageModel!.messages!.isNotEmpty ? SingleChildScrollView(
                    controller: _scrollController,
                    reverse: true,
                    child: PaginatedListView(
                      scrollController: _scrollController,
                      totalSize: chatController.messageModel != null ? chatController.messageModel!.totalSize : null,
                      offset: chatController.messageModel != null ? chatController.messageModel!.offset : null,
                      onPaginate: (int? offset) async => await chatController.getMessages(
                        offset!, widget.notificationBody!, widget.user, widget.conversationId,
                      ),
                      productView: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: chatController.messageModel!.messages!.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: chatController.messageModel!.messages![index],
                            user: chatController.messageModel!.conversation!.receiver,
                            sender: chatController.messageModel!.conversation!.sender,
                            userType: widget.notificationBody!.customerId != null ? AppConstants.user : AppConstants.vendor,
                          );
                        },
                      ),
                    ),
                  ) : const SizedBox() : const Center(child: CircularProgressIndicator())),

                  (chatController.messageModel != null && (chatController.messageModel!.status! || chatController.messageModel!.messages!.isEmpty)) ? Container(
                    color: Theme.of(context).cardColor,
                    child: Column(children: [

                      chatController.chatImage!.isNotEmpty ? SizedBox(height: 100,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: chatController.chatImage!.length,
                            itemBuilder: (BuildContext context, index){
                              return  chatController.chatImage!.isNotEmpty ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(children: [

                                  Container(width: 100, height: 100,
                                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                      child: ResponsiveHelper.isWeb() ? Image.network(
                                        chatController.chatImage![index].path, width: 100, height: 100, fit: BoxFit.cover,
                                      ) : Image.file(
                                        File(chatController.chatImage![index].path), width: 100, height: 100, fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  Positioned(top:0, right:0,
                                    child: InkWell(
                                      onTap : () => chatController.removeImage(index),
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
                      ) : const SizedBox(),

                      Row(children: [

                        InkWell(
                          onTap: () async {
                            Get.find<ChatController>().pickImage(false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: Image.asset(Images.image, width: 25, height: 25, color: Theme.of(context).hintColor),
                          ),
                        ),

                        SizedBox(
                          height: 25,
                          child: VerticalDivider(width: 0, thickness: 1, color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          child: TextField(
                            inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                            controller: _inputMessageController,
                            textCapitalization: TextCapitalization.sentences,
                            style: robotoRegular,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'type_here'.tr,
                              hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
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
                        ),

                        GetBuilder<ChatController>(builder: (chatController) {
                          return !chatController.isLoading ? InkWell(
                            onTap: () async {
                              if(chatController.isSendButtonActive) {
                                if(chatController.chatImage!.length > 3){
                                  showCustomSnackBar('you_do_not_send_more_then_3_photos'.tr);
                                }else{
                                  chatController.sendMessage(
                                    message: _inputMessageController.text, notificationBody: widget.notificationBody, conversationId: widget.conversationId,
                                  ).then((value) {
                                    _inputMessageController.clear();
                                    if(value!.statusCode == 200){
                                      Future.delayed(const Duration(seconds: 2),() {
                                        chatController.getMessages(1, widget.notificationBody!, widget.user, widget.conversationId);
                                      });
                                    }
                                  });
                                }

                              }else{
                                showCustomSnackBar('write_somethings'.tr);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                              child: Image.asset(
                                Images.send, width: 25, height: 25,
                                color: chatController.isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                              ),
                            ),
                          ) : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: SizedBox(
                              width: 25, height: 25,
                              child: CircularProgressIndicator(),
                            ),
                          ) ;
                        }),

                      ]),
                    ]),
                  ) : const SizedBox(),
                ]),
              ),
            ),
          ) : const Center(child: Text('Not Login')),
        ),
      );
    }
    );
  }
}
