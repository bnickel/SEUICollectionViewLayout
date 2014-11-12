//
//  SEUICollectionViewLayout.h
//  SEUICollectionViewLayout
//
//  Created by Brian Nickel on 8/4/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @abstract @c SEUICollectionViewLayout extends @c UICollectionViewLayout and provides a base class for complex layouts.
 @discussion This class improves support for creating and animating decoration and supplementary cells.
 @warning This class assumes that decoration and supplementary views will have distinct view kinds (i.e., unique names for all view kinds).
 */
@interface SEUICollectionViewLayout : UICollectionViewLayout

/**
 @abstract An array of strings representing supplementary and decoration view kinds that should track changes at a section level.
 @discussion This is used for animating supplementary and decoration view changes during updates.
 @see itemTrackingSupplementaryAndDecorationViewKinds
 */
@property (nonatomic, copy) NSArray *sectionTrackingSupplementaryAndDecorationViewKinds;

/**
 @abstract An array of strings representing supplementary and decoration view kinds that should track changes at a item level.
 @discussion This is used for animating supplementary and decoration view changes during updates.
 @see sectionTrackingSupplementaryAndDecorationViewKinds
 */
@property (nonatomic, copy) NSArray *itemTrackingSupplementaryAndDecorationViewKinds;

/**
 @abstract Specifies whether or not to animate on bounds changes.
 @discussion When @c YES and the layout is invalidated due to a bounds change, the layout will attempt to animate views to their final positions.  When @c NO, the default crossfade animation will be used.
 @see shouldInvalidateLayoutForBoundsChange:
 */
@property (nonatomic, assign) BOOL animateBoundsChanges;

/**
 @abstract Notifies the base class that @c prepareLayout has begun.
 @discussion This method must be called at the beginning of the subclass's @prepareLayout call.  It maintains the attribute stores and the mapping between attributes for animations.
 @warning This method call must be paired with @endPreparingLayout in all code paths inside @c prepareLayout.
 @see endPreparingLayout
 */
- (void)beginPreparingLayout;

/**
 @abstract Notifies the base class that @c prepareLayout has finished.
 @discussion This method must be called at the end of the subclass's @prepareLayout call.
 @warning This method call must be called before @c prepareLayout returns.
 @see beginPreparingLayout
 */
- (void)endPreparingLayout;

/**
 @abstract Registers a view to return for @c layoutAttributesForItemAtIndexPath:
 @warning This method must be called between @c beginPreparingLayout and @c endPreparingLayout.
 */
- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 @abstract Registers a view to return for @c layoutAttributesForSupplementaryViewOfKind:indexPath: and use when animating changes.
 @warning This method must be called between @c beginPreparingLayout and @c endPreparingLayout.
 */
- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

/**
 @abstract Registers a view to return for @c layoutAttributesForDecorationViewOfKind:indexPath: and use when animating changes.
 @warning This method must be called between @c beginPreparingLayout and @c endPreparingLayout.
 */
- (void)setLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes forDecorationViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end


/**
 @abstract The @c UICollectionViewDelegateSEUILayout protocol extends @c UICollectionViewDelegate and provides a base protocol for delegates of a @c SEUICollectionViewLayout subclass.  It includes two methods to assist animation.
 */
@protocol UICollectionViewDelegateSEUILayout <UICollectionViewDelegate>

/**
 @abstract Returns a unique identifier that can be used to track the item during changes.
 @discussion The delegate must provide a unique identifier for the item represented by the cell at the index path.  For items that are fixed in memory, this could be the memory address.  For models that will not insert or delete cells, this can be the index path.  For other cases it may be appropriate to generated a @c NSUUID and store it on the item.
 @param collectionView The collection view object displaying the flow layout.
 @param collectionViewLayout The layout object requesting the information.
 @param indexPath The index path of the item.
 @return A unique identifier conforming to @c NSCopying.
 */
- (id<NSCopying>)collectionView:(UICollectionView *)collectionView layout:(SEUICollectionViewLayout *)collectionViewLayout uniqueIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 @abstract Returns a unique identifier that can be used to track the section during changes.
 @discussion The delegate must provide a unique identifier for the data represented by the section.  For sections that are fixed in memory, this could be the memory address.  For models that will not insert or delete sections, this can be a @c NSNumber containing the section.  For other cases it may be appropriate to generated a @c NSUUID and store it with the section data.
 @param collectionView The collection view object displaying the flow layout.
 @param collectionViewLayout The layout object requesting the information.
 @param section The section index.
 @return A unique identifier conforming to @c NSCopying.
 */
- (id<NSCopying>)collectionView:(UICollectionView *)collectionView layout:(SEUICollectionViewLayout *)collectionViewLayout uniqueIdentifierForSection:(NSUInteger)section;

@end