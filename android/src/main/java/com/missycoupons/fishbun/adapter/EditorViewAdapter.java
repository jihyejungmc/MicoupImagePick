package com.missycoupons.fishbun.adapter;

import android.content.Context;
import android.net.Uri;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.util.SparseArray;
import android.view.ViewGroup;

import com.missycoupons.fishbun.ui.editor.EditorFragment;

import java.util.ArrayList;

import static com.missycoupons.fishbun.ui.editor.EditorActivity.DebugLog;

/**
 * Created by tk on 2017-03-13.
 */

public class EditorViewAdapter extends FragmentStatePagerAdapter {

    Context mContext;
    static ArrayList<Uri> mImagePath;
    static SparseArray<EditorFragment> mInstanceArray;

    public EditorViewAdapter(FragmentManager fragmentManager, Context _mContext, ArrayList<Uri> _path) {
        super(fragmentManager);
        this.mContext = _mContext;
        this.mImagePath = _path;
        mInstanceArray = new SparseArray<>(_path.size());
    }

    @Override
    public int getCount() {
        return mImagePath.size();
    }

    public void updatePath(int position, String imagePath) {
        mImagePath.set(position, Uri.parse(imagePath));
    }

    public ArrayList<Uri> getImagePathArray() {
        return mImagePath;
    }

    @Override
    public Fragment getItem(int position) {
        if (mInstanceArray.get(position) != null){
            DebugLog("EditorAdapter(" + String.valueOf(position) + ") > get SUCCESS");
            return mInstanceArray.get(position);
        } else {
            DebugLog("EditorAdapter(" + String.valueOf(position) + ") > get NULL");
            EditorFragment fragment = EditorFragment.create(mContext, position, mImagePath.get(position));
            mInstanceArray.put(position, fragment);
            fragment.path = mImagePath.get(position);
            fragment.position = position;
            fragment.mContext = mContext;
            DebugLog("EditorAdapter(" + String.valueOf(position) + ") > put new in list : " + fragment);
            return fragment;
        }
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        DebugLog("EditorAdapter(" + String.valueOf(position) + ") > destroy");
        mInstanceArray.remove(position);
        super.destroyItem(container, position, object);
    }
}
