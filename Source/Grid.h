//
//  Grid.h
//  2048
//
//  Created by Leonard Li on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNodeColor.h"

static const NSInteger GRID_SIZE = 4;
static const NSInteger START_TILES = 2;
static const NSInteger WIN_TILE = 2048;

@interface Grid : CCNodeColor
@property (nonatomic, assign) NSInteger score;

@end
