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
			self.gridArray[i][j] = self.noTile;
		}
	}
	[self spawnStartTiles];
    
    [self setupGestureRecognizers];
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

- (void)setupGestureRecognizers {
    // listen for swipes to the left
    UISwipeGestureRecognizer * swipeLeft= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];
    // listen for swipes to the right
    UISwipeGestureRecognizer * swipeRight= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
    // listen for swipes up
    UISwipeGestureRecognizer * swipeUp= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUp)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
    // listen for swipes down
    UISwipeGestureRecognizer * swipeDown= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];

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
		BOOL positionFree = (self.gridArray[randomColumn][randomRow] == self.noTile);
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

- (void)move:(CGPoint)direction {
    BOOL movedTilesThisRound = NO;
    
    // apply negative vector until reaching boundary, this way we get the tile that is the furthest away
    //bottom left corner
    NSInteger currentX = 0;
    NSInteger currentY = 0;
    // Move to relevant edge by applying direction until reaching border
    while ([self indexValid:currentX y:currentY]) {
        CGFloat newX = currentX + direction.x;
        CGFloat newY = currentY + direction.y;
        if ([self indexValid:newX y:newY]) {
            currentX = newX;
            currentY = newY;
        } else {
            break;
        }
    }
    // store initial row value to reset after completing each column
    NSInteger initialY = currentY;
    // define changing of x and y value (moving left, up, down or right?)
    NSInteger xChange = -direction.x;
    NSInteger yChange = -direction.y;
    if (xChange == 0) {
        xChange = 1;
    }
    if (yChange == 0) {
        yChange = 1;
    }
    // visit column for column
    while ([self indexValid:currentX y:currentY]) {
        while ([self indexValid:currentX y:currentY]) {
            // get tile at current index
            Tile *tile = self.gridArray[currentX][currentY];
            if ([tile isEqual:self.noTile]) {
                // if there is no tile at this index -> skip
                currentY += yChange;
                continue;
            }
            // store index in temp variables to change them and store new location of this tile
            NSInteger newX = currentX;
            NSInteger newY = currentY;
            /* find the farthest position by iterating in direction of the vector until we reach border of grid or an occupied cell*/
            while ([self indexValidAndUnoccupied:newX+direction.x y:newY+direction.y]) {
                newX += direction.x;
                newY += direction.y;
            }

            BOOL performMove = FALSE;
            /* If we stopped moving in vector direction, but next index in vector direction is valid, this means the cell is occupied. Let's check if we can merge them*/
            if ([self indexValid:newX+direction.x y:newY+direction.y]) {
                // get the other tile
                NSInteger otherTileX = newX + direction.x;
                NSInteger otherTileY = newY + direction.y;
                Tile *otherTile = self.gridArray[otherTileX][otherTileY];
                // compare value of other tile and also check if the other thile has been merged this round
                if (tile.value == otherTile.value && !otherTile.mergedThisRound) {
                    // merge tiles
                    [self mergeTileAtIndex:currentX y:currentY withTileAtIndex:otherTileX y:otherTileY];
                    movedTilesThisRound = YES;
                } else {
                    // we cannot merge so we want to perform a move
                    performMove = TRUE;
                }
            } else {
                // we cannot merge so we want to perform a move
                performMove = TRUE;
            }
            if (performMove) {
                // Move tile to furthest position
                if (newX != currentX || newY !=currentY) {
                    // only move tile if position changed
                    [self moveTile:tile fromIndex:currentX oldY:currentY newX:newX newY:newY];
                    movedTilesThisRound = YES;
                }
            }
            
            // move further in this column
            currentY += yChange;
        }
        // move to the next column, start at the inital row
        currentX += xChange;
        currentY = initialY;
    }
    
    if (movedTilesThisRound) {
        [self nextRound];
    }
}

- (BOOL)indexValid:(NSInteger)x y:(NSInteger)y {
    BOOL indexValid = TRUE;
    indexValid &= x >= 0;
    indexValid &= y >= 0;
    if (indexValid) {
        indexValid &= x < (int) [self.gridArray count];
        if (indexValid) {
            indexValid &= y < (int) [(NSMutableArray*) self.gridArray[x] count];
        }
    }
    return indexValid;
}

- (void)moveTile:(Tile *)tile fromIndex:(NSInteger)oldX oldY:(NSInteger)oldY newX:(NSInteger)newX newY:(NSInteger)newY {
    self.gridArray[newX][newY] = self.gridArray[oldX][oldY];
    self.gridArray[oldX][oldY] = self.noTile;
    CGPoint newPosition = [self positionForColumn:newX row:newY];
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:newPosition];
    [tile runAction:moveTo];
}

- (BOOL)indexValidAndUnoccupied:(NSInteger)x y:(NSInteger)y {
    BOOL indexValid = [self indexValid:x y:y];
    if (!indexValid) {
        return FALSE;
    }
    BOOL unoccupied = [self.gridArray[x][y] isEqual:self.noTile];
    return unoccupied;
}

- (void)mergeTileAtIndex:(NSInteger)x y:(NSInteger)y withTileAtIndex:(NSInteger)xOtherTile y:(NSInteger)yOtherTile {
    // 1) update the game data
    Tile *mergedTile = self.gridArray[x][y];
    Tile *otherTile = self.gridArray[xOtherTile][yOtherTile];
    otherTile.mergedThisRound = YES;
    
    otherTile.value *= 2;
    self.gridArray[x][y] = self.noTile;
    // 2) update the UI
    CGPoint otherTilePosition = [self positionForColumn:xOtherTile row:yOtherTile];
    CCActionMoveTo *moveTo = [CCActionMoveTo actionWithDuration:0.2f position:otherTilePosition];
    CCActionRemove *remove = [CCActionRemove action];
    CCActionCallBlock *mergeTile = [CCActionCallBlock actionWithBlock:^{
        [otherTile updateValueDisplay];
    }];
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[moveTo, mergeTile, remove]];
    [mergedTile runAction:sequence];
}

- (void)nextRound {
    [self spawnRandomTile];
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            Tile *tile = self.gridArray[i][j];
            if (![tile isEqual:_noTile]) {
                // reset merged flag
                tile.mergedThisRound = NO;
            }
        }
    }
}

#pragma mark - Gesture Recognizer Methods

- (void)swipeLeft {
    [self move:ccp(-1, 0)];
}
- (void)swipeRight {
    [self move:ccp(1, 0)];
}
- (void)swipeDown {
    [self move:ccp(0, -1)];
}
- (void)swipeUp {
    [self move:ccp(0, 1)];
}

@end
