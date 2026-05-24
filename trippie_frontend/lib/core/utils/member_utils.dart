// lib/core/utils/member_utils.dart
//
// Pomocné funkcie pre zobrazenie členov tripu.
// Extrahované z TripMembersScreen._MemberTile pre testovateľnosť.

class MemberUtils {
  MemberUtils._();

  /// Vráti iniciály z mena a priezviska veľkými písmenami.
  /// Príklad: ('Jana', 'Nová') → 'JN'
  /// Ak je meno prázdne, daná časť iniciály sa vynechá.
  static String initials(String firstname, String lastname) {
    final f = firstname.isNotEmpty ? firstname[0] : '';
    final l = lastname.isNotEmpty  ? lastname[0]  : '';
    return '$f$l'.toUpperCase();
  }
}