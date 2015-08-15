//
//  HNAppearance.m
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

#import "HNAppearance.h"
#import <TSMessages/TSMessageView.h>
#import "HackerNews-Swift.h"
#import <Colours/Colours.h>

@implementation HNAppearance

+(void)setAppearances
{
    [[TSMessageView appearance] setTitleFont:[UIFont textFont]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor textColor]];
    [[TSMessageView appearance] setBackgroundColor:[UIColor warningColor]];
}

@end
