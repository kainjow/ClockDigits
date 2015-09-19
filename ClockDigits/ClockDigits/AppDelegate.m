//
//  AppDelegate.m
//  ClockDigits
//
//  Created by Kevin Wojniak on 2/3/15.
//  Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@end

@implementation MyView
{
    NSTimer *_timer;
    int _counter;
}

- (void)viewDidMoveToWindow
{
    if (!self.window) {
        [_timer invalidate];
        _timer = nil;
    } else {
        _counter = 100;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSEventTrackingRunLoopMode];
    }
}

- (void)countdown
{
    --_counter;
    self.needsDisplay = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = self.bounds;
    
    const CGFloat width = 98;
    const CGFloat height = 16;
    const CGFloat arrowLength = height / 2;
    const CGFloat offset = height / 8;
    
    const CGFloat baseWidth = width + height + (offset * 2);
    const CGFloat baseHeight =  (height * 3) + ((width * 2) - (height + (offset * 4)));
    
    NSPoint (^makePoint)(CGFloat, CGFloat) = ^(CGFloat x, CGFloat y) {
        return NSMakePoint(ceil(x), ceil(y));
    };
    
    void (^part)(NSRect, int) = ^(NSRect area, int digit) {
        const CGFloat bottomStartX = area.origin.x + (area.size.width - width) / 2;
        NSBezierPath *bottomPath = [NSBezierPath bezierPath];
        [bottomPath moveToPoint:makePoint(bottomStartX, area.origin.y + (height / 2))];
        [bottomPath lineToPoint:makePoint(bottomStartX + arrowLength, area.origin.y + height)];
        [bottomPath lineToPoint:makePoint(bottomStartX + (width - arrowLength), area.origin.y + height)];
        [bottomPath lineToPoint:makePoint(bottomStartX + width, area.origin.y + (height / 2))];
        [bottomPath lineToPoint:makePoint(bottomStartX + (width - arrowLength), area.origin.y)];
        [bottomPath lineToPoint:makePoint(bottomStartX + arrowLength, area.origin.y)];
        [bottomPath closePath];
        
        NSBezierPath* (^transformPath)(CGFloat, NSPoint) = ^(CGFloat angle, NSPoint translate) {
            NSPoint tp;
            if (angle == 90) {
                tp = makePoint(bottomStartX, area.origin.y + (height / 2));
            } else {
                tp = makePoint(bottomStartX + width, area.origin.y + (height / 2));
            }
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy:tp.x yBy:tp.y];
            [transform rotateByDegrees:angle];
            [transform translateXBy:-tp.x yBy:-tp.y];
            NSBezierPath *newPath = [bottomPath copy];
            [newPath transformUsingAffineTransform:transform];
            transform = [NSAffineTransform transform];
            [transform translateXBy:translate.x yBy:translate.y];
            [newPath transformUsingAffineTransform:transform];
            return newPath;
        };
        
        NSBezierPath *midPath = transformPath(0, NSMakePoint(0, (offset * 2) + width));
        NSBezierPath *topPath = transformPath(0, NSMakePoint(0, (offset * 4) + (width * 2)));
        NSBezierPath *bottomLeftPath = transformPath(90, NSMakePoint(-offset, offset));
        NSBezierPath *topLeftPath = transformPath(90, NSMakePoint(-offset, (offset * 3) + width));
        NSBezierPath *bottomRightPath = transformPath(-90, NSMakePoint(offset, offset));
        NSBezierPath *topRightPath = transformPath(-90, NSMakePoint(offset, (offset * 3) + width));
        
        NSArray *paths;
        switch (digit) {
            case 0:
                paths = @[bottomPath, bottomLeftPath, bottomRightPath, topPath, topLeftPath, topRightPath];
                break;
            case 1:
                paths = @[topRightPath, bottomRightPath];
                break;
            case 2:
                paths = @[bottomPath, bottomLeftPath, midPath, topPath, topRightPath];
                break;
            case 3:
                paths = @[bottomPath, bottomRightPath, midPath, topPath, topRightPath];
                break;
            case 4:
                paths = @[bottomRightPath, midPath, topLeftPath, topRightPath];
                break;
            case 5:
                paths = @[bottomPath, bottomRightPath, midPath, topPath, topLeftPath];
                break;
            case 6:
                paths = @[bottomPath, bottomLeftPath, bottomRightPath, midPath, topPath, topLeftPath];
                break;
            case 7:
                paths = @[bottomRightPath, topPath, topRightPath];
                break;
            case 8:
                paths = @[bottomPath, bottomLeftPath, bottomRightPath, midPath, topPath, topLeftPath, topRightPath];
                break;
            case 9:
                paths = @[bottomPath, bottomRightPath, midPath, topPath, topLeftPath, topRightPath];
                break;
            default:
                NSLog(@"Invalid digit '%d'", digit);
                return;
        }
        
        for (NSBezierPath *p in paths) {
            [p fill];
        }
    };
    
    [[NSColor blackColor] set];
    [NSBezierPath fillRect:bounds];
    
    NSMutableArray *digits = [NSMutableArray array];
    
    NSInteger hour, minute, second;
    [[NSCalendar currentCalendar] getHour:&hour minute:&minute second:&second nanosecond:NULL fromDate:[NSDate date]];
    if (hour > 12) {
        hour -= 12;
    }
    for (NSInteger val = _counter; val > 0; val /= 10) {
        [digits insertObject:@(val % 10) atIndex:0];
    }
    const NSUInteger numDigits = digits.count;
    const CGFloat spacing = 22;
    CGFloat allWidth = baseWidth * numDigits;
    if (numDigits > 1) {
        allWidth += ((numDigits - 1) * spacing);
    }
    NSRect baseArea = NSMakeRect(NSMaxX(bounds) - (allWidth + spacing),
                                 bounds.origin.y + (bounds.size.height - baseHeight) / 2,
                                 allWidth, baseHeight);
    NSRect partRect = baseArea;
    partRect.size.width = baseWidth;
    [[NSColor greenColor] set];
    for (NSNumber *digit in digits) {
        part(partRect, digit.intValue);
        partRect.origin.x += baseWidth + spacing;
    }
}

@end

int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}
