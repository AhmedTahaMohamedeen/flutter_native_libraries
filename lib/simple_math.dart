import 'dart:ffi';
import 'dart:io' show Platform;

typedef NativeAddFunc = Int32 Function(Int32 a, Int32 b);
typedef DartAddFunc = int Function(int a, int b);

class SimpleMath {
  static final DynamicLibrary _lib = () {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libsimple_math.so');
    } else if(Platform.isIOS){
      return DynamicLibrary.process();
    }


    else {
      throw UnsupportedError('This platform is not supported.');
    }
  }();

  static final DartAddFunc add = _lib
      .lookup<NativeFunction<NativeAddFunc>>('add')
      .asFunction();
}
