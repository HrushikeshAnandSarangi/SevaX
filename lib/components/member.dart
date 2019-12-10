// The base class for the different types of items the List can contain
abstract class Member {}

// A ListItem that contains data to display a member
class MemberItem implements Member {
  final String email;
  final String fullName;
  final String avatarURL;

  MemberItem(this.email, this.fullName, this.avatarURL);
}
