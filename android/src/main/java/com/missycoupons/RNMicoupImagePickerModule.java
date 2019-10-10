
package com.missycoupons;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Environment;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.missycoupons.fishbun.FishBun;
import com.missycoupons.fishbun.define.Define;
import com.missycoupons.fishbun.util.CameraUtil;

import java.io.File;

import static android.app.Activity.RESULT_OK;

public class RNMicoupImagePickerModule extends ReactContextBaseJavaModule {

    public final static int REQUEST_CAMERA = Define.TAKE_A_PICK_REQUEST_CODE, REQUEST_CAMERA_PERMISSION = 2222, REQUEST_ALBUM_PERMISSION = 2223;
    private static final String TAG = "RNMicoupImagePicker";
    private static String SELECT_IMAGE_FAILED_CODE = "0";
    private final ReactApplicationContext reactContext;
    private ReadableMap cameraOptions;
    private Callback mPickerCallback;
    private Promise mPickerPromise;
    private CameraUtil cameraUtil;

    public RNMicoupImagePickerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.cameraUtil = CameraUtil.getInstance();
    }

    @Override
    public String getName() {
        return "RNMicoupImagePicker";
    }

    @ReactMethod
    public void showImagePickerWithOptions(ReadableMap options, Promise promise) {
        this.cameraOptions = options;
        this.mPickerPromise = promise;
        this.mPickerCallback = null;
        createDirectory("micoup", true);
        this.openImagePicker();
    }

    @ReactMethod
    public void openCameraWithOptions(ReadableMap options, Promise promise) {
        this.cameraOptions = options;
        this.mPickerPromise = promise;
        this.mPickerCallback = null;
        createDirectory("micoup", true);
        this.takePictureFromCamera();
    }

    private void openImagePicker() {
        String boardId = this.cameraOptions.getString("boardId");
        String postNo = this.cameraOptions.getString("documentNo");
        String uploadUrl = this.cameraOptions.getString("imageUploadURL");
        String cookie = this.cameraOptions.getString("cookie");
        int imageCount = this.cameraOptions.getInt("imageCount");
        int spanCount = this.cameraOptions.getInt("spanCount");
        boolean enableCamera = this.cameraOptions.getBoolean("enableCamera");
        this.reactContext.addActivityEventListener(mActivityEventListener);
        String limitMsg = String.format("최대 %d장까지 입력가능합니다.", imageCount);
        Activity currentActivity = getCurrentActivity();
        FishBun.with(currentActivity)
                .setBoardId(boardId)
                .setPostNo(postNo)
                .setUploadUrl(uploadUrl)
                .setCookie(cookie)
                .setPickerCount(imageCount)
                .setPickerSpanCount(spanCount)
                .setActionBarColor(Color.parseColor("#EFEFEF"), Color.parseColor("#000000"))
                .setActionBarTitleColor(Color.parseColor("#333333"))
                .textOnImagesSelectionLimitReached(limitMsg)
                .textOnNothingSelected("사진을 선택해주세요")
                .setAlbumSpanCount(1, 1)
                .setButtonInAlbumActivity(true)
                .setCamera(enableCamera)
                .setReachLimitAutomaticClose(false)
                .setAllViewTitle("전체")
                .setActionBarTitle("사진앨범")
                .startAlbum();
    }

    private void takePictureFromCamera() {
        String boardId = this.cameraOptions.getString("boardId");
        String postNo = this.cameraOptions.getString("documentNo");
        String uploadUrl = this.cameraOptions.getString("imageUploadURL");
        String cookie = this.cameraOptions.getString("cookie");
        this.reactContext.addActivityEventListener(mActivityEventListener);
        Activity currentActivity = getCurrentActivity();
        String saveDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DCIM + "/Camera").getAbsolutePath();
        FishBun.with(currentActivity)
                .setBoardId(boardId)
                .setPostNo(postNo)
                .setUploadUrl(uploadUrl)
                .setCookie(cookie)
                .setSaveDir(saveDir)
                .setActionBarColor(Color.parseColor("#EFEFEF"), Color.parseColor("#000000"))
                .setActionBarTitleColor(Color.parseColor("#333333"))
                .openCamera();
    }

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, final Intent data) {
//            Log.d("onActivityResult", String.format("requestCode : %d", requestCode));
            // FishBun 으로부터 결과를 받아온 경우
            if (resultCode == RESULT_OK) {
                Bundle results = data.getBundleExtra(Define.INTENT_UPLOAD);
                invokeSuccessWithResult(results);
            } else {
                invokeError(resultCode);
            }
        }
    };

    private void createDirectory(String path, boolean noMedia) {
        File folder = new File(Environment.getExternalStorageDirectory(), path);
        if (!folder.exists()) {
            folder.mkdirs();
        }
        if (!noMedia) return;
        try {
            File nomedia = new File(folder.getPath(), ".nomedia");
            nomedia.createNewFile();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void invokeSuccessWithResult(Bundle uploadResult) {
        WritableMap ret = new WritableNativeMap();
        WritableArray fileArray = new WritableNativeArray();
        ret.putBoolean("isSuccess", uploadResult.getBoolean("isSuccess"));
        ret.putBoolean("result", uploadResult.getBoolean("result"));
        ret.putString("message", uploadResult.getString("message"));
        ret.putInt("successCount", uploadResult.getInt("successCount"));
        for (String file : uploadResult.getStringArrayList("fileArray")) {
            fileArray.pushString(file);
        }
        ret.putArray("fileArray", fileArray);
        if (this.mPickerCallback != null) {
            this.mPickerCallback.invoke(null, ret);
            this.mPickerCallback = null;
        } else if (this.mPickerPromise != null) {
            this.mPickerPromise.resolve(ret);
        }
    }

    private void invokeError(int resultCode) {
        String message = "취소";
        if (resultCode != 0) {
            message = String.valueOf(resultCode);
        }
        if (this.mPickerCallback != null) {
            this.mPickerCallback.invoke(message);
            this.mPickerCallback = null;
        } else if (this.mPickerPromise != null) {
            this.mPickerPromise.reject(SELECT_IMAGE_FAILED_CODE, message);
        }
    }
}
