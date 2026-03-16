enum DocumentType {
  taxiLicense,
  insurance,
  dbsCert,
  vehicleLicense,
  driversLicense,
  safeGuardingCert,
  firstAidCert,
  otherDocument,
}

extension DocumentTypeExtension on DocumentType {
  String get title {
    switch (this) {
      case DocumentType.taxiLicense:
        return "Taxi Licence"; 
      case DocumentType.insurance:
        return "Insurance";
      case DocumentType.dbsCert:
        return "DBS CERT";
      case DocumentType.vehicleLicense:
        return "Vehicle Licence";
      case DocumentType.driversLicense:
        return "Drivers Licence";
      case DocumentType.safeGuardingCert:
        return "Safe Guarding CERT";
      case DocumentType.firstAidCert:
        return "First AID CERT";
      case DocumentType.otherDocument:
        return "Other Document";
    }
  }

  int get indexValue => index;
}
