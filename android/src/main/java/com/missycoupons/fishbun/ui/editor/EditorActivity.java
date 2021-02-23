package com.missycoupons.fishbun.ui.editor;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.missycoupons.R;
import com.missycoupons.fishbun.adapter.EditorViewAdapter;
import com.missycoupons.fishbun.define.Define;
import com.tsengvn.typekit.TypekitContextWrapper;

import java.util.ArrayList;

public class EditorActivity extends FragmentActivity {

    public static String TAG = "MICOUP";

    public static final int EDITOR_REQUEST_CODE = 111;
    public static final String DATA_TAG = "DATA";

    ArrayList<Uri> mImagePath;
    EditorViewAdapter mAdapter;

    EditorViewPager mViewPager;
    LinearLayout headerBase, headerCrop, footerBase;
    ImageView headerClose, headerBack, headerFinish, headerApply;
    ImageView footerRotate, footerCrop;
    TextView headerTitle;

    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);

        //if (savedInstanceState != null) finish();

        Intent getter = getIntent();
        if (getter.hasExtra(DATA_TAG)) mImagePath = getter.getParcelableArrayListExtra(DATA_TAG);
        else finish();

        initialize();
    }

    private void initialize(){
        setContentView(R.layout.activity_photo_editor);

        mViewPager = (EditorViewPager) findViewById(R.id.editor_viewPager);
        headerBase = (LinearLayout) findViewById(R.id.editor_header_base);
        headerCrop = (LinearLayout) findViewById(R.id.editor_header_crop);
        footerBase = (LinearLayout) findViewById(R.id.editor_footer);
        headerClose = (ImageView) findViewById(R.id.editor_close);
        headerBack = (ImageView) findViewById(R.id.editor_back);
        headerFinish = (ImageView) findViewById(R.id.editor_finish);
        headerApply = (ImageView) findViewById(R.id.editor_apply);
        footerRotate = (ImageView) findViewById(R.id.editor_footer_rotate);
        footerCrop = (ImageView) findViewById(R.id.editor_footer_crop);
        headerTitle = (TextView) findViewById(R.id.editor_title);

        DebugLog("EditorActivity :: mImagePath (" + String.valueOf(mImagePath.size()) + ")");
        for (Uri currentUri : mImagePath) {
            DebugLog("EditorActivity :: mImagePath > " + currentUri.toString());
        }

        headerTitle.setText(String.valueOf(1) + " / " + String.valueOf(mImagePath.size()));

        mAdapter = new EditorViewAdapter(getSupportFragmentManager(), this, mImagePath);
        mViewPager.setAdapter(mAdapter);
        mViewPager.setOffscreenPageLimit(0);
        mViewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                headerTitle.setText(String.valueOf(position + 1) + " / " + String.valueOf(mImagePath.size()));
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });

        headerClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder mDialogBuilder = new AlertDialog.Builder(EditorActivity.this);
                mDialogBuilder.setMessage(getString(R.string.message_leaving));
                mDialogBuilder.setNegativeButton(getString(R.string.alert_cancel), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
                mDialogBuilder.setPositiveButton(getString(R.string.alert_confirm), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        finish();
                    }
                });
                mDialogBuilder.create().show();
            }
        });

        headerBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                headerBase.setVisibility(View.VISIBLE);
                headerCrop.setVisibility(View.GONE);
                footerBase.setVisibility(View.VISIBLE);
                ((EditorFragment)mAdapter.getItem(mViewPager.getCurrentItem())).toggleCropMode(EditorActivity.this, false);
                mViewPager.setPagingEnabled(true);
            }
        });

        headerFinish.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent resultIntent = new Intent();
                resultIntent.putParcelableArrayListExtra(DATA_TAG, mAdapter.getImagePathArray());
                setResult(EDITOR_REQUEST_CODE, resultIntent);
                finish();
            }
        });

        headerApply.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((EditorFragment)mAdapter.getItem(mViewPager.getCurrentItem())).cropImage(EditorActivity.this);
            }
        });

        footerRotate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((EditorFragment)mAdapter.getItem(mViewPager.getCurrentItem())).rotateImage(EditorActivity.this);
            }
        });

        footerCrop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean toggleSuccess = ((EditorFragment)mAdapter.getItem(mViewPager.getCurrentItem())).toggleCropMode(EditorActivity.this, true);
                if (!toggleSuccess) {
                    return;
                }
                headerBase.setVisibility(View.GONE);
                headerCrop.setVisibility(View.VISIBLE);
                footerBase.setVisibility(View.INVISIBLE);
                mViewPager.setPagingEnabled(false);
            }
        });
    }

    public void onCropFinished(int position, String saveUri, boolean success){
        headerBase.setVisibility(View.VISIBLE);
        headerCrop.setVisibility(View.GONE);
        footerBase.setVisibility(View.VISIBLE);
        ((EditorFragment)mAdapter.getItem(mViewPager.getCurrentItem())).toggleCropMode(EditorActivity.this, false);
        mViewPager.setPagingEnabled(true);
        if (success) {
            mAdapter.updatePath(position, saveUri);
        }
        else {
            finish();
        }
    }

    @Override
    public void onBackPressed(){
        if (headerCrop.getVisibility() == View.VISIBLE) {
            headerBase.setVisibility(View.VISIBLE);
            headerCrop.setVisibility(View.GONE);
            footerBase.setVisibility(View.VISIBLE);
            ((EditorFragment)mAdapter.getItem(mViewPager.getCurrentItem())).toggleCropMode(EditorActivity.this, false);
            mViewPager.setPagingEnabled(true);
            return;
        }
        AlertDialog.Builder mDialogBuilder = new AlertDialog.Builder(EditorActivity.this);
        mDialogBuilder.setMessage(getString(R.string.message_leaving));
        mDialogBuilder.setNegativeButton(getString(R.string.alert_cancel), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        mDialogBuilder.setPositiveButton(getString(R.string.alert_confirm), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                finish();
            }
        });
        mDialogBuilder.create().show();
    }

    public static void DebugLog(String str) {
        if(str.length() > 2000) {
            Log.i(TAG, str.substring(0, 2000));
            DebugLog(str.substring(2000));
        } else
            Log.i(TAG, str);
    }

/*
    @Override
    protected void attachBaseContext(Context newBase) {
        //TypeKit를 적용한 BaseContext로 변경합니다.
        super.attachBaseContext(TypekitContextWrapper.wrap(newBase));
    }
*/

}
