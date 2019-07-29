package com.missycoupons.fishbun.network;

/**
 * JsonDecoder 에서 서버의 response 를 받아올 때 쓰이는 Listener 입니다.
 */

public interface LoadingView {
    void onUploadStart(String id);

    void onUploadFinish(String id, String result);
}
