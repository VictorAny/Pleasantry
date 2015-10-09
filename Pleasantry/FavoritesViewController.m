//
//  FavoritesViewController.m
//  Pleasantry
//
//  Created by Victor Anyirah on 10/4/15.
//  Copyright (c) 2015 Victor Anyirah. All rights reserved.
//

#import "FavoritesViewController.h"
#import "PleasantTableViewCell.h"

static NSString *cellIdentifier = @"favoriteCell";

@interface FavoritesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *favoritesTable;
@property (strong, nonatomic) NSMutableArray *favorites;
@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.favoritesTable.dataSource = self;
    self.favoritesTable.delegate = self;
    [self.favoritesTable registerNib:[UINib nibWithNibName:@"PleasantTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.favoritesTable.rowHeight = 350;
    self.favoritesTable.allowsSelection = NO;

    
}
// Loads favorites to be shown in table
- (void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.favorites = [defaults valueForKey:@"favorites"];
    [self.favoritesTable reloadData];
}

#pragma mark - Tableview Delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PleasantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *favoriteFlick = [self.favorites objectAtIndex:indexPath.row];
    cell.title.text = [favoriteFlick valueForKey:@"title"];
    NSString *url = [[self.favorites objectAtIndex:indexPath.row]valueForKey:@"data"];
    cell.photoView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    cell.favorite.enabled = NO;
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.favorites count];
}

@end
