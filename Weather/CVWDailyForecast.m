//
//  CVWDailyForecast.m
//  Weather
//
//  Created by Matt Clarke on 15/02/2014.
//
//

#import "CVWDailyForecast.h"

@implementation CVWDailyForecast

-(id)initWithDay:(int)dayInt icon:(int)condition high:(NSString*)high andLow:(NSString*)low {
    self = [super initWithFrame:CGRectMake(0, 0, 50, 70)];
    if (self) {
        // Initialization code
        // Localised bundle
        NSBundle *strings = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Weather.framework"];
        
        // Day
        NSString *dayString;
        switch (dayInt) {
            case 1:
                dayString = [strings localizedStringForKey:@"SUN" value:@"SUN" table:@"WeatherFrameworkLocalizableStrings"];
                break;
                
            case 2:
                dayString = [strings localizedStringForKey:@"MON" value:@"MON" table:@"WeatherFrameworkLocalizableStrings"];
                break;
                
            case 3:
                dayString = [strings localizedStringForKey:@"TUE" value:@"TUE" table:@"WeatherFrameworkLocalizableStrings"];
                break;
                
            case 4:
                dayString = [strings localizedStringForKey:@"WED" value:@"WED" table:@"WeatherFrameworkLocalizableStrings"];
                break;
                
            case 5:
                dayString = [strings localizedStringForKey:@"THU" value:@"THU" table:@"WeatherFrameworkLocalizableStrings"];
                break;
            
            case 6:
                dayString = [strings localizedStringForKey:@"FRI" value:@"FRI" table:@"WeatherFrameworkLocalizableStrings"];
                break;
                
            case 7:
                dayString = [strings localizedStringForKey:@"SAT" value:@"SAT" table:@"WeatherFrameworkLocalizableStrings"];
                break;
                
            default:
                dayString = [strings localizedStringForKey:@"SUN" value:@"SUN" table:@"WeatherFrameworkLocalizableStrings"];
                break;
        }
        
        UILabel *day = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 25)];
        day.text = dayString;
        day.backgroundColor = [UIColor clearColor];
        day.textAlignment = NSTextAlignmentCenter;
        day.textColor = [UIColor darkGrayColor];
        day.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        day.clipsToBounds = NO;
        day.opaque = NO;
        day.center = CGPointMake(self.center.x, 13);

        [self addSubview:day];
        
        // Icon
        NSString *iconPath = [NSString stringWithFormat:@"/var/mobile/Library/Convergance/LockWidgets.bundle/com.matchstic.Weather/Icons/%d.png", condition];
        UIImage *img = [UIImage imageWithContentsOfFile:iconPath];
        CGSize newSize = CGSizeMake(40, 30);
        
        if (img) {
            UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
        
            CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
            [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        
            UIImageView *icon = [[UIImageView alloc] initWithImage:newimg];
            icon.frame = CGRectMake(0, 0, 40, 30);
            icon.backgroundColor = [UIColor clearColor];
            icon.opaque = NO;
            icon.center = CGPointMake(self.center.x, self.center.y+4);
        
            [self addSubview:icon];
            
            newimg = nil;
        }
        
        img = nil;
        
        // Hi/Lo
        UILabel *slash = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 5, 15)];
        slash.text = @"|";
        slash.backgroundColor = [UIColor clearColor];
        slash.textColor = [UIColor lightGrayColor];
        slash.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        slash.clipsToBounds = NO;
        slash.opaque = NO;
        slash.textAlignment = NSTextAlignmentCenter;
        slash.center = CGPointMake(self.center.x, self.frame.size.height-7.5);
        
        [self addSubview:slash];
        
        UILabel *hi = [[UILabel alloc] initWithFrame:CGRectMake(-5, self.frame.size.height-15, 25, 15)];
        hi.text = [NSString stringWithFormat:@"%@", high];
        hi.backgroundColor = [UIColor clearColor];
        hi.textColor = [UIColor darkGrayColor];
        hi.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        hi.clipsToBounds = NO;
        hi.opaque = NO;
        hi.textAlignment = NSTextAlignmentRight;
        
        [self addSubview:hi];

        UILabel *lo = [[UILabel alloc] initWithFrame:CGRectMake(30, self.frame.size.height-15, 25, 15)];
        lo.text = [NSString stringWithFormat:@"%@", low];
        lo.backgroundColor = [UIColor clearColor];
        lo.textColor = [UIColor grayColor];
        lo.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        lo.clipsToBounds = NO;
        lo.opaque = NO;
        lo.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:lo];
    }
    return self;
}

@end
