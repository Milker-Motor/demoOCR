//
//  ViewController.m
//  demo OCR
//
//  Created by o.lytvynov-bogdanov on 15.06.16.
//  Copyright © 2016 o.lytvynov-bogdanov. All rights reserved.
//

#import "ViewController.h"
#import "takePictureViewController.h"
#import "MAddContactTableViewController.h"
#import "RecognitionViewController.h"


//static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface ViewController ()
{
    CRecognitionViewController* mainRecognitionController;
}

@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMainRecognitioncontroller
{
    if(mainRecognitionController == nil) {
        mainRecognitionController = [[CRecognitionViewController alloc] init];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqual:@"takePicture"])
    {
        takePictureViewController *vc = [segue destinationViewController];
        vc.parent = self;
    }
    
    if ([[segue identifier] isEqualToString:@"recognizeImage"])
    {
        MAddContactTableViewController *vc = [segue destinationViewController];
        [self loadMainRecognitioncontroller];
        
        mainRecognitionController.parent = vc;
        [mainRecognitionController recognizeBusinessCard:_mainImageView.image];
    }
}

- (void) setMainImage:(UIImage *) image
{
    _mainImageView.image = image;
}



@end
