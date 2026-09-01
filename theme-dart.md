# Theme Builder

## Builder
`theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme(Brightness brightness) {
  final baseTheme = ThemeData(brightness: brightness, useSystemColors: true);
  return baseTheme.copyWith(
    textTheme: GoogleFonts.googleSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ),
  );
}

ThemeData lightTheme = buildTheme(Brightness.light);
ThemeData darkTheme = buildTheme(Brightness.dark);
```

## Use
```dart
return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: Scaffold(
        body: Center(
          child: Text('Hello World!', style: TextStyle(fontSize: 48)),
        ),
      ),
    );
```
