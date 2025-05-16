import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:woocommerce_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:woocommerce_app/features/auth/presentation/screens/home_screen.dart';
import 'package:woocommerce_app/features/auth/presentation/screens/login_screen.dart';
import 'package:woocommerce_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:woocommerce_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:woocommerce_app/injection_container.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    debugPrint('Loading environment variables...');
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');
    
    // Verify required environment variables
    final requiredVars = [
      'WOOCOMMERCE_SITE_URL',
      'WOOCOMMERCE_CONSUMER_KEY',
      'WOOCOMMERCE_CONSUMER_SECRET',
      'JWT_SECRET',
    ];
    
    for (var varName in requiredVars) {
      final value = dotenv.get(varName);
      if (value.isEmpty) {
        debugPrint('WARNING: $varName is empty');
      } else {
        debugPrint('$varName: ${varName.contains('SECRET') ? '***' : value}');
      }
    }
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    // Try with package path
    try {
      await dotenv.load(fileName: "assets/.env");
      debugPrint('Environment variables loaded from assets');
    } catch (e) {
      debugPrint('Error loading .env from assets: $e');
      rethrow;
    }
  }
  
  // Initialize dependencies
  try {
    debugPrint('Initializing dependencies...');
    await init();
    debugPrint('Dependencies initialized successfully');
  } catch (e) {
    debugPrint('Error initializing dependencies: $e');
    rethrow;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize authentication state
      final authProvider = getIt<AuthProvider>();
      await authProvider.checkAuth();
    } catch (e) {
      // Handle initialization error
      debugPrint('Error initializing app: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: getIt<AuthProvider>(),
        ),
      ],
      child: MaterialApp(
        title: 'WooCommerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        routes: {
          '/': (context) => !_isInitialized
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isLoading) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return authProvider.isAuthenticated
                        ? const HomeScreen()
                        : const LoginScreen();
                  },
                ),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
