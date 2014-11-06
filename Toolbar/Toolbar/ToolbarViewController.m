//
//  ViewController.m
//  Toolbar
//
//  Created by Brian Nickel on 11/5/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "ToolbarViewController.h"
#import "SEToolbarCollectionViewLayout.h"
#import "SEToolbarCell.h"
#import "SEToolbarMoreView.h"

@interface ToolbarViewController () <UICollectionViewDataSource, UICollectionViewDelegateToolbarLayout>
@property (weak, nonatomic) IBOutlet UISlider *spacingSlider;
@property (weak, nonatomic) IBOutlet UISlider *maxItemSlider;
@property (weak, nonatomic) IBOutlet UICollectionView *toolbarView;
@property (weak, nonatomic) IBOutlet SEToolbarCollectionViewLayout *toolbarLayout;
@property (weak, nonatomic) IBOutlet UILabel *maxItemLabel;

@property (nonatomic, copy) NSArray *itemWidths;

@end

@implementation ToolbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.toolbarView registerNib:[UINib nibWithNibName:@"SEToolbarCell" bundle:nil] forCellWithReuseIdentifier:@"SEToolbarCell"];
    [self.toolbarView registerNib:[UINib nibWithNibName:@"SEToolbarMoreView" bundle:nil] forSupplementaryViewOfKind:SEToolbarMoreItem withReuseIdentifier:SEToolbarMoreItem];
    self.toolbarLayout.minimumItemSpacing = self.spacingSlider.value;
    self.toolbarLayout.maxItemsToShowIfNotAllFit = (NSInteger)round(self.maxItemSlider.value);
    self.itemWidths = @[@50, @100, @50, @50, @50, @200, @50];
    [self.toolbarView reloadData];
}

- (IBAction)spacingChanged:(UISlider *)sender
{
    self.toolbarLayout.minimumItemSpacing = sender.value;
}

- (IBAction)maxItemsChanged:(UISlider *)sender
{
    self.toolbarLayout.maxItemsToShowIfNotAllFit = (NSInteger)round(sender.value);
    self.maxItemLabel.text = [NSString stringWithFormat:@"Max (%ld)", (long)self.toolbarLayout.maxItemsToShowIfNotAllFit];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemWidths.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SEToolbarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SEToolbarCell" forIndexPath:indexPath];
    NSString *title = [NSString stringWithFormat:@"%ld", [self.itemWidths[indexPath.item] longValue]];
    cell.button.titleLabel.text = title;
    [cell.button setTitle:title forState:UIControlStateNormal];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SEToolbarMoreView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
    [view.button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [view.button addTarget:self action:@selector(moreTapped) forControlEvents:UIControlEventTouchUpInside];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (id<NSCopying>)collectionView:(UICollectionView *)collectionView layout:(SEUICollectionViewLayout *)collectionViewLayout uniqueIdentifierForSection:(NSUInteger)section
{
    return @(section);
}

- (id<NSCopying>)collectionView:(UICollectionView *)collectionView layout:(SEUICollectionViewLayout *)collectionViewLayout uniqueIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return @(indexPath.item);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SEToolbarCollectionViewLayout *)collectionViewLayout widthForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.itemWidths[indexPath.item] floatValue];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layoutWidthForMoreItem:(SEToolbarCollectionViewLayout *)collectionViewLayout
{
    return 100;
}

- (void)moreTapped
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"More tapped" message:[NSString stringWithFormat:@"More tapped because only first %ld items are visible.", (long)self.toolbarLayout.numberOfVisibleItems] preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
