//
//  MainTableViewController.m
//  Dyadminoes
//
//  Created by Bennett Lin on 5/19/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MainTableViewController.h"
#import "Model.h"
#import "NSObject+Helper.h"
#import "MatchTableViewCell.h"
#import "DebugViewController.h"

@interface MainTableViewController () <DebugDelegate>

@property (strong, nonatomic) Model *myModel;

@end

@implementation MainTableViewController

-(id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {

  }
  return self;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
    // instantiates matches only on very first launch
  NSString *path = [self dataFilePath];
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    [self loadSettingsFromPath:path];
  } else { // no file present, instantiate with hard code for now
    self.myModel = [[Model alloc] init];
    [self.myModel instantiateHardCodedMatchesForDebugPurposes];
//    NSLog(@"myMatches %@", self.myModel.myMatches);
  }
}

-(void)viewWillAppear:(BOOL)animated {
  [self.myModel sortMyMatches];
  [self.tableView reloadData];
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.myModel.myMatches.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"matchCell";
  MatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  cell.myMatch = self.myModel.myMatches[indexPath.row];
  [cell setProperties];
  
  return cell;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"sceneSegue"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Match *match = self.myModel.myMatches[indexPath.row];
    DebugViewController *debugVC = [segue destinationViewController];
    debugVC.myMatch = match;
    debugVC.delegate = self;
  }
}

#pragma mark - archiver methods

-(NSString *)documentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths firstObject];
}

-(NSString *)dataFilePath {
  return [[self documentsDirectory] stringByAppendingPathComponent:@"Dyadminoes.plist"];
}

-(void)saveSettings {
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
  [archiver encodeObject:self.myModel.myMatches forKey:kMatchesKey];
  [archiver finishEncoding];
  [data writeToFile:[self dataFilePath] atomically:YES];
}

-(void)loadSettingsFromPath:(NSString *)path {
//  NSLog(@"file path is %@", path);
  NSData *data = [[NSData alloc] initWithContentsOfFile:path];
  NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
  self.myModel.myMatches = [unarchiver decodeObjectForKey:kMatchesKey];
  [unarchiver finishDecoding];
}

@end
