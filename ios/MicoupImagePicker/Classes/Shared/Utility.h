//
//  Utility.h
//
//  Created by coanyaa on 2014. 11. 7..
//  Copyright (c) 2014년 Joy2x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

+ (BOOL)isFourInchScreen;
+ (BOOL)isOverHeight480h;
+ (BOOL)isiPhone6PlusScreen;
+ (BOOL)isiPhone6Screen;
+ (CGFloat)systemVersion;
+ (NSString*)bundleVersion;
+ (NSString*)bundleShortVersion;
+ (NSString*)bundleIdentifier;
+ (NSString*)bundleName;
+ (void)alertMessage:(NSString*)message title:(NSString*)title;
+ (CGFloat)heightForString:(NSString*)str font:(UIFont*)font withSize:(CGSize)size;
+ (CGSize)sizeForString:(NSString*)str font:(UIFont*)font withSize:(CGSize)size;
+ (CGSize)sizeForAttributedString:(NSAttributedString*)attrStr withSize:(CGSize)size;
+ (CGFloat)heightForAttributedString:(NSAttributedString*)attrStr withSize:(CGSize)size;
+ (NSAttributedString*)attributedStringByTrimmingWhiteSpaceNewLineCharacterSet:(NSAttributedString*)attrStr;
+ (NSString*)cachDirectory;
+ (NSString*)filePathFromCachDirectory:(NSString*)filename;
+ (NSString*)documentDirectory;
+ (NSString*)filePathFromDocumentDirectory:(NSString*)filename;
+ (id)findSuperViewIsUICollectionViewCell:(UIView*)subView;
+ (id)findSuperViewIsUICollectionView:(UIView*)subView;
+ (id)findSuperViewIsUITableViewCell:(UIView*)subView;
+ (id)findSuperViewIsUITableView:(UIView*)subView;
+ (BOOL)isEmailFormat:(NSString *)str;
+ (UITextField*)textFieldFromUISearchBar:(UISearchBar*)searchBar;
+ (void)makeTextFieldLeftMargin:(UITextField*)textField marginWidth:(CGFloat)marginWidth;
+ (NSString*)timeStringForTimeInterval:(NSTimeInterval)interval;
+ (NSMutableArray*)parseImageUrlsFromHTMLString:(NSString*)htmlString;
+ (void)changeFontForView:(UIView*)view fontName:(NSString*)fontName;
+ (void)changeFontFromSuperview:(UIView*)superview fontName:(NSString*)fontName;
+ (void)changeAllSubViewFontFromSuperview:(UIView*)superview fontName:(NSString*)fontName;
+ (BOOL)isNumericString:(NSString*)str;
+ (void)openURL:(NSString*)url;
+ (CGFloat)screenRateByFourInchWidth;
+ (void)applyFontSizeWithScreenRate:(CGFloat)rate forView:(UIView*)targetView;
+ (void)applyAllChildViewFontSizeWithScreenRate:(CGFloat)rate parentView:(UIView*)parentView;
+ (NSString*)elapsedTimeStringFromTime:(NSDate*)fromTime;
+ (NSString*)elapsedDateStringFromTime:(NSDate*)fromTime;
+ (NSString*)elapsedTimeStringWithTimeInterval:(NSTimeInterval)interval;
+ (NSString*)timeStringWithTimeInterval:(NSTimeInterval)interval;
+ (NSString *)stringByStrippingHTML:(NSString*)str;
+ (NSInteger)generateRandomNumberFourDigit;
+ (id)parseJsonObjectFromData:(id)data;
+ (NSMutableDictionary*)parseWebParameter:(NSString*)query;
+ (void)makeOutlineWithView:(UIView*)view outlineColor:(UIColor*)outlineColor outlineWidth:(CGFloat)outlineWidth cornerRadius:(CGFloat)cornerRadius;
//+ (NSDictionary*)dictionaryFromXmlString:(NSString*)string;

+ (NSString*)userAgentString;
+ (UIViewController*)topMostViewController;

@end
