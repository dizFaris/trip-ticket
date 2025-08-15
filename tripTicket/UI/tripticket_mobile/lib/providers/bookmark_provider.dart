import 'package:http/http.dart' as http;
import 'package:tripticket_mobile/models/bookmark_model.dart';
import 'package:tripticket_mobile/providers/base_provider.dart';

class BookmarkProvider extends BaseProvider<Bookmark> {
  BookmarkProvider() : super("Bookmark");

  @override
  Bookmark fromJson(data) {
    return Bookmark.fromJson(data);
  }

  Future<void> deleteBookmark(int userId, int tripId) async {
    var url =
        "${BaseProvider.baseUrl}Bookmark/delete?userId=$userId&tripId=$tripId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (!isValidResponse(response)) {
      throw UserFriendlyException("Failed to delete bookmark");
    }
  }

  Future<bool> isTripBookmarked(int userId, int tripId) async {
    var url =
        "${BaseProvider.baseUrl}Bookmark/is-bookmarked?userId=$userId&tripId=$tripId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return response.body.toLowerCase() == 'true';
    } else {
      throw UserFriendlyException("Failed to check bookmark status");
    }
  }
}
