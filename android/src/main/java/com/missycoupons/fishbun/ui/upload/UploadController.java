package com.missycoupons.fishbun.ui.upload;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import com.google.gson.Gson;
import com.missycoupons.R;
import com.missycoupons.fishbun.define.Define;
import com.missycoupons.fishbun.network.LoadingView;
import com.missycoupons.fishbun.network.UploadTask;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UploadController implements LoadingView {

    private static final String TAG = "UploadController";
    private int UPLOAD_QUEUE_COUNT = 0, UPLOAD_COMPLETE_COUNT = 0; // UploadTask가 모두 완료되어야만 정상 finish 가능하게 함
    private Map<String, String> progressMap;
    private Context context;
    private View imageUploadingView; // 이미지 업로드 시 상단에 '이미지 업로드중(n/n)'을 띄우는 TextView
    private TextView imageUploadingText; // 이미지 업로드 시 상단에 '이미지 업로드중(n/n)'을 띄우는 TextView
    private List<Uri> imageUriList;
    private String boardId;
    private String postNo;
    private String uploadUrl;
    private String cookie;
    private Listener listener;

    public static class Builder {
        private Context context;
        private View imageUploadingView;
        private TextView imageUploadingText;
        private List<Uri> imageUriList;
        private String boardId;
        private String postNo;
        private String uploadUrl;
        private String cookie;

        public Builder(Context context) {
            this.context = context;
        }

        public Builder progressView(View imageUploadingView) {
            this.imageUploadingView = imageUploadingView;
            return this;
        }

        public Builder progressText(TextView imageUploadingText) {
            this.imageUploadingText = imageUploadingText;
            return this;
        }

        public Builder imageUriList(List<Uri> imageUriList) {
            this.imageUriList = imageUriList;
            return this;
        }

        public Builder boardId(String boardId) {
            this.boardId = boardId;
            return this;
        }

        public Builder postNo(String postNo) {
            this.postNo = postNo;
            return this;
        }

        public Builder uploadUrl(String uploadUrl) {
            this.uploadUrl = uploadUrl;
            return this;
        }

        public Builder cookie(String cookie) {
            this.cookie = cookie;
            return this;
        }

        public UploadController build() {
            UploadController controller = new UploadController();
            controller.progressMap = new HashMap<>();
            controller.context = context;
            controller.imageUploadingView = this.imageUploadingView;
            controller.imageUploadingText = this.imageUploadingText;
            controller.imageUriList = this.imageUriList;
            controller.boardId = this.boardId;
            controller.postNo = this.postNo;
            controller.uploadUrl = this.uploadUrl;
            controller.cookie = this.cookie;
            return controller;
        }
    }

    public interface Listener {
        void onError(String message);

        void onSuccess(Intent intent);
    }

    public void start(Listener listener) {
        this.listener = listener;
        uploadPhotos();
    }

    private void uploadPhotos() {
        progressMap.clear();
        UPLOAD_QUEUE_COUNT = imageUriList.size();
        for (Uri uri : imageUriList) {
            UploadTask uploadTask = new UploadTask(context, this,
                    this.boardId, this.postNo, this.uploadUrl, this.cookie,
                    uri.toString(), this.getPath(uri));
            uploadTask.execute();
        }
    }

    private String getPath(Uri uri) {
        Cursor cursor = null;
        try {
            String[] proj = {MediaStore.Images.Media.DATA};
            cursor = context.getContentResolver().query(uri, proj, null, null, null);
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
        if (imageUploadingView == null) return;
        imageUploadingView.setVisibility(View.VISIBLE);
        imageUploadingText.setText(this.getUploadingStatus());
    }

    private void hideUploadView() {
        if (imageUploadingView == null) return;
        imageUploadingText.setText(context.getString(R.string.write_message_upload_complete));
        UPLOAD_QUEUE_COUNT = 0;
        UPLOAD_COMPLETE_COUNT = 0;
        imageUploadingView.setVisibility(View.INVISIBLE);
    }

    private boolean isUploading() {
        return UPLOAD_QUEUE_COUNT != UPLOAD_COMPLETE_COUNT;
    }

    private String getUploadingStatus() {
        return context.getResources().getString(R.string.write_message_image_uploading) +
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
            try {
                Intent intent = new Intent();
                intent.putExtra(Define.INTENT_UPLOAD, combineResults());
                listener.onSuccess(intent);
            } catch (Exception e) {
                listener.onError(e.getMessage());
            }
        } else {
            this.showUploadView();
        }
    }

    private Bundle combineResults() {
        ArrayList<String> responses = new ArrayList<String>(this.progressMap.values());
        Bundle bundle = new Bundle();
        ArrayList<String> fileArray = new ArrayList<>();
        boolean allSuccess = true;
        boolean allResult = true;
        String allMessage = "";
        String curMessage = "업로드되었습니다.";
        int successCount = 0;
        Gson gson = new Gson();
        for (String resStr : responses) {
            Response response = gson.fromJson(resStr, Response.class);
            successCount += response.success ? 1 : 0;
            allSuccess = allSuccess && response.success;
            allResult = allResult && response.result;
            allMessage = response.success ? allMessage : response.message;
            fileArray.add(gson.toJson(response.files.get(0)));
        }
        try {
            bundle.putBoolean("isSuccess", allSuccess);
            bundle.putBoolean("result", allResult);
            bundle.putString("message", allMessage.isEmpty() ? curMessage : allMessage);
            bundle.putInt("successCount", successCount);
            bundle.putStringArrayList("fileArray", fileArray);
            return bundle;
        } catch (Exception e) {
            throw new RuntimeException("응답 값 조합에 문제 발생");
        }
    }

    class Response {
        private boolean success;
        private boolean result;
        private String message;
        private List<File> files;
    }

    class File {
        private String name;
        private boolean success;
        private String msg;
        private int image_id;
        private String serial;
        private int width;
        private int height;
        private String url;
        private Boolean updated;
    }
}
