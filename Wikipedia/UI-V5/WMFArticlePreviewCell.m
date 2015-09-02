
#import "WMFArticlePreviewCell.h"
#import "WMFSaveableTitleCollectionViewCell+Subclass.h"

#import "Wikipedia-Swift.h"
#import "PromiseKit.h"

#import "NSAttributedString+WMFModify.h"
#import "UIImageView+MWKImage.h"
#import "SessionSingleton.h"
#import "NSParagraphStyle+WMFParagraphStyles.h"
#import "NSAttributedString+WMFHTMLForSite.h"

CGFloat const WMFArticlePreviewCellTextPadding = 8.0;
CGFloat const WMFArticlePreviewCellImageHeight = 160;

@interface WMFArticlePreviewCell ()

@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@property (strong, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel* summaryLabel;

@end

@implementation WMFArticlePreviewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageURL = nil;
    self.imageView.image = [UIImage imageNamed:@"lead-default.png"];
    self.descriptionText = nil;
    self.summaryLabel.text     = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.image             = [UIImage imageNamed:@"lead-default.png"];
    self.backgroundColor             = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (UICollectionViewLayoutAttributes*)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes {
    CGFloat const preferredMaxLayoutWidth = layoutAttributes.size.width - 2 * WMFArticlePreviewCellTextPadding;

    self.titleLabel.preferredMaxLayoutWidth       = preferredMaxLayoutWidth;
    self.descriptionLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    self.summaryLabel.preferredMaxLayoutWidth     = preferredMaxLayoutWidth;

    UICollectionViewLayoutAttributes* preferredAttributes = [layoutAttributes copy];
    CGFloat height                                        =
        WMFArticlePreviewCellImageHeight +
        MIN(200, self.summaryLabel.intrinsicContentSize.height + 2 * WMFArticlePreviewCellTextPadding);
    preferredAttributes.size = CGSizeMake(layoutAttributes.size.width, height);
    return preferredAttributes;
}

- (void)setImageURL:(NSURL*)imageURL {
    [[WMFImageController sharedInstance] cancelFetchForURL:self.imageURL];
    [self.imageView wmf_resetImageMetadata];

    _imageURL = imageURL;
    @weakify(self);
    [[WMFImageController sharedInstance] fetchImageWithURL:imageURL]
    .then(^id (WMFImageDownload* download) {
        @strongify(self);
        if ([self.imageURL isEqual:imageURL]) {
            self.imageView.image = download.image;
        }
        return nil;
    })
    .catch(^(NSError* error){
        //TODO: Show placeholder
    });
}

- (void)setImage:(MWKImage*)image {
    if (image) {
        [self.imageView wmf_setImageWithFaceDetectionFromMetadata:image];
    }
}

- (void)setDescriptionText:(NSString*)descriptionText {
    _descriptionText           = descriptionText;
    self.descriptionLabel.text = descriptionText;
}

- (void)setSummaryAttributedText:(NSAttributedString*)summaryAttributedText {
    if (!summaryAttributedText.string.length) {
        self.summaryLabel.text = nil;
        return;
    }


    summaryAttributedText = [summaryAttributedText
                             wmf_attributedStringChangingAttribute:NSParagraphStyleAttributeName
                                                         withBlock:^NSParagraphStyle*(NSParagraphStyle* paragraphStyle){
        NSMutableParagraphStyle* style = paragraphStyle.mutableCopy;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        return style;
    }];

    self.summaryLabel.attributedText = summaryAttributedText;
}

- (void)setSummaryHTML:(NSString*)summaryHTML fromSite:(MWKSite*)site {
    if (!summaryHTML.length) {
        self.summaryLabel.text = nil;
        return;
    }

    NSAttributedString* summaryAttributedText =
        [[NSAttributedString alloc] initWithHTMLData:[summaryHTML dataUsingEncoding:NSUTF8StringEncoding] site:site];

    [self setSummaryAttributedText:summaryAttributedText];
}

@end
