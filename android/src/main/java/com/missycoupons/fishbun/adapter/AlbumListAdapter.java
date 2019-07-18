package com.missycoupons.fishbun.adapter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.missycoupons.fishbun.bean.Album;
import com.missycoupons.fishbun.define.Define;
import com.missycoupons.fishbun.ui.picker.PickerActivity;

import java.util.ArrayList;
import java.util.List;
import com.missycoupons.R;

public class AlbumListAdapter
        extends RecyclerView.Adapter<AlbumListAdapter.ViewHolder> {

    private List<Album> albumList;
    private List<Uri> thumbList = new ArrayList<>();
    private ArrayList<Uri> pickedImagePath;

    public static class ViewHolder extends RecyclerView.ViewHolder {

        private View view;
        private ImageView imgAlbumThumb;
        private TextView txtAlbumName;
        private TextView txtAlbumCount;

        public ViewHolder(View view) {
            super(view);
            this.view = view;
            imgAlbumThumb = (ImageView) view.findViewById(R.id.img_album_thumb);
            imgAlbumThumb.setLayoutParams(new RelativeLayout.LayoutParams(Define.ALBUM_THUMBNAIL_SIZE, Define.ALBUM_THUMBNAIL_SIZE));

            txtAlbumName = (TextView) view.findViewById(R.id.txt_album_name);
            txtAlbumCount = (TextView) view.findViewById(R.id.txt_album_count);
        }
    }

    public AlbumListAdapter(List<Album> albumList, ArrayList<Uri> pickedImagePath) {
        this.albumList = albumList;
        this.pickedImagePath = pickedImagePath;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.album_item, parent, false);
        return new ViewHolder(view);
    }

    public void setThumbList(List<Uri> thumbList) {
        this.thumbList = thumbList;
        notifyDataSetChanged();
    }


    @Override
    public void onBindViewHolder(final ViewHolder holder, final int position) {
        if (thumbList != null && thumbList.size() > position) {
            holder.imgAlbumThumb.setImageDrawable(null);
            Glide
                    .with(holder.imgAlbumThumb.getContext())
                    .load(thumbList.get(position))
                    .thumbnail(0.1f)
                    .centerCrop()
                    .into(holder.imgAlbumThumb);
        }
        holder.view.setTag(albumList.get(position));
        Album a = (Album) holder.view.getTag();
        holder.txtAlbumName.setText(albumList.get(position).bucketName);
        holder.txtAlbumCount.setText(String.valueOf(a.counter));


        holder.view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Album a = (Album) v.getTag();
                Context context = holder.view.getContext();
                Intent i = new Intent(context, PickerActivity.class);
                i.putExtra("album", a);
                i.putExtra("album_title", albumList.get(position).bucketName);
                i.putExtra("position", position);

                i.putParcelableArrayListExtra(Define.INTENT_PATH, pickedImagePath);
                ((Activity) context).startActivityForResult(i, Define.ENTER_ALBUM_REQUEST_CODE);
            }
        });
    }

    @Override
    public int getItemCount() {
        return albumList.size();
    }

    public ArrayList<Uri> getPickedImagePath() {
        return pickedImagePath;
    }

    public void setPickedImagePath(ArrayList<Uri> pickedImagePath) {
        this.pickedImagePath = pickedImagePath;
    }

    public List<Album> getAlbumList() {
        return albumList;
    }

    public List<Uri> getThumbList() {
        return thumbList;
    }
}


