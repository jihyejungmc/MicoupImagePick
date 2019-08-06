package com.missycoupons.fishbun.ui.picker;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.missycoupons.R;
import com.missycoupons.fishbun.adapter.PickerGridAdapter;
import com.missycoupons.fishbun.bean.Album;
import com.missycoupons.fishbun.bean.Image;
import com.missycoupons.fishbun.bean.PickedImage;
import com.missycoupons.fishbun.define.Define;
import com.missycoupons.fishbun.permission.PermissionCheck;
import com.missycoupons.fishbun.ui.editor.EditorActivity;
import com.missycoupons.fishbun.ui.upload.UploadController;
import com.missycoupons.fishbun.util.SingleMediaScanner;
import com.missycoupons.fishbun.util.UiUtil;

import java.io.File;
import java.util.ArrayList;

import static android.widget.Toast.LENGTH_SHORT;
import static com.missycoupons.fishbun.ui.editor.EditorActivity.DebugLog;


public class PickerActivity extends AppCompatActivity implements UploadController.Listener  {

    private static final String TAG = "PickerActivity";

    private RecyclerView recyclerView;
    private ArrayList<PickedImage> pickedImages;
    private PickerController pickerController;
    private Album album;
    private int position;
    private UiUtil uiUtil = new UiUtil();
    private PickerGridAdapter adapter;
    private TextView SelectedPhotoTextView;
    private TextView TitleTextView;
    private ImageView DoneImageView;
    private ImageView DoneImageView2;

    private String boardId;
    private String postNo;
    private String uploadUrl;
    private String cookie;

    private TextView progressAlbumText;

    private View uploadView;
    private TextView uploadText;

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        try {
            outState.putParcelableArrayList(Define.SAVE_INSTANCE_PICK_IMAGES, pickedImages);
            outState.putString(Define.SAVE_INSTANCE_SAVED_IMAGE, pickerController.getSavePath());
            outState.putParcelableArray(Define.SAVE_INSTANCE_SAVED_IMAGE_THUMBNAILS, adapter.getImages());
            outState.putParcelableArrayList(Define.SAVE_INSTANCE_NEW_IMAGES, pickerController.getAddImagePaths());
            outState.putString("boardId", boardId);
            outState.putString("postNo", postNo);
            outState.putString("uploadUrl", uploadUrl);
            outState.putString("cookie", cookie);
        } catch (Exception e) {
            Log.d(TAG, e.toString());
        }

        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle outState) {
        // Always call the superclass so it can restore the view hierarchy
        super.onRestoreInstanceState(outState);
        // Restore state members from saved instance
        try {
            boardId = outState.getString("boardId");
            postNo = outState.getString("postNo");
            uploadUrl = outState.getString("uploadUrl");
            cookie = outState.getString("cookie");
            pickedImages = outState.getParcelableArrayList(Define.SAVE_INSTANCE_PICK_IMAGES);
            ArrayList<Uri> addImages = outState.getParcelableArrayList(Define.SAVE_INSTANCE_NEW_IMAGES);
            String savedImage = outState.getString(Define.SAVE_INSTANCE_SAVED_IMAGE);
            Image[] imageBeenList = (Image[]) outState.getParcelableArray(Define.SAVE_INSTANCE_SAVED_IMAGE_THUMBNAILS);
            adapter = new PickerGridAdapter(imageBeenList,
                    pickedImages,
                    pickerController,
                    pickerController.getPathDir(album.bucketId));
            if (addImages != null) {
                pickerController.setAddImagePaths(addImages);
            }
            if (savedImage != null) {
                pickerController.setSavePath(savedImage);
            }
        } catch (Exception e) {
            Log.d(TAG, e.toString());
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_photo_picker);
        initView();
        initController();
        setData(getIntent());
        uploadView = findViewById(R.id.UploadingView);
        uploadText = findViewById(R.id.UploadingText);
        SelectedPhotoTextView = (TextView)findViewById(R.id.Text_View);
        TitleTextView = (TextView)findViewById(R.id.TitleView);
        DoneImageView = (ImageView)findViewById(R.id.Done_View);
        DoneImageView2 = (ImageView)findViewById(R.id.Done_View2);

        DoneImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (pickedImages.size() == 0) {
                    Snackbar.make(recyclerView, Define.MESSAGE_NOTHING_SELECTED, Snackbar.LENGTH_SHORT).show();
                } else {
                    ArrayList<Uri> path = new ArrayList<>();
                    for (int i = 0; i < pickedImages.size(); i++) {
                        path.add(pickedImages.get(i).getImgPath());
                    }
                    Intent editor = new Intent(PickerActivity.this, EditorActivity.class);
                    editor.putParcelableArrayListExtra(EditorActivity.DATA_TAG, path);
                    startActivityForResult(editor, EditorActivity.EDITOR_REQUEST_CODE);
                }
            }
        });

        DoneImageView2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (pickedImages.size() == 0) {
                    Snackbar.make(recyclerView, Define.MESSAGE_NOTHING_SELECTED, Snackbar.LENGTH_SHORT).show();
                } else {
                    pickerController.uploadPhotos(pickedImages);
                }
            }
        });

        if (pickerController.checkPermission())
            pickerController.displayImage(album.bucketId);
    }

    @Override
    public void onBackPressed() {
        pickerController.transImageFinish(pickedImages, position);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == Define.TAKE_A_PICK_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                File savedFile = new File(pickerController.getSavePath());
                new SingleMediaScanner(this, savedFile);
                adapter.addImage(Uri.fromFile(savedFile));
                DebugLog("PickerActivity onActivityResult > adapter.addImage > " + Uri.fromFile(savedFile));
                // ADDED FOR #180
                if (Build.VERSION.SDK_INT != Build.VERSION_CODES.LOLLIPOP) {
                    ArrayList<Uri> path = new ArrayList<>();
                    path.add(Uri.fromFile(savedFile));
                    Intent editor = new Intent(PickerActivity.this, EditorActivity.class);
                    editor.putParcelableArrayListExtra(EditorActivity.DATA_TAG, path);
                    startActivityForResult(editor, EditorActivity.EDITOR_REQUEST_CODE);
                }
            } else {
                new File(pickerController.getSavePath()).delete();
            }
        }
        if (requestCode == EditorActivity.EDITOR_REQUEST_CODE) {
            if (data == null) return;
            ArrayList<Uri> path = data.getParcelableArrayListExtra(EditorActivity.DATA_TAG);
            pickerController.uploadPhotos(path, true);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case Define.PERMISSION_STORAGE: {
                if (grantResults.length > 0) {
                    if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                        pickerController.displayImage(album.bucketId);
                        // permission was granted, yay! do the
                        // calendar task you need to do.
                    } else {
                        new PermissionCheck(this).showPermissionDialog();
                        finish();
                    }
                }
            }

        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        //getMenuInflater().inflate(R.menu.menu_photo_album, menu);
        return true;
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify album parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        /*if (id == R.id.action_ok) {
            if (pickedImages.size() == 0) {
                Snackbar.make(recyclerView, Define.MESSAGE_NOTHING_SELECTED, Snackbar.LENGTH_SHORT).show();
            } else {
                pickerController.uploadPhotos(pickedImages);
            }
            return true;
        } else */if (id == android.R.id.home)
            pickerController.transImageFinish(pickedImages, position);
        return super.onOptionsItemSelected(item);
    }

    public void showToolbarTitle() {
        if (getSupportActionBar() != null)
            TitleTextView.setText(album.bucketName);
            //getSupportActionBar().setTitle(album.bucketName);

    }

    public void setBottomBarTitle(int total){
        if (SelectedPhotoTextView != null) {
            SelectedPhotoTextView.setText(String.valueOf(total) + "/" +Define.ALBUM_PICKER_COUNT);
            /*if (Define.ALBUM_PICKER_COUNT == 1)
                getSupportActionBar().setTitle(album.bucketName);
            else
                getSupportActionBar().setTitle(album.bucketName + "(" + String.valueOf(total) + "/" + Define.ALBUM_PICKER_COUNT + ")");*/
        }
    }

    private void setData(Intent intent) {
        boardId = intent.getStringExtra("boardId");
        postNo = intent.getStringExtra("postNo");
        uploadUrl = intent.getStringExtra("uploadUrl");
        cookie = intent.getStringExtra("cookie");
        album = intent.getParcelableExtra("album");
        position = intent.getIntExtra("position", -1);

        //only first init
        if (pickedImages == null) {
            pickedImages = new ArrayList<>();
            ArrayList<Uri> path = getIntent().getParcelableArrayListExtra(Define.INTENT_PATH);
            if (path != null) {
                for (int i = 0; i < path.size(); i++) {
                    pickedImages.add(new PickedImage(i + 1, path.get(i), -1));
                }
            }
        }
    }

    private void initController() {
        pickerController = new PickerController(this, recyclerView);
    }

    private void initView() {
        recyclerView = (RecyclerView) findViewById(R.id.recycler_picker_list);
        GridLayoutManager gridLayoutManager = new GridLayoutManager(this, Define.PHOTO_SPAN_COUNT, GridLayoutManager.VERTICAL, false);
        recyclerView.setLayoutManager(gridLayoutManager);
        initToolBar();
    }

    private void initToolBar() {
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar_picker_bar);
        setSupportActionBar(toolbar);
        toolbar.setBackgroundColor(Define.COLOR_ACTION_BAR);
        toolbar.setTitleTextColor(Define.COLOR_ACTION_BAR_TITLE_COLOR);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            uiUtil.setStatusBarColor(this);
        }
        ActionBar bar = getSupportActionBar();
        getSupportActionBar().setDisplayShowTitleEnabled(false);
        if (bar != null) bar.setDisplayHomeAsUpEnabled(true);
    }


    public void setAdapter(Image[] result) {
        if (adapter == null)
            adapter = new PickerGridAdapter(
                    result, pickedImages, pickerController, pickerController.getPathDir(album.bucketId));
        recyclerView.setAdapter(adapter);
        showToolbarTitle();
        setBottomBarTitle(pickedImages.size());
    }

    public void uploadPhotos(ArrayList<Uri> paths) {
        if (paths == null || paths.size() == 0) return;
        new UploadController.Builder(this)
                .progressView(uploadView)
                .progressText(uploadText)
                .boardId(boardId)
                .postNo(postNo)
                .uploadUrl(uploadUrl)
                .cookie(cookie)
                .imageUriList(paths)
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
}
