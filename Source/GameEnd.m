//
//  GameEnd.m
//  2048
//
//  Created by Leonard Li on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameEnd.h"

@interface GameEnd()
@property (strong, nonatomic) CCLabelTTF *messageLabel;
@property (strong, nonatomic) CCLabelTTF *scoreLabel;

@end

@implementation GameEnd

- (void)newGame {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

- (void)setMessage:(NSString *)message score:(NSInteger)score {
    self.messageLabel.string = message;
    self.scoreLabel.string = [NSString stringWithFormat:@"%d", score];
}


@end
