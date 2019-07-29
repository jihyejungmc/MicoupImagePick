
package com.missycoupons;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Environment;
import android.os.Parcelable;
import android.util.Log;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;
import com.missycoupons.fishbun.FishBun;
import com.missycoupons.fishbun.define.Define;
import com.missycoupons.fishbun.ui.upload.UploadActivity;
import com.missycoupons.fishbun.util.CameraUtil;
import com.missycoupons.fishbun.util.SingleMediaScanner;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

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

    private String boardId;
    private String postNo;
    private String uploadUrl;
    private String cookie;

    public RNMicoupImagePickerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.cameraUtil = new CameraUtil();
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

    private void openImagePicker() {
        this.boardId = this.cameraOptions.getString("boardId");
        this.postNo = this.cameraOptions.getString("documentNo");
        this.uploadUrl = this.cameraOptions.getString("imageUploadURL");
        this.cookie = this.cameraOptions.getString("cookie");
        int imageCount = this.cameraOptions.getInt("imageCount");
        int spanCount = this.cameraOptions.getInt("spanCount");
        boolean enableCamera = this.cameraOptions.getBoolean("enableCamera");
        this.reactContext.addActivityEventListener(mActivityEventListener);
        Activity currentActivity = getCurrentActivity();
        FishBun.with(currentActivity)
                .setPickerCount(imageCount)
                .setPickerSpanCount(spanCount)
                .setActionBarColor(Color.parseColor("#EFEFEF"), Color.parseColor("#000000"))
                .setActionBarTitleColor(Color.parseColor("#333333"))
                .textOnImagesSelectionLimitReached("최대 20장까지 입력가능합니다.")
                .textOnNothingSelected("사진을 선택해주세요")
                .setAlbumSpanCount(1, 1)
                .setButtonInAlbumActivity(true)
                .setCamera(enableCamera)
                .setReachLimitAutomaticClose(false)
                .setAllViewTitle("전체")
                .setActionBarTitle("사진앨범")
                .startAlbum();
    }

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {
        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode, final Intent data) {
            if (requestCode == Define.ALBUM_REQUEST_CODE && resultCode == RESULT_OK) { // FishBun 으로부터 결과를 받아온 경우 ( Fishbun 선택 후 이미지 편집기로 편집한 경우도 포함 )
                ArrayList<Uri> mPath = data.getParcelableArrayListExtra(Define.INTENT_PATH); // 선택된 이미지들 경로를 받아옴
                if (mPath == null || mPath.size() == 0) return;
                invokeSuccessWithResult(mPath);
            }
            if(requestCode == Define.UPLOAD_IMAGES_REQUEST_CODE && resultCode == RESULT_OK) {
                ArrayList<String> uploadResult = data.getStringArrayListExtra(Define.INTENT_UPLOAD);
                onCompleteUpload(uploadResult);
            }
            if (requestCode == REQUEST_CAMERA) { // 카메라로부터 이미지 결과를 받아온 경우
                // API 24+ 대응 코드로 변경됨
                if (resultCode == RESULT_OK) { // 카메라로부터의 결과 코드가 OK인경우, 이미지를 가져옴
                    File savedFile = new File(cameraUtil.getSavePath()); // 이미지 파일 가져오기
                    new SingleMediaScanner(activity, savedFile);
                    ArrayList<Uri> mPath = new ArrayList<>();
                    mPath.add(Uri.fromFile(savedFile));
                    invokeSuccessWithResult(mPath);
                } else { // 카메라로부터의 결과 코드가 OK가 아니면, 이미지를 저장하려던 경로의 파일을 제거
                    new File(cameraUtil.getSavePath()).delete();
                }
            }

        }
    };

    private void invokeSuccessWithResult(List<Uri> imageUriList) {
        Log.d(TAG, String.format("invokeSuccessWithResult imageUriList : %s", imageUriList.toString()));
        Intent i = new Intent(getCurrentActivity(), UploadActivity.class);
        i.putExtra("boardId", boardId);
        i.putExtra("postNo", postNo);
        i.putExtra("uploadUrl", uploadUrl);
        i.putExtra("cookie", cookie);
        i.putParcelableArrayListExtra("imageUriList", new ArrayList<Parcelable>(imageUriList));
        getCurrentActivity().startActivityForResult(i, Define.UPLOAD_IMAGES_REQUEST_CODE);
    }

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

    private void onCompleteUpload(List<String> uploadResult) {
        WritableArray imageList = new WritableNativeArray();
        for (String result : uploadResult) {
            if (result != null) {
                imageList.pushString(result);
            }
        }
        if (this.mPickerCallback != null) {
            this.mPickerCallback.invoke(null, imageList);
            this.mPickerCallback = null;
        } else if (this.mPickerPromise != null) {
            this.mPickerPromise.resolve(imageList);
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
