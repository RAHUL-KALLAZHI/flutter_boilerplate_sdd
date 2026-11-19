import 'package:injectable/injectable.dart';

import '../../router/app_router.dart';
import '../../router/router_listenable.dart';

@module
abstract class RouterModule {
  @lazySingleton
  RouterListenable get routerListenable => RouterListenable();

  @lazySingleton
  AppRouter appRouter(RouterListenable listenable) =>
      AppRouter(routerListenable: listenable);
}
