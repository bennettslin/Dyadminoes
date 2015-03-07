//
//  HelpContentViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/28/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "HelpContentViewController.h"

@interface HelpContentViewController ()

@property (strong, nonatomic) NSArray *textViews;
@property (strong, nonatomic) NSArray *imageViews;

@end

@implementation HelpContentViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {

  }
  return self;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor clearColor];
  [self createTextViews];
}

-(void)createTextViews {
  
  NSMutableArray *tempTextViews = [NSMutableArray new];
  NSArray *textViewTexts = [self textViewTextsForPage:self.pageIndex];
  
  for (int i = 0; i < textViewTexts.count; i++) {
    UITextView *textView = [UITextView new];
    textView.text = textViewTexts[i];
    textView.textColor = kPlayerDarkRed;
    textView.userInteractionEnabled = NO;
    textView.font = [UIFont fontWithName:kFontModern size:kChildVCButtonSize * 0.45];
    textView.textAlignment = NSTextAlignmentJustified;
    textView.backgroundColor = [UIColor clearColor];
    textView.layer.borderColor = [UIColor redColor].CGColor;
    textView.layer.borderWidth = 2.f;
    textView.frame = CGRectMake(0, 0, self.parentViewController.view.frame.size.width - (kChildVCSideMargin * 2), kChildVCButtonSize * 0.45);
    [textView sizeToFit];
    [tempTextViews addObject:textView];
    [self.view addSubview:textView];
  }
  
  self.textViews = [NSArray arrayWithArray:tempTextViews];
}

-(void)viewWillAppear:(BOOL)animated {
  
  [self centreTextViewsAndImageViews];
}

-(void)centreTextViewsAndImageViews {
  
  CGFloat yOrigin = 0;
  for (int i = 0; i < self.textViews.count; i++) {
    UITextView *textView = self.textViews[i];
    
    textView.frame = CGRectMake(kChildVCSideMargin, yOrigin, textView.frame.size.width, textView.frame.size.height);
    
    yOrigin += textView.frame.size.height;
  }
}

-(NSArray *)imageViewNamesForPage:(NSUInteger)pageIndex {
  NSArray *imageViews;
  switch (pageIndex) {
    case 0:
      imageViews = @[];
      break;
    case 1:
      imageViews = @[];
      break;
    case 2:
      imageViews = @[];
      break;
    case 3:
      imageViews = @[];
      break;
    default:
      break;
  }
  return imageViews;
}

-(NSArray *)textViewTextsForPage:(NSUInteger)pageIndex {
  NSArray *textViews;
  switch (pageIndex) {
    case 0:
      textViews = @[@"Play one dyadmino at a time from your rack onto the board. Each dyadmino must form at least one new chord.", @"The order of notes in a chord does not matter. However, notes cannot repeat.", @"Dyadminoes already played on the board can be freely rotated and rearranged, as long as they do not break existing chords.", @"Incomplete chords can be freely broken and made. This includes any two distinct notes.", @"Combinations of notes that are not part of any legal chord cannot be made."];
      break;
    case 1:
      textViews = @[@"Each new triad is 2 points. Each new seventh chord is 3 points.", @"Each new seventh chord built from an existing triad is 1 point.", @"Incomplete chords score no points.", @"Use up all six dyadminoes in your rack in one turn for a 5-point bonus.", @"The game ends if a) one player runs out of dyadminoes, b) all players pass twice with dyadminoes left in the pile, c) all players pass once with no dyadminoes left in the pile. The player with the highest score wins!"];
      break;
    case 2:
      textViews = @[@"There are 5 possible triads that can be formed, transposable to any key."];
      break;
    case 3:
      textViews = @[@"Similarly, there are 8 possible seventh chords."];
      break;
    case 4:
      textViews = @[@"There are 66 dyadminoes in the pile."];
      break;
    default:
      break;
  }
  return textViews;
}

-(NSString *)titleTextBasedOnPageIndex {
  NSString *titleLabelText;
  switch (self.pageIndex) {
    case 0:
      titleLabelText = @"Placement Rules";
      break;
    case 1:
      titleLabelText = @"Scoring and Winning";
      break;
    case 2:
      titleLabelText = @"Legal Triads";
      break;
    case 3:
      titleLabelText = @"Legal Seventh Chords";
      break;
    case 4:
      titleLabelText = @"Dyadminoes";
      break;
    default:
      break;
  }
  return titleLabelText;
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
