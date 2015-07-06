#import "HFImageEditorViewController+Private.h"
#import "ImageEditorViewController.h"

@interface ImageEditorViewController ()

@end

@implementation ImageEditorViewController

@synthesize  saveButton = _saveButton;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.cropRect = CGRectMake(0,0,320,320);
        self.minimumScale = 0.2;
        self.maximumScale = 10;
    }
    return self;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.saveButton = nil;
}

#pragma mark Hooks
- (void)startTransformHook
{
    self.saveButton.tintColor = [UIColor colorWithRed:0 green:49/255.0f blue:98/255.0f alpha:1];
}

- (void)endTransformHook
{
    self.saveButton.tintColor = [UIColor colorWithRed:0 green:128/255.0f blue:1 alpha:1];
}

- (void)setSquareSize:(CGSize)size
{
    self.cropRect = CGRectMake((self.frameView.frame.size.width-size.width)/2.0f, (self.frameView.frame.size.height-size.height)/2.0f, size.width, size.height);
    [self reset:YES];
}

@end
