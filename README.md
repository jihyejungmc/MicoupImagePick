
# Micoup Image Picker 

## Getting started

`$ npm install react-native-micoup-image-picker --save`

### Mostly automatic installation

`$ react-native link react-native-micoup-image-picker`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-micoup-image-picker` and add `RNMicoupImagePicker.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNMicoupImagePicker.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNMicoupImagePickerPackage;` to the imports at the top of the file
  - Add `new RNMicoupImagePickerPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-micoup-image-picker'
  	project(':react-native-micoup-image-picker').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-micoup-image-picker/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-micoup-image-picker')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNMicoupImagePicker.sln` in `node_modules/react-native-micoup-image-picker/windows/RNMicoupImagePicker.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Micoup.Image.Picker.RNMicoupImagePicker;` to the usings at the top of the file
  - Add `new RNMicoupImagePickerPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNMicoupImagePicker from 'react-native-micoup-image-picker';

// TODO: What to do with the module?
RNMicoupImagePicker;
```
