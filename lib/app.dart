import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:sellefli/src/core/widgets/rating_widget.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'package:sellefli/src/data/repositories/rating_repository.dart';
import 'package:sellefli/src/data/repositories/profile_repository.dart';
import 'package:sellefli/src/data/repositories/booking_repository.dart';
import 'package:sellefli/src/data/local/local_item_repository.dart';
import 'package:sellefli/src/features/Booking/booking_detail_page.dart';
import 'package:sellefli/src/features/auth/auth_page.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:sellefli/src/features/home/home_page.dart';
import 'package:sellefli/src/features/item/edit_item.dart';
import 'package:sellefli/src/features/item/item_details.dart';
import 'package:sellefli/src/features/landing/landing_page.dart';
import 'package:sellefli/src/features/listing/my_listings.dart';
import 'package:sellefli/src/features/map/map_picker.dart';
import 'package:sellefli/src/features/orders/requests_orders_page.dart';
import 'package:sellefli/src/features/profile/profile.dart';
import 'package:sellefli/src/features/settings/settings_page.dart';
import 'package:sellefli/src/features/profile/edit_profile_page.dart';
import 'package:sellefli/src/features/item/create_item_page.dart';
import 'package:sellefli/src/core/widgets/protected_route.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/l10n/language_cubit.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'src/features/profile/logic/profile_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(
          create: (context) => ItemRepository(Supabase.instance.client),
        ),
        RepositoryProvider(
          create: (context) => RatingRepository(Supabase.instance.client),
        ),
        RepositoryProvider(
          create: (context) =>
              ProfileRepository(supabase: Supabase.instance.client),
        ),
        RepositoryProvider(
          create: (context) => BookingRepository(Supabase.instance.client),
        ),
        RepositoryProvider(create: (context) => LocalItemRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              profileRepository: context.read<ProfileRepository>(),
              bookingRepository: context.read<BookingRepository>(),
            ),
          ),
          BlocProvider(create: (context) => LanguageCubit()),
        ],
        child: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, langState) {
            return MaterialApp(
              title: 'Sellefli',
              debugShowCheckedModeBanner: false,
              theme: appTheme,
              locale: langState.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('fr'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const AuthWrapper(),
              routes: {
                '/landing': (context) => const LandingPage(),
                '/map-picker': (context) =>
                    const ProtectedRoute(child: MapPickerPage()),
                '/settings': (context) =>
                    ProtectedRoute(child: SettingsHelpPage()),
                '/create-item': (context) =>
                    const ProtectedRoute(child: CreateItemPage()),
                '/edit-item': (context) =>
                    const ProtectedRoute(child: EditItemPage()),
                '/auth': (context) => const AuthPage(),
                '/request-order': (context) =>
                    const ProtectedRoute(child: RequestsOrdersPage()),
                '/booking-details': (context) =>
                    const ProtectedRoute(child: BookingDetailPage()),
                '/item-details': (context) =>
                    const ProtectedRoute(child: ItemDetailsPage()),
                '/profile-page': (context) =>
                    const ProtectedRoute(child: ProfilePage()),
                '/edit-profile': (context) =>
                    const ProtectedRoute(child: EditProfilePage()),
                '/listings': (context) =>
                    const ProtectedRoute(child: MyListingsPage()),
                '/home': (context) => const ProtectedRoute(child: HomePage()),
                '/rating': (context) => ProtectedRoute(child: RatingWidget()),
              },
            );
          },
        ),
      ),
    );
  }
}

// Auth wrapper to handle auto-login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // User is authenticated, go to home
          return const HomePage();
        } else if (state is AuthUnauthenticated) {
          // User is not authenticated, show landing page
          return const LandingPage();
        } else {
          // Loading/Initial state - show splash screen
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}


