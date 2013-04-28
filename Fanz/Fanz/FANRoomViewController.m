//
//  FANRoomViewController.m
//  Fanz
//
//  Created by Ankur Oberoi on 4/28/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import "FANRoomViewController.h"
#import "FANAvatarView.h"

@interface FANRoomViewController ()

@end

@implementation FANRoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.titleBarView.image = [[UIImage imageNamed:@"title_bar_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 26.0, 0.0, 26.0)];
    
    self.homeTeamLocationLabel.text = self.room.homeTeam[@"location"];
    self.homeTeamNameLabel.text = self.room.homeTeam[@"name"];
    self.homeTeamScoreLabel.text = [NSString stringWithFormat:@"%d", self.room.homeTeam[@"score"] ];
    
    self.awayTeamLocationLabel.text = self.room.awayTeam[@"location"];
    self.awayTeamNameLabel.text = self.room.awayTeam[@"name"];
    //self.awayTeamScoreLabel.text = self.room.awayTeam[@"score"];
    self.awayTeamScoreLabel.text = [NSString stringWithFormat:@"%d", self.room.awayTeam[@"score"] ];
    
    
    //[self roomMemberArrived:@""];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)roomMemberArrived:(NSString *)data
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"FANAvatarView" owner:self options:nil];
    FANAvatarView *avatarView = [xib objectAtIndex:0];
    avatarView.frame = CGRectMake(0, 0, 125, 276);
    [self.view addSubview:avatarView];
}

- (IBAction)cheer:(id)sender {
}

- (IBAction)laugh:(id)sender {
}

- (IBAction)boo:(id)sender {
}

- (IBAction)wtf:(id)sender {
}
@end
