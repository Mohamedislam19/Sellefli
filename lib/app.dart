import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/core/widgets/rating_widget.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/features/Booking/booking_detail_page.dart';
import 'package:sellefli/src/features/auth/auth_screen.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
import 'package:sellefli/src/features/auth/logic/auth_state.dart';
import 'package:sellefli/src/features/home/marketplace_home_page.dart';
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
import 'src/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: MaterialApp(
          title: 'Sellefli',
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: const AuthWrapper(),
          routes: {
            '/landing': (context) => const LandingPage(),
            '/map-picker': (context) => const MapPickerPage(),
            '/settings': (context) => SettingsHelpPage(),
            '/create-item': (context) => const CreateItemPage(),
            '/edit-item': (context) => const EditItemPage(itemId: '5fcded9a-298e-4c46-962a-f00c1bafa70b'),
            '/auth': (context) => const AuthScreen(),
            '/request-order': (context) => const RequestsOrdersPage(),
            '/booking-details': (context) => const BookingDetailPage(),
            '/item-details': (context) => const ItemDetailsPage(),
            '/profile-page': (context) => const ProfilePage(),
            '/edit-profile': (context) => const EditProfilePage(),
            '/listings': (context) => const MyListingsPage(),
            '/home': (context) => const MarketplaceHomePage(),
            '/rating': (context) => RatingWidget(),
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
          return const MarketplaceHomePage();
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
