//
//  CVWDailyForecast.h
//  Weather
//
//  Created by Matt Clarke on 15/02/2014.
//
//

#import <UIKit/UIKit.h>

@interface CVWDailyForecast : UIView

-(id)initWithDay:(int)day icon:(int)condition high:(NSString*)high andLow:(NSString*)low;

@end
