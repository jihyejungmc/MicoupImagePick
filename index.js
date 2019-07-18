import { NativeModules, Platform } from 'react-native';

const { RNMicoupImagePicker } = NativeModules;

const defaultOptions = {
  documentNo: -1,
  cookie: undefined,
  userAgent: Platform.OS === 'ios' ? 'MissyCouponsTest/1.0.6(197.1)' : 'MissyCoupons/1.0.4(3)',
  imageCount: 1,
  spanCount: 3,
  enableCamera: true
};

export default {
  showImagePickerWithOptions(optionArgs) {
    const options = {
      ...defaultOptions,
      ...optionArgs,
    };
    return RNMicoupImagePicker.showImagePickerWithOptions(options);
  }
};
