#import "HFImageEditorViewController.h"

@interface ImageEditorViewController : HFImageEditorViewController

@property(nonatomic,strong) IBOutlet UIBarButtonItem *saveButton;

- (void)setSquareSize:(CGSize)frame;

@end
