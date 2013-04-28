//
//  FANIntroViewController.m
//  Fanz
//
//  Created by Ankur Oberoi on 4/27/13.
//  Copyright (c) 2013 Ankur Oberoi. All rights reserved.
//

#import "FANIntroViewController.h"

@interface FANIntroViewController ()

@end

@implementation FANIntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // assign a background image
    self.backgroundImageView.image = [[UIImage imageNamed:@"intro_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(24.0, 24.0, 24.0, 24.0)
                                                         resizingMode:UIImageResizingModeStretch];
    
    // assign the title image
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
