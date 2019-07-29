package com.missycoupons.fishbun.network;

import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.ColorMatrix;
import android.graphics.ColorMatrixColorFilter;
import android.graphics.LightingColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicBlur;

import java.io.IOException;
import java.io.InputStream;

/**
 * 이미지의 사이즈 변경,병합 등 여러 기능을 담당하는 기능을 모아놓은 클래스입니다.
 */

public class BitmapUtils {

    /**
     * 내장된 이미지인 Drawable을 Bitmap으로 변환시켜주는 메서드
     *
     * @param drawable 내장된 이미지
     * @return Bitmap
     */
    public static Bitmap drawableToBitmap (Drawable drawable) {
        Bitmap bitmap = null;

        if(drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
        } else {
            bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        }

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    /**
     * Bitmap을 ratio에 맞춰서 max값 만큼 resize한다.
     *
     * @param src Bitmap 원본
     * @param max 원하는 최대 크기의 값
     * @return Bitmap
     */
    public static Bitmap resizeBitmap(Bitmap src, int max) {
        if(src == null)
            return null;

        int width = src.getWidth();
        int height = src.getHeight();
        float rate = 0.0f;

        if (width > height) {
            rate = max / (float) width;
            height = (int) (height * rate);
            width = max;
        } else {
            rate = max / (float) height;
            width = (int) (width * rate);
            height = max;
        }

        return Bitmap.createScaledBitmap(src, width, height, true);
    }

    /**
     * Bitmap을 ratio에 맞춰서 max값 만큼 resize한다.
     *
     * @param src Bitmap 원본
     * @param max 원하는 최대 크기의 값
     * @param isKeep 작은 크기인 경우 유지할건지 체크
     * @return Bitmap
     */
    public static Bitmap resize(Bitmap src, int max, boolean isKeep) {
        if(!isKeep)
            return resizeBitmap(src, max);

        int width = src.getWidth();
        int height = src.getHeight();
        float rate = 0.0f;

        if (width < max && height < max) {
            return src;
        }

        if (width > height) {
            if (max < width) {
                rate = max / (float) width;
                height = (int) (height * rate);
                width = max;
            }
        } else {
            if (max < height) {
                rate = max / (float) height;
                width = (int) (width * rate);
                height = max;
            }
        }

        return Bitmap.createScaledBitmap(src, width, height, true);
    }

    public static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;

        if (height > reqHeight || width > reqWidth) {

            final int halfHeight = height / 2;
            final int halfWidth = width / 2;

            while ((halfHeight / inSampleSize) >= reqHeight
                    || (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }

        return inSampleSize;
    }

    /**
     * Bitmap 이미지를 정사각형으로 만든다.
     *
     * @param src Bitmap 원본
     * @param max 원하는 최대 크기의 값
     * @return Bitmap
     */
    public static Bitmap resizeSquare(Bitmap src, int max) {
        if(src == null)
            return null;

        return Bitmap.createScaledBitmap(src, max, max, true);
    }

    /**
     * Bitmap 이미지를 x, y 를 기준으로 w, h 크기 만큼 자른다.
     *
     * @param src Bitmap 원본
     * @param x 자르기 시작할 X좌표
     * @param y 자르기 시작할 Y좌표
     * @param w 넓이
     * @param h 높이
     * @return Bitmap
     */
    public static Bitmap cropCenterBitmap(Bitmap src, int x, int y, int w, int h) {
        if(src == null)
            return null;

        int width = src.getWidth();
        int height = src.getHeight();

        if(width < w && height < h)
            return src;

        int cw = w; // crop width
        int ch = h; // crop height

        if(w > width)
            cw = width;

        if(h > height)
            ch = height;

        return Bitmap.createBitmap(src, x, y, cw, ch);
    }

    /**
     * 색상 필터를 적용합니다
     *
     * @param sourceBitmap 필터가 적용될 Bitmap
     * @param color 필터의 색상값
     * @return Bitmap
     */
    private Bitmap setColorFilter(Bitmap sourceBitmap, int color) {

        Bitmap resultBitmap = Bitmap.createBitmap(sourceBitmap, 0, 0,
                sourceBitmap.getWidth() - 1, sourceBitmap.getHeight() - 1);
        Paint p = new Paint();
        ColorFilter filter = new LightingColorFilter(color, 1);
        p.setColorFilter(filter);

        Canvas canvas = new Canvas(resultBitmap);
        canvas.drawBitmap(resultBitmap, 0, 0, p);

        return resultBitmap;
    }

    /**
     * 이미지를 90도 회전시킵니다.
     *
     * @param bmp 회전시킬 Bitmap
     * @return Bitmap
     */
    public static Bitmap rotateBitmap(Bitmap bmp){

        int width = bmp.getWidth();
        int height = bmp.getHeight();

        Matrix matrix = new Matrix();
        matrix.postRotate(-90);

        Bitmap resizedBitmap = Bitmap.createBitmap(bmp, 0, 0, width, height, matrix, true);
        bmp.recycle();

        return resizedBitmap;
    }

    public static Bitmap blurBitmap(Context context, Bitmap sentBitmap, float radius) {
        if (radius == 0.0){
            return sentBitmap;
        }

        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.JELLY_BEAN) {
            try {
                Bitmap bitmap = sentBitmap.copy(sentBitmap.getConfig(), true);
                final RenderScript rs = RenderScript.create(context);
                final Allocation input = Allocation.createFromBitmap(rs, sentBitmap, Allocation.MipmapControl.MIPMAP_NONE,
                        Allocation.USAGE_SCRIPT);
                final Allocation output = Allocation.createTyped(rs, input.getType());
                final ScriptIntrinsicBlur script = ScriptIntrinsicBlur.create(rs, Element.U8_4(rs));
                script.setRadius(radius); //0.0f ~ 25.0f
                script.setInput(input);
                script.forEach(output);
                output.copyTo(bitmap);
                return bitmap;
            } catch (Exception err){
                return sentBitmap;
            }
        } else {
            return sentBitmap;
        }

    }

    /**
     * 두 개의 Bitmap 이미지를 하나로 합친다
     *
     * @param bmp1 합칠 원본 이미지
     * @param bmp2 합칠 추가할 이미지
     * @param x 이미지를 추가할 X좌표
     * @param y 이미지를 추가할 Y좌표
     * @return Bitmap
     */
    public static Bitmap mergeBitmap(Bitmap bmp1, Bitmap bmp2, int x, int y) {
        Bitmap bmOverlay = Bitmap.createBitmap(bmp1.getWidth(), bmp1.getHeight(), bmp1.getConfig());

        Canvas canvas = new Canvas(bmOverlay);
        canvas.drawBitmap(bmp1, new Matrix(), null);
        canvas.drawBitmap(bmp2, x, y, null);

        return bmOverlay;
    }

    public static Bitmap changeBitmapColor(Bitmap bmp, float red, float green, float blue)
    {
        ColorMatrix cm = new ColorMatrix(new float[]
                {
                        red/255, 0, 0, 0, 0,
                        0, green/255, 0, 0, 0,
                        0, 0, blue/255, 0, 0,
                        0, 0, 0, 1, 0
                });

        Bitmap ret = Bitmap.createBitmap(bmp.getWidth(), bmp.getHeight(), bmp.getConfig());

        Canvas canvas = new Canvas(ret);

        Paint paint = new Paint();
        paint.setColorFilter(new ColorMatrixColorFilter(cm));
        canvas.drawBitmap(bmp, 0, 0, paint);

        return ret;
    }

    public static Bitmap changeBitmapDepth(Bitmap src, int bitOffset) {
        int width = src.getWidth();
        int height = src.getHeight();
        Bitmap bmOut = Bitmap.createBitmap(width, height, src.getConfig());
        int A, R, G, B;

        int[] pixels = new int[height * width];
        src.getPixels(pixels,0,width,0,0,width,height);

        for(int a = 0; a < pixels.length; a ++) {
            int pixel = pixels[a];
            A = Color.alpha(pixel);
            R = Color.red(pixel);
            G = Color.green(pixel);
            B = Color.blue(pixel);

            R = ((R + (bitOffset / 2)) - ((R + (bitOffset / 2)) % bitOffset) - 1);
            if(R < 0) { R = 0; }
            G = ((G + (bitOffset / 2)) - ((G + (bitOffset / 2)) % bitOffset) - 1);
            if(G < 0) { G = 0; }
            B = ((B + (bitOffset / 2)) - ((B + (bitOffset / 2)) % bitOffset) - 1);
            if(B < 0) { B = 0; }

            pixels[a] = Color.argb(A,R,G,B);
        }
        bmOut.setPixels(pixels,0,width,0,0,width,height);
        return bmOut;
    }

    public static Bitmap changeBitmapRGBEffect(Bitmap bmp, int red_value, int green_value, int blue_value, int red_start, int red_end, int green_start, int green_end, int blue_start, int blue_end, boolean opposite, float opposite_per){

        int width = bmp.getWidth();
        int height = bmp.getHeight();

        Bitmap bmOut = Bitmap.createBitmap(width, height, bmp.getConfig());

        int A, R, G, B;
        int[] pixels = new int[height * width];
        bmp.getPixels(pixels,0,width,0,0,width,height);

        for(int a = 0; a < pixels.length; a ++) {
            int pixel = pixels[a];

            A = Color.alpha(pixel);
            R = Color.red(pixel);
            G = Color.green(pixel);
            B = Color.blue(pixel);

            if (R >= red_start && R <= red_end && G >= green_start && G <= green_end && B >= blue_start && B <= blue_end){

                R += red_value;
                G += green_value;
                B += blue_value;

                if (R > 255) R = 255;
                if (G > 255) G = 255;
                if (B > 255) B = 255;
            } else if (opposite){
                R -= red_value * opposite_per;
                G -= green_value * opposite_per;
                B -= blue_value * opposite_per;

                if (R < 0) R = 0;
                if (G < 0) G = 0;
                if (B < 0) B = 0;
            }
            pixels[a] = Color.argb(A,R,G,B);
        }

        bmOut.setPixels(pixels,0,width,0,0,width,height);

        return bmOut;
    }

    public static Bitmap changeBitmapContrastBrightness(Bitmap bmp, float contrast, float brightness)
    {
        ColorMatrix cm = new ColorMatrix(new float[]
                {
                        contrast, 0, 0, 0, brightness,
                        0, contrast, 0, 0, brightness,
                        0, 0, contrast, 0, brightness,
                        0, 0, 0, 1, 0
                });

        Bitmap ret = Bitmap.createBitmap(bmp.getWidth(), bmp.getHeight(), bmp.getConfig());

        Canvas canvas = new Canvas(ret);

        Paint paint = new Paint();
        paint.setColorFilter(new ColorMatrixColorFilter(cm));
        canvas.drawBitmap(bmp, 0, 0, paint);

        return ret;
    }

    public static Bitmap changeBitmapSaturation(Bitmap src, float settingSat) {

        int w = src.getWidth();
        int h = src.getHeight();

        Bitmap bitmapResult =
                Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        Canvas canvasResult = new Canvas(bitmapResult);
        Paint paint = new Paint();
        ColorMatrix colorMatrix = new ColorMatrix();
        colorMatrix.setSaturation(settingSat);
        ColorMatrixColorFilter filter = new ColorMatrixColorFilter(colorMatrix);
        paint.setColorFilter(filter);
        canvasResult.drawBitmap(src, 0, 0, paint);

        return bitmapResult;
    }

    /** Get Bitmap's Width **/
    public static int getBitmapOfWidth( String fileName ){
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(fileName, options);
            return options.outWidth;
        } catch(Exception e) {
            return 0;
        }
    }

    /**
     * 이미지 경로로부터 올바르게 회전된 Bitmap을 가져옴
     *
     * @param context Context
     * @param photoUri Uri
     * @return Bitmap
     * @throws IOException
     */
    public static Bitmap getCorrectlyOrientedImage(Context context, Uri photoUri, String photoPath) throws IOException {
        InputStream is = context.getContentResolver().openInputStream(photoUri);
        BitmapFactory.Options dbo = new BitmapFactory.Options();
        dbo.inJustDecodeBounds = true;
        BitmapFactory.decodeStream(is, null, dbo);
        is.close();

        int MAX_IMAGE_SIZE = 1200;

        //int orientation = getOrientation(context, photoUri);
        int scale = 1;
        if (dbo.outHeight > MAX_IMAGE_SIZE || dbo.outWidth > MAX_IMAGE_SIZE) {
            scale = (int)Math.pow(2, (int)Math.round(Math.log(MAX_IMAGE_SIZE/(double)Math.max(dbo.outHeight, dbo.outWidth)) / Math.log(0.5)));
        }
        dbo.inJustDecodeBounds = false;
        dbo.inSampleSize = scale;

        Bitmap srcBitmap;
        is = context.getContentResolver().openInputStream(photoUri);
        srcBitmap = BitmapFactory.decodeStream(is, null, dbo);
        is.close();

        /*
        if (orientation > 0) {
            Matrix matrix = new Matrix();
            matrix.postRotate(orientation);

            srcBitmap = Bitmap.createBitmap(srcBitmap, 0, 0, srcBitmap.getWidth(),
                    srcBitmap.getHeight(), matrix, true);
        }
        */
        int orientation;
        try {
            ExifInterface ei = new ExifInterface(photoPath);
            orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_UNDEFINED);
        } catch (Exception e) {
            e.printStackTrace();
            orientation = ExifInterface.ORIENTATION_UNDEFINED;
        }

        if (orientation == ExifInterface.ORIENTATION_UNDEFINED) {
            int rotation = getOrientation(context, photoUri);

            return rotateImage(srcBitmap, rotation);
        }

        switch(orientation) {

            case ExifInterface.ORIENTATION_ROTATE_90:
                return rotateImage(srcBitmap, 90);

            case ExifInterface.ORIENTATION_ROTATE_180:
                return rotateImage(srcBitmap, 180);

            case ExifInterface.ORIENTATION_ROTATE_270:
                return rotateImage(srcBitmap, 270);

            case ExifInterface.ORIENTATION_NORMAL:
            default:
                return srcBitmap;
        }
    }

    public static Bitmap rotateImage(Bitmap source, float angle) {
        Matrix matrix = new Matrix();
        matrix.postRotate(angle);
        return Bitmap.createBitmap(source, 0, 0, source.getWidth(), source.getHeight(),
                matrix, true);
    }

    /**
     * 이미지로부터 회전 각을 가져와서 올바르게 회전시킴
     *
     * @param context 컨텍스트
     * @param photoUri 포토 경로
     * @return int
     */
    public static int getOrientation(Context context, Uri photoUri) {
        Cursor cursor = context.getContentResolver().query(photoUri,
                new String[]{MediaStore.Images.ImageColumns.ORIENTATION}, null, null, null);

        int rotation = 0;

        try {
            if (cursor.getCount() != 1) {
                rotation = -1;
            }
            cursor.moveToFirst();
            rotation = cursor.getInt(0);
            cursor.close();
        } catch (NullPointerException e) {
            e.printStackTrace();
        }

        return rotation;
    }

}

