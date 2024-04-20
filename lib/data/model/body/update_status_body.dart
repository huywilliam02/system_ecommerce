class UpdateStatusBody {
  String? token;
  int? orderId;
  String? status;
  String? otp;
  String method = 'put';
  String? reason;

  UpdateStatusBody({this.token, this.orderId, this.status, this.otp, this.reason});

  UpdateStatusBody.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    orderId = json['order_id'];
    status = json['status'];
    otp = json['otp'];
    status = json['_method'];
    reason = json['reason'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['token'] = token!;
    data['order_id'] = orderId.toString();
    data['status'] = status!;
    data['otp'] = otp??'';
    data['_method'] = method;
    if(reason != '' && reason != null) {
      data['reason'] = reason!;
    }
    return data;
  }
}
