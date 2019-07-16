//
//  Utility.m
//
//  Created by coanyaa on 2014. 11. 7..
//  Copyright (c) 2014년 Joy2x. All rights reserved.
//

#import <stdlib.h>
#import "Utility.h"
#import "DateHelper.h"

//@import HTMLReader;

@implementation Utility

+ (BOOL)isFourInchScreen
{
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    
    return (appFrame.size.height == 568.0);
}

+ (BOOL)isOverHeight480h
{
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    
    return (appFrame.size.height > 480.0);
}

+ (BOOL)isiPhone6PlusScreen
{
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    
    return (appFrame.size.height == 736.0 && appFrame.size.width == 414.0);
}

+ (BOOL)isiPhone6Screen
{
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    
    return (appFrame.size.height == 667.0 && appFrame.size.width == 375.0);
}

+ (CGFloat)systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString*)bundleVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString*)bundleShortVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString*)bundleIdentifier
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString*)bundleName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
}

+ (void)alertMessage:(NSString*)message title:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:(title ? title : @"") message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    [alertView show];
}

+ (CGFloat)heightForString:(NSString*)str font:(UIFont*)font withSize:(CGSize)size
{
    CGFloat retHeight = 0.0;
    
    if( [Utility systemVersion] < 7.0 ){
        CGSize size = [str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
        retHeight = ceilf(size.height);
    }
    else{
        CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
        retHeight = ceilf(rect.size.height);
    }
    
    return retHeight;
}

+ (CGSize)sizeForString:(NSString*)str font:(UIFont*)font withSize:(CGSize)size
{
    CGSize retSize = CGSizeZero;
    
    if( [Utility systemVersion] < 7.0 ){
        CGSize size = [str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByTruncatingTail];
        retSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    }
    else{
        CGRect rect = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading   attributes:@{NSFontAttributeName : font} context:nil];
        retSize = CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
    }
    
    return retSize;
}

+ (CGSize)sizeForAttributedString:(NSAttributedString*)attrStr withSize:(CGSize)size
{
    CGRect rect = [attrStr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

+ (CGFloat)heightForAttributedString:(NSAttributedString*)attrStr withSize:(CGSize)size
{
    CGRect rect = [attrStr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    return ceilf(rect.size.height);
}

+ (NSAttributedString*)attributedStringByTrimmingWhiteSpaceNewLineCharacterSet:(NSAttributedString*)attrStr
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange range           = [attrString.string rangeOfCharacterFromSet:charSet];
    while (range.length != 0 && range.location == 0)
    {
        [attrString replaceCharactersInRange:range withString:@""];
        range = [attrString.string rangeOfCharacterFromSet:charSet];
    }
    
    // Trim trailing whitespace and newlines.
    range = [attrString.string rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
    while (range.length != 0 && NSMaxRange(range) == attrString.length)
    {
        [attrString replaceCharactersInRange:range withString:@""];
        range = [attrString.string rangeOfCharacterFromSet:charSet options:NSBackwardsSearch];
    }
    
    return [attrString attributedSubstringFromRange:NSMakeRange(0, [attrString length])];
}

+ (NSString*)cachDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString*)filePathFromCachDirectory:(NSString*)filename
{
    return [[Utility cachDirectory] stringByAppendingPathComponent:filename];
}

+ (NSString*)documentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString*)filePathFromDocumentDirectory:(NSString*)filename
{
    return [[Utility documentDirectory] stringByAppendingPathComponent:filename];
}

+ (id)findSuperViewIsUICollectionViewCell:(UIView*)subView
{
    if( [subView superview] == nil )
        return nil;
    else if( [[subView superview] isKindOfClass:[UICollectionViewCell class]] )
        return [subView superview];
    
    return [Utility findSuperViewIsUICollectionViewCell:[subView superview]];
}

+ (id)findSuperViewIsUICollectionView:(UIView*)subView
{
    if( [subView superview] == nil )
        return nil;
    else if( [[subView superview] isKindOfClass:[UICollectionView class]] )
        return [subView superview];
    
    return [Utility findSuperViewIsUICollectionView:[subView superview]];
}

+ (id)findSuperViewIsUITableViewCell:(UIView*)subView
{
    if( [subView superview] == nil )
        return nil;
    else if( [[subView superview] isKindOfClass:[UITableViewCell class]] )
        return [subView superview];
    
    return [Utility findSuperViewIsUITableViewCell:[subView superview]];
}

+ (id)findSuperViewIsUITableView:(UIView*)subView
{
    if( [subView superview] == nil )
        return nil;
    else if( [[subView superview] isKindOfClass:[UITableView class]] )
        return [subView superview];
    
    return [Utility findSuperViewIsUITableView:[subView superview]];
}

+ (BOOL)isEmailFormat:(NSString *)str
{
    if([str length] < 1)
        return NO;
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:str options:0 range:NSMakeRange(0, [str length])];
    
    return ( regExMatches > 0 );
}


+ (UITextField*)textFieldFromUISearchBar:(UISearchBar*)searchBar
{
    UITextField *textField = nil;
    for(UIView *view in searchBar.subviews){
        if([view isKindOfClass:[UITextField class]]){
            textField = (UITextField *)view;
            break;
        }
    }
    
    return textField;
}

+ (void)makeTextFieldLeftMargin:(UITextField*)textField marginWidth:(CGFloat)marginWidth
{
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, marginWidth, textField.frame.size.height)];
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (NSString*)timeStringForTimeInterval:(NSTimeInterval)interval
{
    NSString *retStr = @"";
    
    NSInteger hour = (NSInteger)(interval / 3600.0);
    NSInteger minutes = (NSInteger)(( interval - (hour * 3600.0) ) / 60.0);
    NSInteger seconds = (NSInteger)fmodf(interval, 60.0);
    
    if( hour > 0 )
        retStr = [retStr stringByAppendingFormat:@"%ld시간",(long)hour];
    if( minutes > 0 )
        retStr = [retStr stringByAppendingFormat:@"%@%ld분",( [retStr length] > 0 ? @" " : @""),(long)minutes];
    if( seconds > 0 )
        retStr = [retStr stringByAppendingFormat:@"%@%ld초",( [retStr length] > 0 ? @" " : @""),(long)seconds];
    
    return retStr;
}

+ (NSMutableArray*)parseImageUrlsFromHTMLString:(NSString*)htmlString
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableArray *array = [NSMutableArray array];
    [regex enumerateMatchesInString:htmlString
                            options:0
                              range:NSMakeRange(0, [htmlString length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSString *img = [htmlString substringWithRange:[result rangeAtIndex:2]];
                             [array addObject:img];
                         }];
    return array;
}

+ (void)changeFontForView:(UIView*)view fontName:(NSString*)fontName
{
    
    if( [view isKindOfClass:[UILabel class]] ){
        UILabel *label = (UILabel*)view;
        UIFont *font = [UIFont fontWithName:fontName size:label.font.pointSize];
        label.font = font;
    }
    else if( [view isKindOfClass:[UIButton class]] ){
        UIButton *button = (UIButton*)view;
        UIFont *font = [UIFont fontWithName:fontName size:button.titleLabel.font.pointSize];
        button.titleLabel.font = font;
    }
    else if( [view isKindOfClass:[UITextView class]] ){
        UITextView *textView = (UITextView*)view;
        UIFont *font = [UIFont fontWithName:fontName size:textView.font.pointSize];
        textView.font = font;
    }
    else if( [view isKindOfClass:[UITextField class]] ){
        UITextField *textField = (UITextField*)view;
        UIFont *font = [UIFont fontWithName:fontName size:textField.font.pointSize];
        textField.font = font;
    }
}

+ (void)changeFontFromSuperview:(UIView*)superview fontName:(NSString*)fontName
{
    for(UIView *subView in superview.subviews ){
        [Utility changeFontForView:subView fontName:fontName];
    }
}

+ (void)changeAllSubViewFontFromSuperview:(UIView*)superview fontName:(NSString*)fontName
{
    for(UIView *subView in superview.subviews ){
        if( [subView.subviews count] > 0 )
            [Utility changeAllSubViewFontFromSuperview:subView fontName:fontName];
        else
            [Utility changeFontForView:subView fontName:fontName];
    }
}

+ (BOOL)isNumericString:(NSString*)str
{
    NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
    return ([[str stringByTrimmingCharactersInSet:numberSet] length] < 1);
}

+ (void)openURL:(NSString*)url
{
    NSURL *openURL = [NSURL URLWithString:url];
    if( [[UIApplication sharedApplication] canOpenURL:openURL] )
        [[UIApplication sharedApplication] openURL:openURL];
}

+ (CGFloat)screenRateByFourInchWidth
{
    CGRect appFrame = [[UIScreen mainScreen] bounds];
    return ( appFrame.size.width / 320.0 );
}

+ (void)applyFontSizeWithScreenRate:(CGFloat)rate forView:(UIView*)targetView
{
    if( [targetView isKindOfClass:[UILabel class]] ){
        UILabel *label = (UILabel*)targetView;
        label.font = [label.font fontWithSize:label.font.pointSize * rate];
    }
    else if( [targetView isKindOfClass:[UIButton class]] ){
        UIButton *button = (UIButton*)targetView;
        button.titleLabel.font = [button.titleLabel.font fontWithSize:button.titleLabel.font.pointSize*rate];
    }
    else if( [targetView isKindOfClass:[UITextField class]] ){
        UITextField *textField = (UITextField*)targetView;
        textField.font = [textField.font fontWithSize:textField.font.pointSize*rate];
    }
    else if( [targetView isKindOfClass:[UITextView class]] ){
        UITextView *textView = (UITextView*)targetView;
        textView.font = [textView.font fontWithSize:textView.font.pointSize * rate];
    }
}

+ (void)applyAllChildViewFontSizeWithScreenRate:(CGFloat)rate parentView:(UIView*)parentView
{
    [Utility applyFontSizeWithScreenRate:rate forView:parentView];
    if( [parentView isKindOfClass:[UIButton class]] || [parentView isKindOfClass:[UITextField class]] || [parentView isKindOfClass:[UILabel class]] || [parentView isKindOfClass:[UITextView class]])
        return;
    
    if( [parentView.subviews count] > 0 ){
        for(UIView *subView in parentView.subviews){
            [Utility applyAllChildViewFontSizeWithScreenRate:rate parentView:subView];
        }
    }
}

+ (NSString*)elapsedTimeStringFromTime:(NSDate*)fromTime
{
    NSDate *date = [NSDate date];
    NSTimeInterval elapsedTime = [date timeIntervalSinceDate:fromTime];
    
    NSString *retStr = @"";
    
    if( elapsedTime < 10 )
        retStr = @"방금";
    else if( elapsedTime < 60.0 )
        retStr = [NSString stringWithFormat:@"%.0f초전",elapsedTime];
    else if( elapsedTime < 3600.0 )
        retStr = [NSString stringWithFormat:@"%.0f분전", elapsedTime/60.0];
    else if( elapsedTime < (3600.0 * 24.0) )
        retStr = [NSString stringWithFormat:@"%.0f시간전", elapsedTime/3600.0];
    else{
        NSInteger fromYear = [DateHelper yearFromDate:fromTime];
        NSInteger nowYear = [DateHelper yearFromDate:date];
        if( fromYear == nowYear )
            retStr = [DateHelper dateStringFromDate:fromTime withFormat:@"M월 d일"];
        else
            retStr = [DateHelper dateStringFromDate:fromTime withFormat:@"yyyy년 M월 d일"];
    }
    
    return retStr;
}

+ (NSString*)elapsedDateStringFromTime:(NSDate*)fromTime
{
    NSDate *date = [NSDate date];
    NSTimeInterval elapsedTime = [date timeIntervalSinceDate:fromTime];
    
    NSString *retStr = @"";
    
    if( elapsedTime < 10 )
        retStr = @"방금";
    else if( elapsedTime < 60.0 )
        retStr = [NSString stringWithFormat:@"%.0f초전",elapsedTime];
    else if( elapsedTime < 3600.0 )
        retStr = [NSString stringWithFormat:@"%.0f분전", elapsedTime/60.0];
    else if( elapsedTime < (3600.0 * 24.0) )
        retStr = [NSString stringWithFormat:@"%.0f시간전", elapsedTime/3600.0];
    else{
        NSInteger diffDays = [DateHelper diffDaysFromDate:fromTime toDate:date];
        if( diffDays == 1 )
            retStr = @"어제";
        else{
            NSInteger fromYear = [DateHelper yearFromDate:fromTime];
            NSInteger nowYear = [DateHelper yearFromDate:date];
            if( fromYear == nowYear )
                retStr = [DateHelper dateStringFromDate:fromTime withFormat:@"M월 d일"];
            else
                retStr = [DateHelper dateStringFromDate:fromTime withFormat:@"yyyy년 M월 d일"];
        }
    }
    
    return retStr;
}

+ (NSString*)elapsedTimeStringWithTimeInterval:(NSTimeInterval)interval
{
    NSInteger hour = (NSInteger)(interval / 3600.0);
    NSInteger minutes = (NSInteger)(( interval - (hour * 3600.0) ) / 60.0);
    NSInteger seconds = (NSInteger)fmodf(interval, 60.0);
    
    return [NSString stringWithFormat:@"%02ld:%02ld':%02ld\"",(long)hour,(long)minutes,(long)seconds];
}

+ (NSString*)timeStringWithTimeInterval:(NSTimeInterval)interval
{
    NSInteger hour = (NSInteger)(interval / 3600.0);
    NSInteger minutes = (NSInteger)(( interval - (hour * 3600.0) ) / 60.0);
    NSInteger seconds = (NSInteger)fmodf(interval, 60.0);
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)minutes,(long)seconds];
}


+ (NSString *)stringByStrippingHTML:(NSString*)str
{
    NSRange r;
    NSString *s = [[NSString alloc] initWithString:str];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    s = [[[[[s stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "] stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"] stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    return s;
}

+ (NSInteger)generateRandomNumberFourDigit
{
    return ( (arc4random() % 9000) + 1000 );
}

+ (id)parseJsonObjectFromData:(id)data
{
    id jsonData = nil;
    if( [data isKindOfClass:[NSString class]] ){
        NSString *str = (NSString*)data;
        NSData *inputData = [str dataUsingEncoding:NSUTF8StringEncoding];
        jsonData = [NSJSONSerialization JSONObjectWithData:inputData options:0 error:nil];
    }
    else if( [data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSArray class]] ){
        jsonData = data;
    }
    else if( [data isKindOfClass:[NSData class]] ){
        jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    
    return jsonData;
}

+ (NSMutableDictionary*)parseWebParameter:(NSString*)query
{
    if( [query length] < 1 )
        return nil;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *components = [query componentsSeparatedByString:@"&"];
    
    for( NSString *str in components ){
        NSRange range = [str rangeOfString:@"="];
        if( NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) ) continue;
        
        NSString *key = [str substringToIndex:range.location];
        NSString *value = [str substringFromIndex:range.location + range.length];
        [dict setObject:( [value length] < 1 ? @"" : value ) forKey:key];
    }
    
    return dict;
}

+ (void)makeOutlineWithView:(UIView*)view outlineColor:(UIColor*)outlineColor outlineWidth:(CGFloat)outlineWidth cornerRadius:(CGFloat)cornerRadius
{
    view.layer.cornerRadius = cornerRadius;
    view.layer.borderColor = outlineColor.CGColor;
    view.layer.borderWidth = outlineWidth;
    view.layer.masksToBounds = YES;
}

/*
+ (NSDictionary*)dictionaryFromXmlString:(NSString*)string
{
    HTMLDocument *doc = [HTMLDocument documentWithString:string];
    HTMLElement *element = [doc firstNodeMatchingSelector:@"img"];
    return element.attributes;
//    NSString *sourceString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if( [sourceString length] < 1 )
//        return nil;
//
//    NSMutableDictionary *xmlDict = nil;
//    if( [[sourceString substringToIndex:1] isEqualToString:@"<"] ){
//        NSRange endRange = [sourceString rangeOfString:@"/>"];
//        if( NSEqualRanges(endRange, NSMakeRange(NSNotFound, 0)) )
//            endRange = [sourceString rangeOfString:@">"];
//
//        if( !NSEqualRanges(endRange, NSMakeRange(NSNotFound, 0)) ){
//            NSString *bodyString = [sourceString substringWithRange:NSMakeRange(1, endRange.location-1)];
//            NSInteger startIndex = 0;
//            NSRange searchRange = [bodyString rangeOfString:bodyString options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex, [bodyString length])];
//
//            while( !NSEqualRanges(searchRange, NSMakeRange(NSNotFound, 0)) ){
//                NSString *key = [[bodyString substringWithRange:NSMakeRange(startIndex, searchRange.location - startIndex)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                NSRange valueRange = [bodyString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"' "] options:NSCaseInsensitiveSearch range:NSMakeRange(searchRange.location+searchRange.length, [bodyString length] - (searchRange.location+searchRange.length))];
//                if( !NSEqualRanges(valueRange, NSMakeRange(NSNotFound, 0)) ){
//
//                }
//                else{
//                    break;
//                }
//            }
//        }
//    }
//
//    return xmlDict;
}
 */

+ (NSString*)userAgentString
{
    NSString *retString = [NSString stringWithFormat:@"%@/%@(%@)", [Utility bundleName], [Utility bundleShortVersion], [Utility bundleVersion]];
    return retString;
}

+ (UIViewController*)topMostViewController {
    return [self topMostViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topMostViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topMostViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topMostViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topMostViewControllerWithRootViewController:presentedViewController];
    }
    
    return rootViewController;
}

@end
