//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Grid.h"

@interface MainScene()
@property (strong, nonatomic) Grid *grid;
@property (strong, nonatomic) CCLabelTTF *scoreLabel;
@property (strong, nonatomic) CCLabelTTF *highscoreLabel;

@end

@implementation MainScene

- (void)didLoadFromCCB {
    [_grid addObserver:self forKeyPath:@"score" options:0 context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"score"]) {
        self.scoreLabel.string = [NSString stringWithFormat:@"%d", self.grid.score];
    }
}

- (void)dealloc {
    [self.grid removeObserver:self forKeyPath:@"score"];
}

@end
