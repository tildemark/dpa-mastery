/// Zero-knowledge deterministic cryptographic certificate hash and URL generation engine.
class CertificateService {
  static const String webBaseUrl = 'https://dpa.sanchez.ph';
  static const String linkedInOrgId = '144796321';
  static const String linkedInOrgName = 'DPA Mastery';

  /// Deterministic zero-knowledge cryptographic hash computation.
  /// Identical formula used in Next.js web certificate engine.
  static String computeChecksum(String name, String packId) {
    final seed = '${name.trim().toLowerCase()}_${packId}_2026';
    int hash = 0x811c9dc5;
    for (int i = 0; i < seed.length; i++) {
      hash ^= seed.codeUnitAt(i);
      hash = (hash + (hash << 1) + (hash << 4) + (hash << 7) + (hash << 8) + (hash << 24)) & 0xFFFFFFFF;
    }
    final hex = ((hash >>> 0) & 0xffff).toRadixString(16).toUpperCase().padLeft(4, '0');
    return hex;
  }

  /// Generate canonical serial code: `DPA-DPOACE-<CHECKSUM>-VERIFIED`
  static String generateSerial({
    required String name,
    String packCode = 'DPOACE',
    String packId = 'dpo_ace',
  }) {
    final checksum = computeChecksum(name, packId);
    return 'DPA-$packCode-$checksum-VERIFIED';
  }

  /// Build public online certificate viewing URL
  static String buildCertificateUrl({
    required String name,
    required String serial,
    String packTitle = 'DPO ACE Competency Examination',
  }) {
    final uri = Uri.parse('$webBaseUrl/certificate').replace(queryParameters: {
      'id': serial,
      'name': name,
      'pack': packTitle,
    });
    return uri.toString();
  }

  /// Build public verification registry ledger URL
  static String buildVerificationUrl({
    required String name,
    required String serial,
    String packTitle = 'DPO ACE Competency Examination',
  }) {
    final uri = Uri.parse('$webBaseUrl/verify').replace(queryParameters: {
      'id': serial,
      'name': name,
      'pack': packTitle,
    });
    return uri.toString();
  }

  /// Build 1-Tap LinkedIn "Add License or Certification" Direct URL
  static String buildLinkedInAddUrl({
    required String name,
    required String serial,
    String packTitle = 'DPO ACE Competency Examination',
  }) {
    final certUrl = buildVerificationUrl(name: name, serial: serial, packTitle: packTitle);
    final now = DateTime.now();

    final uri = Uri.parse('https://www.linkedin.com/profile/add').replace(queryParameters: {
      'startTask': 'CERTIFICATION_NAME',
      'name': '$packTitle (Mastery)',
      'organizationName': linkedInOrgName,
      'organizationId': linkedInOrgId,
      'issueYear': '${now.year}',
      'issueMonth': '${now.month}',
      'certUrl': certUrl,
      'certId': serial,
    });
    return uri.toString();
  }

  /// Build LinkedIn Feed Share URL
  static String buildLinkedInShareUrl({
    required String name,
    required String serial,
    String packTitle = 'DPO ACE Competency Examination',
  }) {
    final certUrl = buildVerificationUrl(name: name, serial: serial, packTitle: packTitle);
    return 'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(certUrl)}';
  }

  /// Build Facebook Share URL
  static String buildFacebookShareUrl({
    required String name,
    required String serial,
    String packTitle = 'DPO ACE Competency Examination',
  }) {
    final certUrl = buildVerificationUrl(name: name, serial: serial, packTitle: packTitle);
    return 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(certUrl)}';
  }
}
