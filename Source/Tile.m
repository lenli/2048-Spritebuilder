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
        self.value = (arc4random()%2+1)*2;
    }
    return self;
}

- (void)updateValueDisplay {
    self.valueLabel.string = [NSString stringWithFormat:@"%d", self.value];
}

- (void)didLoadFromCCB {
    [self updateValueDisplay];
}

@end
