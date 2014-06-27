//
//  Tile.h
//  2048
//
//  Created by Leonard Li on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Tile : CCNode
@property (strong, nonatomic) CCLabelTTF *valueLabel;
@property (strong, nonatomic) CCNodeColor *backgroundNode;
@property (nonatomic) NSInteger value;
@property (nonatomic, assign) BOOL mergedThisRound;

- (void)updateValueDisplay;

@end
