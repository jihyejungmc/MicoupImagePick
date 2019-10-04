package com.missycoupons.fishbun.ui.camera;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.missycoupons.R;
import com.missycoupons.fishbun.define.Define;
import com.missycoupons.fishbun.permission.PermissionCheck;
import com.missycoupons.fishbun.ui.upload.UploadController;
import com.missycoupons.fishbun.util.CameraUtil;

import java.io.File;
import java.util.ArrayList;

import static android.widget.Toast.LENGTH_SHORT;

public class CameraActivity extends AppCompatActivity implements UploadController.Listener {
    private String boardId;
    private String postNo;
    private String uploadUrl;
    private String cookie;
    private String saveDir;
    private CameraUtil cameraUtil;

    private View uploadView;
    private TextView uploadText;

    public final static int REQUEST_CAMERA_PERMISSION = 2222;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo_camera);
        uploadView = findViewById(R.id.UploadingView);
        uploadText = findViewById(R.id.UploadingText);

        this.cameraUtil = new CameraUtil();
        Log.d("CameraActivity", "onCreate");
        Intent intent = getIntent();
        boardId = intent.getStringExtra("boardId");
        postNo = intent.getStringExtra("postNo");
        uploadUrl = intent.getStringExtra("uploadUrl");
        cookie = intent.getStringExtra("cookie");
        saveDir = intent.getStringExtra("saveDir");
        if (checkPermissionCamera(REQUEST_CAMERA_PERMISSION)) {
            takePicture();
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        outState.putString("boardId", boardId);
        outState.putString("postNo", postNo);
        outState.putString("uploadUrl", uploadUrl);
        outState.putString("cookie", cookie);
        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle outState) {
        super.onRestoreInstanceState(outState);
        boardId = outState.getString("boardId");
        postNo = outState.getString("postNo");
        uploadUrl = outState.getString("uploadUrl");
        cookie = outState.getString("cookie");
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == Define.TAKE_A_PICK_REQUEST_CODE) { // 카메라 결과를 받은 경우, 댓글 모듈에 전달
            if (resultCode == RESULT_OK) {
                File savedFile = new File(cameraUtil.getSavePath());
                uploadPhoto(savedFile);
            } else {
                new File(cameraUtil.getSavePath()).delete();
                setResult(RESULT_CANCELED);
                finish();
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        Log.d("PermissionsResult", "requestCode : " + requestCode);
        switch (requestCode) {
            case REQUEST_CAMERA_PERMISSION:
                if (grantResults.length > 1 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    takePicture();
                }
                break;
            case Define.PERMISSION_STORAGE:
                if (grantResults.length > 0) {
                    if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                        // permission was granted, yay!
                        takePicture();
                    } else {
                        new PermissionCheck(this).showPermissionDialog();
                        finish();
                    }
                }
                break;
        }
    }

    private void uploadPhoto(File file) {
        ArrayList<Uri> mPath = new ArrayList<>();
        mPath.add(Uri.fromFile(file));
        if (mPath == null || mPath.size() == 0) return;
        new UploadController.Builder(this)
                .progressView(uploadView)
                .progressText(uploadText)
                .boardId(boardId)
                .postNo(postNo)
                .uploadUrl(uploadUrl)
                .cookie(cookie)
                .imageUriList(mPath)
                .build()
                .start(this);
    }

    @Override
    public void onError(String message) {
        Toast.makeText(this, message, LENGTH_SHORT).show();
    }

    @Override
    public void onSuccess(Intent intent) {
        setResult(RESULT_OK, intent);
        finish();
    }

    private void takePicture() {
        if (checkPermission()) {
            cameraUtil.takePicture(this, saveDir);
        }
    }

    boolean checkPermission() {
        PermissionCheck permissionCheck = new PermissionCheck(this);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (permissionCheck.CheckStoragePermission())
                return true;
        } else
            return true;
        return false;
    }

    private boolean checkPermissionCamera(int requestCode) {
        if (Build.VERSION.SDK_INT < 23) return true;
        if (!(ContextCompat.checkSelfPermission(this, android.Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED)
                || !(ContextCompat.checkSelfPermission(this, android.Manifest.permission_group.STORAGE) == PackageManager.PERMISSION_GRANTED)) {
            ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.CAMERA, android.Manifest.permission_group.STORAGE}, requestCode);
            return false;
        } else {
            return true;
        }
    }
}
