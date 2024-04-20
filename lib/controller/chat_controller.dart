import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:citgroupvn_ecommerce_delivery/controller/auth_controller.dart';
import 'package:citgroupvn_ecommerce_delivery/data/api/api_checker.dart';
import 'package:citgroupvn_ecommerce_delivery/data/api/api_client.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/body/notification_body.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/conversation_model.dart';
import 'package:citgroupvn_ecommerce_delivery/data/model/response/message_model.dart';
import 'package:citgroupvn_ecommerce_delivery/data/repository/chat_repo.dart';
import 'package:citgroupvn_ecommerce_delivery/util/app_constants.dart';

class ChatController extends GetxController implements GetxService{

  final ChatRepo chatRepo;
  ChatController({required this.chatRepo});

  List<bool>? _showDate;
  List<XFile>? _imageFiles;
  bool _isSendButtonActive = false;
  final bool _isSeen = false;
  final bool _isSend = true;
  final bool _isMe = false;
  bool _isLoading= false;
  List <XFile>?_chatImage = [];
  int? _pageSize;
  int? _offset;
  ConversationsModel? _conversationModel ;
  ConversationsModel? _searchConversationModel;
  MessageModel? _messageModel;

  bool get isLoading => _isLoading;
  List<bool>? get showDate => _showDate;
  List<XFile>? get imageFiles => _imageFiles;
  bool get isSendButtonActive => _isSendButtonActive;
  bool get isSeen => _isSeen;
  bool get isSend => _isSend;
  bool get isMe => _isMe;
  int? get pageSize => _pageSize;
  int? get offset => _offset;
  List<XFile>? get chatImage => _chatImage;
  ConversationsModel? get conversationModel => _conversationModel;
  ConversationsModel? get searchConversationModel => _searchConversationModel;
  MessageModel? get messageModel => _messageModel;

  Future<void> getConversationList(int offset) async{
    _searchConversationModel = null;
    _conversationModel = null;
    Response response = await chatRepo.getConversationList(offset);
    if(response.statusCode == 200) {
      if(offset == 1) {
        _conversationModel = ConversationsModel.fromJson(response.body);
      }else {
        _conversationModel!.totalSize = ConversationsModel.fromJson(response.body).totalSize;
        _conversationModel!.offset = ConversationsModel.fromJson(response.body).offset;
        _conversationModel!.conversations!.addAll(ConversationsModel.fromJson(response.body).conversations!);
      }
    }else {
      ApiChecker.checkApi(response);
    }
    update();

  }

  Future<void> searchConversation(String name) async {
    _searchConversationModel = ConversationsModel();
    update();
    Response response = await chatRepo.searchConversationList(name);
    if(response.statusCode == 200) {
      _searchConversationModel = ConversationsModel.fromJson(response.body);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void removeSearchMode() {
    _searchConversationModel = null;
    update();
  }

  Future<void> getMessages(int offset, NotificationBody notificationBody, User? user, int? conversationID, {bool firstLoad = false}) async {
    Response? response;
    if(firstLoad) {
      _messageModel = null;
    }

    if(notificationBody.customerId != null || notificationBody.type == AppConstants.user) {
      response = await chatRepo.getMessages(offset, notificationBody.customerId, AppConstants.user, conversationID);
    }else if(notificationBody.vendorId != null || notificationBody.type == AppConstants.vendor) {
      response = await chatRepo.getMessages(offset, notificationBody.vendorId, AppConstants.vendor, conversationID);
    }

    if (response != null && response.body['messages'] != {} && response.statusCode == 200) {
      if (offset == 1) {

        /// Unread-read
        /* if(conversationID != null && _conversationModel != null) {
          int _index = -1;
          for(int index=0; index<_conversationModel.conversations.length; index++) {
            if(conversationID == _conversationModel.conversations[index].id) {
              _index = index;
              break;
            }
          }
          if(_index != -1) {
            _conversationModel.conversations[_index].unreadMessageCount = 0;
          }
        }*/

        if(Get.find<AuthController>().profileModel == null) {
          await Get.find<AuthController>().getProfile();
        }

        /// Manage Receiver
        _messageModel = MessageModel.fromJson(response.body);
        if(_messageModel!.conversation == null && user != null) {
          _messageModel!.conversation = Conversation(sender: User(
            id: Get.find<AuthController>().profileModel!.id, image: Get.find<AuthController>().profileModel!.image,
            fName: Get.find<AuthController>().profileModel!.fName, lName: Get.find<AuthController>().profileModel!.lName,
          ), receiver: user);
        }else if(_messageModel!.conversation != null && _messageModel!.conversation!.receiverType == 'delivery_man') {
          User? receiver = _messageModel!.conversation!.receiver;
          _messageModel!.conversation!.receiver = _messageModel!.conversation!.sender;
          _messageModel!.conversation!.sender = receiver;
        }
      }else {
        _messageModel!.totalSize = MessageModel.fromJson(response.body).totalSize;
        _messageModel!.offset = MessageModel.fromJson(response.body).offset;
        _messageModel!.messages!.addAll(MessageModel.fromJson(response.body).messages!);
      }
    } else {
      ApiChecker.checkApi(response!);
    }
    _isLoading = false;
    update();

  }

  void pickImage(bool isRemove) async {
    final ImagePicker picker = ImagePicker();
    if(isRemove) {
      _imageFiles = [];
      _chatImage = [];
    }else {
      _imageFiles = await picker.pickMultiImage(imageQuality: 30);
      if (_imageFiles != null) {
        _chatImage = imageFiles;
        _isSendButtonActive = true;
      }
    }
    update();
  }
  void removeImage(int index){
    chatImage!.removeAt(index);
    update();
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    update();
  }

  Future<Response?> sendMessage({required String message, required NotificationBody? notificationBody, required int? conversationId}) async {
    Response? response;
    _isLoading = true;
    update();

    List<MultipartBody> myImages = [];
    for (var image in _chatImage!) {
      myImages.add(MultipartBody('image[]', image));
    }

    if(notificationBody != null && (notificationBody.customerId != null || notificationBody.type == AppConstants.user)) {
      response = await chatRepo.sendMessage(message, myImages, conversationId, notificationBody.customerId, AppConstants.customer);
    }else if(notificationBody != null && (notificationBody.vendorId != null || notificationBody.type == AppConstants.vendor)){
      response = await chatRepo.sendMessage(message, myImages, conversationId, notificationBody.vendorId, AppConstants.vendor);
    }

    if (response!.statusCode == 200) {
      _imageFiles = [];
      _chatImage = [];
      _isSendButtonActive = false;
      _isLoading = false;
      _messageModel = MessageModel.fromJson(response.body);
      if(_messageModel!.conversation != null && _messageModel!.conversation!.receiverType == 'delivery_man') {
        User? receiver = _messageModel!.conversation!.receiver;
        _messageModel!.conversation!.receiver = _messageModel!.conversation!.sender;
        _messageModel!.conversation!.sender = receiver;
      }
    }
    update();
    return response;
  }
}