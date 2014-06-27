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

@interface Grid : CCNodeColor
@property (nonatomic) CGFloat columnWidth;
@property (nonatomic) CGFloat columnHeight;
@property (nonatomic) CGFloat tileMarginVertical;
@property (nonatomic) CGFloat tileMarginHorizontal;

@end
