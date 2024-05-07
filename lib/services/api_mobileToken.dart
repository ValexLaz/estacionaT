import 'package:map_flutter/models/MobileToken.dart';
import 'package:map_flutter/services/ApiRepository.dart';

class ApiMobileTokenRepository extends ApiRepository<MobileToken> {
  ApiMobileTokenRepository()
      : super(
          path: 'user/users/mobile-tokens/',
          fromJson: MobileToken.fromJson,
          toJson: (MobileToken p) => p.toJson(),
        );
}
