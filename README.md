
# Native C Library Example for Flutter (Android & iOS)

## 📚 Overview
This project demonstrates how to:
- Compile a simple C library into:
  - `.so` for **Android**
  - `.a` for **iOS**
- Integrate the compiled libraries into a Flutter project via **FFI**.

---

# 🛠 Step 1: Create the C Code (`simple_math.c`)

```c
#include <stdint.h>

// Exported symbol for use in FFI
__attribute__((visibility("default"))) int32_t add(int32_t a, int32_t b) {
    return a + b;
}
```

✅ Notes:
- `__attribute__((visibility("default")))` is required to make the symbol visible for dynamic linking (especially on iOS).
- `int32_t` ensures 32-bit integers for cross-platform consistency.

---

# 🛠 Step 2: Build for Android (generate `.so`)

## 2.1 Create `Android.mk`

```makefile
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := simple_math
LOCAL_SRC_FILES := simple_math.c

include $(BUILD_SHARED_LIBRARY)
```

---

## 2.2 Create `Application.mk`

```makefile
APP_ABI := all
APP_PLATFORM := android-21
```

---

## 2.3 Build `.so` using NDK

```bash
ndk-build
```

✅ You will get `.so` files inside `libs/{abi}/libsimple_math.so`.

---

# 🛠 Step 3: Build for iOS (generate `.a`)

## 3.1 Build object files (`.o`)

```bash
clang -c simple_math.c -o simple_math_arm64.o -target arm64-apple-ios -isysroot $(xcrun --sdk iphoneos --show-sdk-path)
clang -c simple_math.c -o simple_math_sim_x86_64.o -target x86_64-apple-ios-simulator -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path)
```

---

## 3.2 Create static libraries

```bash
libtool -static -o libsimple_math_arm64.a simple_math_arm64.o
libtool -static -o libsimple_math_sim_x86_64.a simple_math_sim_x86_64.o
```

---

## 3.3 Create a universal static library

```bash
lipo -create -output libsimple_math_universal.a libsimple_math_arm64.a libsimple_math_sim_x86_64.a
```

✅ Now you have `libsimple_math_universal.a` ready for iOS (both devices and simulators).

---

# 🛠 Step 4: Setup Flutter Project

## 4.1 Add FFI Dependency

In your `pubspec.yaml`:

```yaml
dependencies:
  ffi: ^2.0.2
```

Then run:

```bash
flutter pub get
```

---

## 4.2 Create FFI Binding in Flutter

`lib/simple_math_bindings.dart`

```dart
import 'dart:ffi';
import 'dart:io' show Platform;

typedef NativeAddFunc = Int32 Function(Int32 a, Int32 b);
typedef DartAddFunc = int Function(int a, int b);

class SimpleMath {
  static final DynamicLibrary _lib = () {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libsimple_math.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }();

  static final DartAddFunc add = _lib
      .lookup<NativeFunction<NativeAddFunc>>('add')
      .asFunction();
}
```

---

# 🛠 Step 5: Integrate Native Libraries into Flutter Platforms

## 5.1 For Android

- Copy the generated `.so` files into:

```
android/app/src/main/jniLibs/{abi}/libsimple_math.so
```

Example:

```
android/app/src/main/jniLibs/arm64-v8a/libsimple_math.so
```

---

## 5.2 For iOS

- Create a folder inside iOS:

```
ios/Vendor/simple_math/
```

- Place `libsimple_math_universal.a` inside it.

- Open `ios/Runner.xcworkspace` with Xcode.

- In Xcode:
  - Go to Runner ➔ TARGETS ➔ Runner ➔ Build Phases ➔ Link Binary With Libraries ➔ Add `libsimple_math_universal.a`.
  - Go to Build Settings ➔ Library Search Paths ➔ Add:
    ```
    $(PROJECT_DIR)/Vendor/simple_math
    ```
  - Add to Other Linker Flags:
    ```
    -all_load
    ```

---

## 5.3 Create Swift Wrapper

`ios/Runner/SimpleMathWrapper.swift`

```swift
import Foundation

@_silgen_name("add")
func add(_ a: Int32, _ b: Int32) -> Int32

@_cdecl("dummy_reference_to_add")
public func dummy_reference_to_add() -> Int32 {
    return add(1, 1);
}
```

✅ This dummy call forces Xcode's linker to include the `add` symbol inside the final app.

---

# 🛠 Step 6: Run your Flutter App

## 6.1 Example usage

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'simple_math_bindings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final result = SimpleMath.add(5, 7);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Math FFI Example'),
        ),
        body: Center(
          child: Text('Result of 5 + 7 = $result'),
        ),
      ),
    );
  }
}
```

✅ Now run:

```bash
flutter run
```

✅ You should see:

```
Result of 5 + 7 = 12
```

---

# 📚 References

- [Flutter FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [Android NDK Official Docs](https://developer.android.com/ndk)
- [Apple Developer - Static Libraries](https://developer.apple.com/documentation/xcode/using-static-libraries-in-your-app)

---

# ✅ Conclusion

This guide showed you:
- How to create a simple C function.
- How to generate `.so` for Android using NDK.
- How to generate `.a` for iOS using clang and lipo.
- How to link native libraries with Flutter.
- How to use FFI in a clean and cross-platform way.
