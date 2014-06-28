//
//  Tile.m
//  2048
//
//  Created by Leonard Li on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Tile.h"
@implementation Tile

- (instancetype)init {
    self = [super init];
    if (self) {
        self.value = (arc4random()%2+1)*3;
    }
    return self;
}

- (void)updateValueDisplay {
    self.valueLabel.string = [NSString stringWithFormat:@"%d", self.value];
    CCColor *backgroundColor = nil;
    switch (self.value) {
        case 3:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:20.f/255.f blue:80.f/255.f];
            break;
        case 6:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:20.f/255.f blue:140.f/255.f];
            break;
        case 12:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:60.f/255.f blue:220.f/255.f];
            break;
        case 24:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:120.f/255.f blue:120.f/255.f];
            break;
        case 48:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:160.f/255.f blue:120.f/255.f];
            break;
        case 96:
            backgroundColor = [CCColor colorWithRed:20.f/255.f green:160.f/255.f blue:60.f/255.f];
            break;
        case 384:
            backgroundColor = [CCColor colorWithRed:50.f/255.f green:160.f/255.f blue:60.f/255.f];
            break;
        case 768:
            backgroundColor = [CCColor colorWithRed:80.f/255.f green:120.f/255.f blue:60.f/255.f];
            break;
        case 1536:
            backgroundColor = [CCColor colorWithRed:140.f/255.f green:70.f/255.f blue:60.f/255.f];
            break;
        case 3072:
            backgroundColor = [CCColor colorWithRed:170.f/255.f green:30.f/255.f blue:60.f/255.f];
            break;
        case 6144:
            backgroundColor = [CCColor colorWithRed:220.f/255.f green:30.f/255.f blue:30.f/255.f];
            break;
        default:
            backgroundColor = [CCColor greenColor];
            break;
    }
    self.backgroundNode.color = backgroundColor;
    
}

- (void)didLoadFromCCB {
    [self updateValueDisplay];
}

@end
