import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:tripticket_desktop/models/support_reply_model.dart';

class SupportReplyProvider extends BaseProvider<SupportReply> {
  SupportReplyProvider() : super("SupportReply");

  @override
  SupportReply fromJson(data) {
    return SupportReply.fromJson(data);
  }
}
