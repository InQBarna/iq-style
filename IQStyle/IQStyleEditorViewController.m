//
// Author: David Romacho <david.romacho@inqbarna.com>
//
// Copyright (c) 2016 InQBarna Kenkyuu Jo (http://inqbarna.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IQStyleEditorViewController.h"
#import "IQStyle.h"

@implementation IQStyleEditorViewController

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 48.0f;
    self.title = @"Style Editor";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.navigationController) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(dismiss:)];
    }
}

#pragma mark -
#pragma mark IQStyleEditorViewController methods

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (UIImage *)imageWithColor:(UIColor *)color rect:(CGRect)rect{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [IQStyle colorTags].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"styleCell";
    
    UITableViewCell *result = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!result) {
        result = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                        reuseIdentifier:reuseIdentifier];
        result.imageView.layer.borderColor = [UIColor blackColor].CGColor;
        result.imageView.layer.borderWidth = 1.0f;
    }
    
    NSString *tag = [[IQStyle colorTags] objectAtIndex:indexPath.row];
    UIColor *color = [IQStyle colorWithTag:tag];
    result.textLabel.text = tag;
    result.detailTextLabel.text = [color toString];
    result.imageView.image = [self.class imageWithColor:color rect:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    
    return result;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self editColorAtIndexPath:indexPath];
}

- (void)editColorAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *tag = [[IQStyle colorTags] objectAtIndex:indexPath.row];
    UIColor *color = [IQStyle colorWithTag:tag];
    NSString *text = [color toString];
    
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Enter new color"
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    __block __weak UITextField *tf;
    [a addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        tf = textField;
        textField.delegate = nil;
        textField.text = text;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
    }];
    
    __weak typeof(self) welf = self;    
    [a addAction:[UIAlertAction actionWithTitle:@"Ok"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                  {
                      UIColor *newColor = [UIColor colorWithHexString:tf.text];
                      if(newColor) {
                          [IQStyle setColor:newColor forTag:tag];
                          [welf.tableView reloadRowsAtIndexPaths:@[indexPath]
                                           withRowAnimation:UITableViewRowAnimationAutomatic];
                      }
                  }]];
    
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *action)
                  {
                  }]];
    
    [self presentViewController:a animated:YES completion:nil];
}

@end
