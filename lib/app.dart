import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khyate_tailor_app/common_widget/no_internet_dialog.dart';
import 'package:khyate_tailor_app/core/bloc/connectivity_bloc.dart/connectivity_bloc.dart';
import 'package:khyate_tailor_app/core/bloc/language_bloc/language_bloc.dart';
import 'package:khyate_tailor_app/core/bloc/location_bloc/location_bloc.dart';
import 'package:khyate_tailor_app/core/bloc/theme_bloc/theme_bloc.dart';
import 'package:khyate_tailor_app/core/bloc/theme_bloc/theme_state.dart';
import 'package:khyate_tailor_app/core/services/navigator_services/navigator_routes.dart';
import 'package:khyate_tailor_app/core/services/navigator_services/navigator_service.dart';
import 'package:khyate_tailor_app/core/services/storage_services/storage_service.dart';
import 'package:khyate_tailor_app/main.dart';
import 'package:khyate_tailor_app/utils/get_it.dart';

class App extends StatelessWidget {
  final String seletedLagusge;
  const App({super.key, required this.seletedLagusge});
  // final WebSocketService webSocketService;

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();

    return ScreenUtilInit(
      designSize: const Size(371, 812),
      builder: (context, child) {
        return MultiBlocProvider(
            providers: [
              BlocProvider<ConnectivityBloc>(
                create: (context) => locator<ConnectivityBloc>()..add(InitializeConnectivity()),
              ),
              // BlocProvider<ChatBloc>(
              //   create: (context) =>
              //       ChatBloc(webSocketService)..add(ConnectWebSocket()),
              // ),
              BlocProvider(
                create: (_) => LanguageBloc(storageService)..add(InitializeLanguage()),
              ),
              BlocProvider<LocationBloc>(create: (context) => LocationBloc()),
            ],
            child: BlocConsumer<ConnectivityBloc, ConnectivityState>(
              listener: (context, connectivityState) {},
              builder: (context, connectivityState) {
                return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
                  final isDark = themeState.themeMode == ThemeMode.dark;
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Stack(
                      children: [
                        MaterialApp(
                          color: Colors.white,
                          debugShowCheckedModeBanner: false,
                          title: 'Mr. Groomer',
                          // theme: getLightTheme(),
                          // darkTheme: getDarkTheme(),
                          themeMode: themeState.themeMode, // ✅ now this is valid
                          home: SplashScreen(selectedLanguage: seletedLagusge),
                          onGenerateRoute: generateRoutes,
                          navigatorKey: locator<NavigatorService>().rootNavigatorKey,
                        ),
                        if (connectivityState is ConnectivityFailure) const NoInternetDialog(),
                      ],
                    ),
                  );
                });
              },
            ));
      },
    );
  }
}
