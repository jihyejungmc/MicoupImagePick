using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Micoup.Image.Picker.RNMicoupImagePicker
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNMicoupImagePickerModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNMicoupImagePickerModule"/>.
        /// </summary>
        internal RNMicoupImagePickerModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNMicoupImagePicker";
            }
        }
    }
}
