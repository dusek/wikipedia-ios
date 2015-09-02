//
//  WMFSaveableTitleCollectionViewCell+Subclass.h
//  Wikipedia
//
//  Created by Brian Gerstle on 9/2/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.
//

#import "WMFSaveableTitleCollectionViewCell.h"

@interface WMFSaveableTitleCollectionViewCell ()

/**
 *  Label used to display the receiver's @c title.
 *
 *  Updated with the text of the title by default.  Configure as needed in Interface Builder
 *  or during initialization when subclassing.
 */
@property (strong, nonatomic) IBOutlet UILabel* titleLabel;

/**
 *  The button used to display the saved state of the receiver's @c title.
 *
 *  If you want to use a custom button, you need to set it programatically, as this class will automatically
 *  configure any buttons connected to this property in Interface Builder (during @c awakeFromNib).
 */
@property (strong, nonatomic) IBOutlet UIButton* saveButton;

@end
