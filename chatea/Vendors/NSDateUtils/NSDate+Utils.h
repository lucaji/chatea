//
//  NSDate+Utils.h
//  BloodSugar
//
//  Created by PeterPan on 13-12-27.
//  Copyright (c) 2013年 shake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDate (Utils)

+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day
                    hour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second;

+ (NSInteger)daysOffsetBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

+ (NSDate *)dateWithHour:(int)hour
                  minute:(int)minute;

#pragma mark - Getter
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger year;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger month;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger day;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger hour;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger minute;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger second;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *weekday;


#pragma mark - Time string
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *timeHourMinute;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *timeHourMinuteWithPrefix;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *timeHourMinuteWithSuffix;
- (NSString *)timeHourMinuteWithPrefix:(BOOL)enablePrefix suffix:(BOOL)enableSuffix;

#pragma mark - Date String
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringTime;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringMonthDay;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringYearMonthDay;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringYearMonthDayHourMinuteSecond;
+ (NSString *)stringYearMonthDayWithDate:(NSDate *)date;      //date为空时返回的是当前年月日
+ (NSString *)stringLoacalDate;

#pragma mark - Date formate
+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)timestampFormatStringSubSeconds;

#pragma mark - Date adjust
- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;

#pragma mark - Relative dates from the date
+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;
+ (NSDate *) dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days;
+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours;
+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours;
+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes;
+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes;
+ (NSDate *) dateStandardFormatTimeZeroWithDate: (NSDate *) aDate;  //Zero standard format date
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger daysBetweenCurrentDateAndDate;                     //负数为过去，正数为未来

#pragma mark - Date compare
- (BOOL)isEqualToDateIgnoringTime: (NSDate *) aDate;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringYearMonthDayCompareToday;                 //返回“今天”，“明天”，“昨天”，或年月日

#pragma mark - Date and string convert
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *string;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringCutSeconds;

@end
