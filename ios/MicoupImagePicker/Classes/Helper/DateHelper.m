//
//  DateHelper.m
//
//  Created by coanyaa on
//

#import "DateHelper.h"

@implementation DateHelper

+ (NSString*)dateStringFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy. MM. dd. EEE"];
	return [df stringFromDate:date];
}

+ (NSString*)dateStringFromDate:(NSDate*)date withFormat:(NSString*)format
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:format];
	return [df stringFromDate:date];
}

+ (NSDate*)dateFromString:(NSString*)dateStr withFormat:(NSString *)format
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:format];
	
	return [df dateFromString:dateStr];
}

+ (BOOL)isAMDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"a"];
	NSString *str = [df stringFromDate:date];
	
	return [str isEqualToString:@"AM"];
}

+ (NSInteger)hour24FromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"HH"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)hour12FromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"hh"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)minuteFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"mm"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)secondFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"ss"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)yearFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)monthFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MM"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)dayFromDate:(NSDate*)date
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"dd"];
	NSString *str = [df stringFromDate:date];
	return [str intValue];
}

+ (NSInteger)weekdayFromDate:(NSDate*)date
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    
    return [comp weekday];
}

+ (NSInteger)getDaysFromTodayToDate:(NSDate*)goalDate
{
	if( goalDate == nil )
		return 0;
	NSDate* today = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *todayComponent = [[NSDateComponents alloc] init];
	[todayComponent setDay:[DateHelper dayFromDate:today]];
	[todayComponent setMonth:[DateHelper monthFromDate:today]];
	[todayComponent setYear:[DateHelper yearFromDate:today]];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitDay
												  fromDate:[calendar dateFromComponents:todayComponent]
													toDate:goalDate options:0];
	
	return [diffComponent day];
}

+ (NSInteger)diffDaysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
	if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitDay
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent day];
}

+ (NSInteger)diffWeeksFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitWeekOfYear
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent weekOfYear];
}

+ (NSInteger)diffMonthsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitMonth
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent month];
}

+ (NSInteger)diffYearsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    if( toDate == nil || fromDate == nil)
		return 0;
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitYear
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent year];
}

+ (NSInteger)diffSecondsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
	if( toDate == nil || fromDate == nil)
		return 0;
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *diffComponent = [calendar components:NSCalendarUnitSecond
												  fromDate:fromDate
													toDate:toDate options:0];
	
	return [diffComponent second];
}

+ (NSDate*)dateFromTodayByDays:(NSInteger)days
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setDay:days];
	return [calendar dateByAddingComponents:addComponent toDate:[NSDate date] options:0];
}

+ (NSDate*)dateFromTodayAndHour:(NSInteger)hour minute:(NSInteger)minute
{
	NSDate* today = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *todayComponent = [[NSDateComponents alloc] init];
	[todayComponent setDay:[DateHelper dayFromDate:today]];
	[todayComponent setMonth:[DateHelper monthFromDate:today]];
	[todayComponent setYear:[DateHelper yearFromDate:today]];
	[todayComponent setHour:hour];
	[todayComponent setMinute:minute];
	[todayComponent setSecond:0];
	
	return [calendar dateFromComponents:todayComponent];
}

+ (NSDate*)dateFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
	[dateComponent setDay:day];
	[dateComponent setMonth:month];
	[dateComponent setYear:year];
	[dateComponent setHour:hour];
	[dateComponent setMinute:minute];
	[dateComponent setSecond:second];
	
	return [calendar dateFromComponents:dateComponent];
}

+ (NSDate*)dateByAddingHours:(NSInteger)hours fromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *addComponent = [[NSDateComponents alloc] init];
    [addComponent setHour:hours];
    return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingDays:(NSInteger)days fromDate:(NSDate*)date
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setDay:days];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingYears:(NSInteger)years fromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setYear:years];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingMonth:(NSInteger)month fromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setMonth:month];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByAddingWeeks:(NSInteger)weeks fromDate:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setWeekOfYear:weeks];
	return [calendar dateByAddingComponents:addComponent toDate:date options:0];
}

+ (NSDate*)dateByDiffMonth:(NSInteger)diff atMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *addComponent = [[NSDateComponents alloc] init];
	[addComponent setMonth:diff];
	return [calendar dateByAddingComponents:addComponent toDate:month options:0];
}

+ (NSInteger)firstDayPositionOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *component = [[NSDateComponents alloc] init];
	[component setYear:[DateHelper yearFromDate:month]];
	[component setMonth:[DateHelper monthFromDate:month]];
	[component setDay:1];
	NSDate* date = [calendar dateFromComponents:component];
	component = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekdayOrdinal fromDate:date];
	
	return ([component weekday]-1);
}

+ (NSInteger)numberOfWeeksOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *startDate = [DateHelper dateFromYear:[DateHelper yearFromDate:month] month:[DateHelper monthFromDate:month] day:1 hour:12 minute:0 second:0];
	NSRange range = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:startDate];
	
	return range.length;
}

+ (NSInteger)lastDaysOfMonth:(NSDate*)month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *startDate = [DateHelper dateFromYear:[DateHelper yearFromDate:month] month:[DateHelper monthFromDate:month] day:1 hour:12 minute:0 second:0];
	NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:startDate];
	
	return range.length;
}

+ (NSDate*)dateMake12PM:(NSDate*)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    return [DateHelper dateFromYear:[comps year] month:[comps month] day:[comps day] hour:12 minute:0 second:0];
}

+ (NSDate*)dateMakeSecondZero:(NSDate*)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    return [DateHelper dateFromYear:[comps year] month:[comps month] day:[comps day] hour:[comps hour] minute:[comps minute] second:0];
}

+ (NSDate*)dateMakeMonthFirstDayAtDate:(NSDate*)date
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    return [DateHelper dateFromYear:[comps year] month:[comps month] day:1 hour:12 minute:0 second:0];
}

+ (NSDate*)dateMakeMonthLastDayAtDate:(NSDate*)date
{
    NSInteger lastday = [DateHelper lastDaysOfMonth:date];
    
    return [DateHelper dateFromYear:[DateHelper yearFromDate:date] month:[DateHelper monthFromDate:date] day:lastday hour:23 minute:59 second:59];
}

+ (NSDate*)dateMakeDate:(NSDate*)date Hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    return [DateHelper dateFromYear:[comps year] month:[comps month] day:[comps day] hour:hour minute:minute second:0];
}

+ (NSDateComponents*)dateComponentsFromDate:(NSDate*)date unitFlags:(NSUInteger)unitFlags
{
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:date];
}

+ (BOOL)isCurrentLocaleIsKorea
{
    return [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]	isEqualToString:@"KR"];
}

+ (NSDate*)firstNoWeekendFromAddingDays:(NSInteger)addingDays fromDate:(NSDate*)fromDate
{
    NSDate *retDate = nil;
    BOOL isFound = NO;
    do{
        retDate = [DateHelper dateByAddingDays:addingDays fromDate:fromDate];
        NSInteger weekday = [DateHelper weekdayFromDate:retDate];
        if( weekday == 1 )
            addingDays++;
        else
            isFound = YES;
    }while( !isFound );
    
    return retDate;
}


@end
