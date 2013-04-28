//
//  FANRoomViewController.h
//  Fanz
//
//  Created by Ankur Oberoi on 4/28/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FANRoom.h"

@interface FANRoomViewController : UIViewController

@property (strong, nonatomic) FANRoom *room;

@property (weak, nonatomic) IBOutlet UIImageView *titleBarView;

@property (weak, nonatomic) IBOutlet UILabel *homeTeamLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamScoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *homeTeamLogoView;

@property (weak, nonatomic) IBOutlet UILabel *awayTeamLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamScoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *awayTeamLogoView;

@property (weak, nonatomic) IBOutlet UILabel *latestPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *latestPlayerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *latestPlayerImageView;

- (IBAction)cheer:(id)sender;
- (IBAction)laugh:(id)sender;
- (IBAction)boo:(id)sender;
- (IBAction)wtf:(id)sender;


@end
