import 'package:chatfrontend/tokenservice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenProvider= AsyncNotifierProvider<TokenService, String?>(TokenService.new);

    