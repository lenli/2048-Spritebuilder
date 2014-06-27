//
//  Grid.m
//  2048
//
//  Created by Leonard Li on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Tile.h"

@interface Grid()
@property (strong, nonatomic) NSMutableArray *gridArray;
@property (strong, nonatomic) NSNull *noTile;

@end

@implementation Grid

- (void)didLoadFromCCB {
	[self setupBackground];
	self.noTile = [NSNull null];
	self.gridArray = [NSMutableArray array];
	for (int i = 0; i < GRID_SIZE; i++) {
		self.gridArray[i] = [NSMutableArray array];
		for (int j = 0; j < GRID_SIZE; j++) {
			self.gridArray[i][j] = _noTile;
		}
	}
	[self spawnStartTiles];
}

- (void)setupBackground
{
	// load one tile to read the dimensions
	CCNode *tile = [CCBReader load:@"Tile"];
	self.columnWidth = tile.contentSize.width;
	self.columnHeight = tile.contentSize.height;

    // this hotfix is needed because of issue #638 in Cocos2D 3.1 / SB 1.1 (https://github.com/spritebuilder/SpriteBuilder/issues/638)
    [tile performSelector:@selector(cleanup)];

	// calculate the margin by subtracting the tile sizes from the grid size
	self.tileMarginHorizontal = (self.contentSize.width - (GRID_SIZE * self.columnWidth)) / (GRID_SIZE+1);
	self.tileMarginVertical = (self.contentSize.height - (GRID_SIZE * self.columnHeight)) / (GRID_SIZE+1);

	// set up initial x and y positions
	float x = self.tileMarginHorizontal;
	float y = self.tileMarginVertical;
	for (int i = 0; i < GRID_SIZE; i++) {
		for (int j = 0; j < GRID_SIZE; j++) {
			CCNodeColor *backgroundTile = [CCNodeColor nodeWithColor:[CCColor blueColor]];
			backgroundTile.contentSize = CGSizeMake(self.columnWidth, self.columnHeight);
			backgroundTile.position = ccp(x, y);
			[self addChild:backgroundTile];
			x+= self.columnWidth + self.tileMarginHorizontal;
		}
        x = self.tileMarginHorizontal;
		y += self.columnHeight + self.tileMarginVertical;
	}
}

#pragma mark - Grid Helper Methods

- (CGPoint)positionForColumn:(NSInteger)column
                         row:(NSInteger)row {
    NSInteger x = self.tileMarginHorizontal + column * (self.tileMarginHorizontal + self.columnWidth);
    NSInteger y = self.tileMarginVertical + row * (self.tileMarginVertical + self.columnHeight);
    return CGPointMake(x,y);
}

- (void)addTileAtColumn:(NSInteger)column
                  atRow:(NSInteger)row {
    Tile *tile = (Tile *)[CCBReader load:@"Tile"];
    self.gridArray[column][row] = tile;
    tile.scale = 0.f;
    tile.position = [self positionForColumn:column row:row];
    [self addChild:tile];
    
	CCActionDelay *delay = [CCActionDelay actionWithDuration:0.3f];
	CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.2f scale:1.f];
	CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, scaleUp]];
	[tile runAction:sequence];
}

- (void)spawnRandomTile {
	BOOL spawned = FALSE;
	while (!spawned) {
		NSInteger randomRow = arc4random() % GRID_SIZE;
		NSInteger randomColumn = arc4random() % GRID_SIZE;
		BOOL positionFree = (_gridArray[randomColumn][randomRow] == _noTile);
		if (positionFree) {
			[self addTileAtColumn:randomColumn atRow:randomRow];
			spawned = TRUE;
		}
	}
}

- (void)spawnStartTiles {
	for (int i = 0; i < START_TILES; i++) {
		[self spawnRandomTile];
	}
}

@end
