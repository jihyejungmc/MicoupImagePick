package com.missycoupons.fishbun.util;

/**
 * Created by tk on 2017-03-18.
 */

public class KoreanUtil {
    public static final String getComleteWordByJongsung(String name, String firstValue, String secondValue) {

        char lastName = name.charAt(name.length() - 1);

        // 한글의 제일 처음과 끝의 범위밖일 경우는 오류
        if (lastName < 0xAC00 || lastName > 0xD7A3) {
            return name;
        }


        String seletedValue = (lastName - 0xAC00) % 28 > 0 ? firstValue : secondValue;

        return name+seletedValue;
    }

}
