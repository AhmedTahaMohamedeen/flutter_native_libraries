#include <stdint.h>

// Export symbol for iOS DynamicLibrary.process()
__attribute__((visibility("default"))) int32_t add(int32_t a, int32_t b) {
    return a + b;
}