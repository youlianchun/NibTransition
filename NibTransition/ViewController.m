//
//  ViewController.m
//  NibTransition
//
//  Created by YLCHUN on 2018/12/24.
//  Copyright © 2018年 YLCHUN. All rights reserved.
//

#import "ViewController.h"
#import "NibTransition.h"
#import "DragView.h"
#import "FileHelper.h"

@interface ViewController()
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSImageView *dragStateView;
@property (weak) IBOutlet DragView *dragView;
@property (weak) IBOutlet NSButton *radio_t;
@property (weak) IBOutlet NSButton *radio_c;
@property (weak) IBOutlet NSButton *radio_v;
@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSButton *defPathBtn;
@property (weak) IBOutlet NSButton *transitBtn;
@end

@implementation ViewController
{
    NSData *_sourceData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cleanRadio];
    [self setupDragDropView];
    [self setOutputPath:getDefPath()];
    
    // Do any additional setup after loading the view.
}

-(void)setOutputPath:(NSString *)path {
    self.defPathBtn.title = path;
    setDefPath(path);
}

- (IBAction)transitAction:(NSButton *)sender {
    if (self.defPathBtn.state == NSControlStateValueOn) {
        [self transition];
    }else {
        [self selectPath:^(NSString *path) {
            [self setOutputPath:path];
            self.defPathBtn.state = NSControlStateValueOn;
            [self transition];
        }];
    }
}

-(void)transition {
    NibTransitionType type = [self transitionType];
    if (type == NibTransitionType_u || _sourceData.length == 0) {
        return;
    }
    xibTransition(_sourceData, type, ^(NSData * _Nonnull xib) {
        [self onTransition:xib];
    });
}

-(void)onTransition:(NSData *)data {
    NSString *name = self.nameTextField.stringValue;
    if (name.length == 0) {
        name = self.nameTextField.placeholderString;
    }
    NSString *path = self.defPathBtn.title;
    NSString *file = getFilePath(path, name);
    BOOL success = [data writeToFile:file atomically:NO];
    if (!success) {
        NSString *msg = [NSString stringWithFormat:@"please check the output path and try again later \npath: %@", path];
        [self alertWithTitle:@"i can't do it" message:msg];
    }
}

-(void)alertWithTitle:(NSString *)title message:(NSString *)message {
    NSAlert * alert = [[NSAlert alloc]init];
    alert.messageText = title;
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleCritical;
    [alert addButtonWithTitle:@"OK"];
    NSWindow *window = NSApplication.sharedApplication.mainWindow;
    [alert beginSheetModalForWindow:window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
        }
    }];
}

- (IBAction)radioAction:(NSButton *)sender {
    [self cleanRadio];
    sender.state = NSControlStateValueOn;
    self.transitBtn.enabled = [self transitBtnEnabled];
}

-(void)cleanRadio {
    self.radio_t.state = NSControlStateValueOff;
    self.radio_c.state = NSControlStateValueOff;
    self.radio_v.state = NSControlStateValueOff;
    self.transitBtn.enabled = NO;
}

-(void)setupDragDropView {
    self.dragStateView.alphaValue = 0.5;
    __weak typeof(self) wself = self;
    [self.dragView setDraggedType:NSPasteboardTypeXIB count:1 callback:^(NSArray * _Nonnull contents) {
        NSString *file = contents.firstObject;
        [wself onLoadXib:file];
    }];
}

-(void)onLoadXib:(NSString *)file {
    _sourceData = [NSData dataWithContentsOfFile:file];
    self.dragStateView.alphaValue = 1;
    self.transitBtn.enabled = [self transitBtnEnabled];
    NSString *name = getFileName(file);
    self.nameLabel.stringValue = name;
    name = appendingFileName(nil, name, @"_nt");
    if (self.nameTextField.stringValue.length == 0) {
        self.nameTextField.stringValue = name;
    }
    self.nameTextField.placeholderString = name;
}

-(BOOL)transitBtnEnabled {
    return [self transitionType] != NibTransitionType_u && _sourceData.length > 0;
}

-(NibTransitionType)transitionType {
    if (self.radio_t.state == NSControlStateValueOn) {
        return NibTransitionType_t;
    }
    else if (self.radio_c.state == NSControlStateValueOn) {
        return NibTransitionType_c;
    }
    else if (self.radio_v.state == NSControlStateValueOn) {
        return NibTransitionType_v;
    }
    else {
        return NibTransitionType_u;
    }
}

-(void)selectPath:(void(^)(NSString *path))callback {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.canCreateDirectories = YES;
    openPanel.title = @"Choose Export Directories";
    openPanel.message = @"Choose Export Directories";
    openPanel.prompt = @"Export";
    NSButton *cancelButton = [openPanel valueForKey:@"_cancelButton"];
    cancelButton.title = @"Cancel";
    NSWindow *window = NSApplication.sharedApplication.mainWindow;
    [openPanel beginSheetModalForWindow:window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSString *path = openPanel.URL.path;
            callback(path);
        }
    }];
}

@end
