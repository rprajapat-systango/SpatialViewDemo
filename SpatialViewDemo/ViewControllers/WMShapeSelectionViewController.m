//
//  WMShapeSelectionViewController.m
//  SpatialViewDemo
//
//  Created by SGVVN on 13/08/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMShapeSelectionViewController.h"
#import "WMShapeSelectionTableViewCell.h"

@interface WMShapeSelectionViewController (){
    NSArray *arrItems;
}

@end

@implementation WMShapeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrItems = @[@"RECTANGLE", @"ELLIPSE", @"DIAMOND", @"TRIANGLE"];
    // Do any additional setup after loading the view.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMShapeSelectionTableViewCell *cell = (WMShapeSelectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"WMShapeSelectionTableViewCell" forIndexPath:indexPath];
    [cell.shapeView  configureWithType:indexPath.row];
    cell.lblShapeTitle.text = arrItems[indexPath.row];
    return cell;
}


#pragma mark UITable View delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(didSelectShapeWithType:)]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate didSelectShapeWithType:indexPath.row];
        }];
    }
}

@end
