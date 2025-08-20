import 'package:tripticket_desktop/providers/base_provider.dart';
import 'package:tripticket_desktop/models/support_ticket_model.dart';

class SupportTicketProvider extends BaseProvider<SupportTicket> {
  SupportTicketProvider() : super("SupportTicket");

  @override
  SupportTicket fromJson(data) {
    return SupportTicket.fromJson(data);
  }
}
