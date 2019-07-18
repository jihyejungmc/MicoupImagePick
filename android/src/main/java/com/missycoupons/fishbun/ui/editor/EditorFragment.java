package com.missycoupons.fishbun.ui.editor;

import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.isseiaoki.simplecropview.CropImageView;
import com.isseiaoki.simplecropview.callback.CropCallback;
import com.isseiaoki.simplecropview.callback.LoadCallback;
import com.isseiaoki.simplecropview.callback.SaveCallback;
import com.missycoupons.R;

import java.io.File;

import static com.missycoupons.fishbun.ui.editor.EditorActivity.DebugLog;

/**
 * Created by tk on 2017-03-13.
 */

public class EditorFragment extends Fragment {

    private static final String PROGRESS_DIALOG = "ProgressDialog";

    public Context mContext;
    public int position;
    public Uri path;

    CropImageView mCropView;

    public static EditorFragment create(Context _mContext, int _position, Uri _path) {
        DebugLog("EditorFragment(" + String.valueOf(_position) + ") > create NEW : " + _path);
        EditorFragment fragment = new EditorFragment();
        Bundle args = new Bundle();
        args.putInt("position", _position);
        args.putString("path", _path.toString());
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        position = getArguments().getInt("position");
        path = Uri.parse(getArguments().getString("path"));
        DebugLog("EditorFragment(" + String.valueOf(position) + ") > onCreate [" + path + "]");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        DebugLog("EditorFragment(" + String.valueOf(position) + ") > onCreateView [" + path + "]");

        ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.viewpager_image, container, false);

        if (savedInstanceState == null) { // savedInstanceState == null ||
            mCropView = (CropImageView) rootView.findViewById(R.id.editor_viewPager_CropView);
            mCropView.setOutputMaxSize(1200, 1200);
            mCropView.setCropEnabled(false);
            mCropView.startLoad(path, new LoadCallback() {
                @Override
                public void onSuccess() {
                    DebugLog("EditorFragment(" + String.valueOf(position) + ") > startLoad(SUCCESS): " + path);
                }

                @Override
                public void onError() {
                    DebugLog("EditorFragment(" + String.valueOf(position) + ") > startLoad(ERROR): " + path);
                }
            });
        }

        return rootView;
    }

    public boolean toggleCropMode(final EditorActivity mActivity, boolean enabled){
        DebugLog("EditorFragment(" + String.valueOf(position) + ") > toggleCropMode : " + String.valueOf(enabled));
        if (enabled){
            String filepath = getPath(mActivity, path);
            if (filepath != null && filepath.contains(".")) {
                if (filepath.substring(filepath.lastIndexOf(".")).contains("gif")) {
                    Toast.makeText(mActivity, mActivity.getString(R.string.gif_exception),Toast.LENGTH_SHORT).show();
                    return false;
                }
            }
        }
        mCropView.setCropEnabled(enabled);
        return true;
    }

    public void rotateImage(final EditorActivity mActivity){
        DebugLog("EditorFragment(" + String.valueOf(position) + ") > rotateImage");
        String filepath = getPath(mActivity, path);
        if (filepath != null && filepath.contains(".")) {
            if (filepath.substring(filepath.lastIndexOf(".")).contains("gif")) {
                Toast.makeText(mActivity, mActivity.getString(R.string.gif_exception),Toast.LENGTH_SHORT).show();
                return;
            }
        }
        mCropView.rotateImage(CropImageView.RotateDegrees.ROTATE_90D);
        cropImage(mActivity);
    }

    public void cropImage(final EditorActivity mActivity){
        DebugLog("EditorFragment(" + String.valueOf(position) + ") > cropImage : " + path + " : ");
        String filepath = getPath(mActivity, path);
        if (filepath != null && filepath.contains(".")) {
            if (filepath.substring(filepath.lastIndexOf(".")).contains("gif")) {
                Toast.makeText(mActivity, mActivity.getString(R.string.gif_exception),Toast.LENGTH_SHORT).show();
                return;
            }
        }
        showProgress();
        Uri saveUri = createSaveUri();
        if (saveUri == null) {
            DebugLog("EditorFragment: Cannot create save uri");
            Toast.makeText(mActivity, mActivity.getString(R.string.crop_failed),Toast.LENGTH_SHORT).show();
            dismissProgress();
            return;
        }

        mCropView.startCrop(saveUri, null, new SaveCallback() {
            @Override
            public void onSuccess(Uri outputUri) {
                mActivity.onCropFinished(position, outputUri.toString(), true);
                mCropView.startLoad(outputUri, null);
                dismissProgress();
            }

            @Override
            public void onError() {
                Toast.makeText(mActivity, mActivity.getString(R.string.crop_failed),Toast.LENGTH_SHORT).show();
                mActivity.onCropFinished(position, null, false);
                dismissProgress();
            }
        });
    }

    private String getPath(Context mContext, Uri uri) {
        DebugLog("EditorFragment > getPath : " + mContext + " / " + uri);
        Cursor cursor = null;
        try {
            String[] proj = { MediaStore.Images.Media.DATA };
            cursor = mContext.getContentResolver().query(uri, proj, null, null, null);
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            cursor.moveToFirst();
            String result = cursor.getString(column_index);
            cursor.close();
            return result;
        } catch (Exception e){
            e.printStackTrace();
            return uri.getPath();
        }
    }

    public Uri createSaveUri() {
        File path = new File(Environment.getExternalStorageDirectory() + "/micoup/");
        try {
            path.mkdirs();
        } catch (SecurityException ex) {
            DebugLog("EditorFragment > createSaveUri > Failed to create paths for "+path.toString());
            return null;
        }

        return Uri.fromFile(new File(path, String.valueOf(System.currentTimeMillis()) + String.valueOf(position) + ".png"));
    }

    public void showProgress() {
        ProgressDialogFragment f = ProgressDialogFragment.getInstance();
        getFragmentManager()
                .beginTransaction()
                .add(f, PROGRESS_DIALOG)
                .commitAllowingStateLoss();
    }

    public void dismissProgress() {
        if (!isAdded()) return;
        android.support.v4.app.FragmentManager manager = getFragmentManager();
        if (manager == null) return;
        ProgressDialogFragment f = (ProgressDialogFragment) manager.findFragmentByTag(PROGRESS_DIALOG);
        if (f != null) {
            getFragmentManager().beginTransaction().remove(f).commitAllowingStateLoss();
        }
    }


}
