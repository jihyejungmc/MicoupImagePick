package com.missycoupons.fishbun.ui.upload;

import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcelable;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import com.missycoupons.R;
import com.missycoupons.fishbun.define.Define;
import com.missycoupons.fishbun.network.LoadingView;
import com.missycoupons.fishbun.network.UploadTask;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UploadActivity extends AppCompatActivity implements LoadingView {

    private static final String TAG = "UploadActivity";
    private int UPLOAD_QUEUE_COUNT = 0, UPLOAD_COMPLETE_COUNT = 0; // UploadTask가 모두 완료되어야만 정상 finish 가능하게 함
    private View mImageUploadingView; // 이미지 업로드 시 상단에 '이미지 업로드중(n/n)'을 띄우는 TextView
    private TextView mImageUploadingText; // 이미지 업로드 시 상단에 '이미지 업로드중(n/n)'을 띄우는 TextView
    private Map<String, String> progressMap;

    private List<Uri> imageUriList;
    private String boardId;
    private String postNo;
    private String uploadUrl;
    private String cookie;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo_upload);
        this.progressMap = new HashMap<>();
        mImageUploadingView = (View) findViewById(R.id.UploadingView);
        mImageUploadingText = (TextView) findViewById(R.id.UploadingText);
        setData(getIntent());
        uploadPhotos();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        try {
            outState.putString("boardId", boardId);
            outState.putString("postNo", postNo);
            outState.putString("uploadUrl", uploadUrl);
            outState.putString("cookie", cookie);
            outState.putParcelableArrayList("imageUriList", new ArrayList<Parcelable>(imageUriList));
        } catch (Exception e) {
            Log.d(TAG, e.toString());
        }

        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle outState) {
        super.onRestoreInstanceState(outState);
        try {
            boardId = outState.getString("boardId");
            postNo = outState.getString("postNo");
            uploadUrl = outState.getString("uploadUrl");
            cookie = outState.getString("cookie");
            imageUriList = outState.getParcelableArrayList("imageUriList");
        } catch (Exception e) {
            Log.d(TAG, e.toString());
        }
    }

    private void setData(Intent intent) {
        boardId = intent.getStringExtra("boardId");
        postNo = intent.getStringExtra("postNo");
        uploadUrl = intent.getStringExtra("uploadUrl");
        cookie = intent.getStringExtra("cookie");
        imageUriList = intent.getParcelableArrayListExtra("imageUriList");
    }

    private void uploadPhotos() {
        progressMap.clear();
        UPLOAD_QUEUE_COUNT = imageUriList.size();
        for (Uri uri : imageUriList) {
            UploadTask uploadTask = new UploadTask(this, this,
                    this.boardId, this.postNo, this.uploadUrl, this.cookie,
                    uri.toString(), this.getPath(uri));
            uploadTask.execute();
        }
    }

    private String getPath(Uri uri) {
        Cursor cursor = null;
        try {
            String[] proj = {MediaStore.Images.Media.DATA};
            cursor = this.getContentResolver().query(uri, proj, null, null, null);
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            cursor.moveToFirst();
            String result = cursor.getString(column_index);
            cursor.close();
            return result;
        } catch (Exception e) {
            return uri.getPath();
        }
    }

    private void showUploadView() {
        if (mImageUploadingView == null) return;
        mImageUploadingView.setVisibility(View.VISIBLE);
        mImageUploadingText.setText(this.getUploadingStatus());
    }

    private void hideUploadView() {
        if (mImageUploadingView == null) return;
        mImageUploadingText.setText(getString(R.string.write_message_upload_complete));
        UPLOAD_QUEUE_COUNT = 0;
        UPLOAD_COMPLETE_COUNT = 0;
        mImageUploadingView.setVisibility(View.INVISIBLE);
    }

    private boolean isUploading() {
        return UPLOAD_QUEUE_COUNT != UPLOAD_COMPLETE_COUNT;
    }

    private String getUploadingStatus() {
        return getResources().getString(R.string.write_message_image_uploading) +
                " (" +
                String.valueOf(UPLOAD_COMPLETE_COUNT + 1) +
                "/" +
                String.valueOf(UPLOAD_QUEUE_COUNT) +
                ")";
    }

    @Override
    public void onUploadStart(String id) {
        Log.d(TAG, String.format("onUploadStart %s", id));
        progressMap.put(id, null);
        this.showUploadView();
    }

    @Override
    public void onUploadFinish(String id, String result) {
        Log.d(TAG, String.format("onUploadFinish %s %s", id, result));
        boolean allUploaded = true;
        progressMap.put(id, result);
        int completeCount = 0;
        for (String uploaded : this.progressMap.values()) {
            allUploaded = allUploaded && uploaded != null;
            completeCount += uploaded != null ? 1 : 0;
        }
        UPLOAD_COMPLETE_COUNT = completeCount;
        if (allUploaded) {
            this.hideUploadView();
            this.finishUpload();
        } else {
            this.showUploadView();
        }
    }

    private void finishUpload() {
        Intent intent = new Intent();
        intent.putStringArrayListExtra(Define.INTENT_UPLOAD, new ArrayList<String>(this.progressMap.values()));
        setResult(RESULT_OK, intent);
        finish();
    }
}
