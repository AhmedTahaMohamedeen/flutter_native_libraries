LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := simple_math
LOCAL_SRC_FILES := simple_math.c

include $(BUILD_SHARED_LIBRARY)
