package com.missycoupons.fishbun.network;

import android.content.Context;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class UploadTask extends AsyncTask<String, Void, String> {

    private static String TAG = "[UploadTask]";
    private final int MAX_IMAGE_SIZE = 1200, IMAGE_COMPRESS_QUALITY = 100;
    private Context context;
    private LoadingView loadingView;
    private OkHttpClient client;
    private String boardId, postNo, uploadUrl, cookie;
    private String url, fileuri, filepath;
    private int imageWidth, imageHeight;

    private final MediaType MEDIA_TYPE_PNG = MediaType.parse("image/png");
    private final MediaType MEDIA_TYPE_GIF = MediaType.parse("image/gif");

    private MediaType contentType = MEDIA_TYPE_PNG;

    public UploadTask(Context context, LoadingView loadingView,
                      String boardId, String postNo, String uploadUrl, String cookie,
                      String fileuri, String filepath) {
        this.context = context;
        this.loadingView = loadingView;
        this.client = new OkHttpClient();
        this.boardId = boardId;
        this.postNo = postNo;
        this.uploadUrl = uploadUrl;
        this.cookie = cookie;
        this.fileuri = fileuri;
        this.filepath = filepath;
    }

    private static void DebugLog(String str) {
        if (str.length() > 2000) {
            Log.i(TAG, str.substring(0, 2000));
            DebugLog(str.substring(2000));
        } else
            Log.i(TAG, str);
    }

    protected void onPreExecute() {
        super.onPreExecute();
        DebugLog("*UploadTask* onPreExecute : " + fileuri);
        loadingView.onUploadStart(this.fileuri);
    }

    @Override
    protected String doInBackground(String... params) {
        DebugLog("*UploadTask* doInBackground");
        try {
            DebugLog("*UploadTask* doInBackground : Image Compressing : " + fileuri + " / " + filepath);
            String fileoutput = Environment.getExternalStorageDirectory() + "/micoup/";
            if (filepath.contains("/") && filepath.contains("."))
                fileoutput += filepath.substring(filepath.lastIndexOf("/") + 1);
            else fileoutput += "image.png";
            if (fileoutput.contains(".gif")) {
                contentType = MEDIA_TYPE_GIF;
                throw new Exception("GIF FORMAT CANNOT BE SUPPORTED");
            }
            Bitmap bitmap = BitmapUtils.getCorrectlyOrientedImage(context, Uri.parse(fileuri), filepath);
            bitmap = BitmapUtils.resize(bitmap, MAX_IMAGE_SIZE, true);
            imageWidth = bitmap.getWidth();
            imageHeight = bitmap.getHeight();
            FileOutputStream out = new FileOutputStream(fileoutput);
            bitmap.compress(Bitmap.CompressFormat.PNG, IMAGE_COMPRESS_QUALITY, out);
            out.close();
            filepath = fileoutput;
            DebugLog("*UploadTask* doInBackground : Image Compressed : " + filepath);
        } catch (Exception e) {
            DebugLog("*UploadTask* doInBackground : Image Compress Error : " + e.getMessage());
            e.printStackTrace();
        } catch (Error err) {
            err.printStackTrace();
            return "ERROR";
        }

        RequestBody requestBody = new MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("id", boardId)
                .addFormDataPart("no", postNo)
                .addFormDataPart("files[0]", filepath,
                        RequestBody.create(contentType, new File(filepath)))
                .build();

        Request request = new Request.Builder()
                .header("Cookie", "MCSESSID=" + cookie)
                .header("User-Agent", "MissyCoupons/1.0.4(3)")
                .url(this.uploadUrl)
                .post(requestBody)
                .build();

        OkHttpClient client = new OkHttpClient();
        DebugLog("*UploadTask* doInBackground : request : " + request.toString());
        try {
            Response response = client.newCall(request).execute();
            DebugLog("*UploadTask* Response : " + response.toString());
            return response.body().string();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    protected void onPostExecute(String result) {
        super.onPostExecute(result);
        this.loadingView.onUploadFinish(this.fileuri, result);
    }
}
