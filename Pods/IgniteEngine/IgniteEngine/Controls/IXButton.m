//
//  IXButton.m
//  Ignite Engine
//
//  Created by Robert Walsh on 2/3/14.
//
/****************************************************************************
 The MIT License (MIT)
 Copyright (c) 2015 Apigee Corporation
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
//

#import "IXButton.h"

#import "UIImage+IXAdditions.h"
#import "UIButton+IXAdditions.h"
#import "UIFont+IXAdditions.h"
#import "ColorUtils.h"
#import "NSString+FontAwesome.h"

// Attributes
IX_STATIC_CONST_STRING kIXTextDefault = @"text";
IX_STATIC_CONST_STRING kIXTextDefaultFont = @"font";
IX_STATIC_CONST_STRING kIXTextDefaultColor = @"color";
IX_STATIC_CONST_STRING kIXBackgroundColor = @"bg.color";
IX_STATIC_CONST_STRING kIXIconDefault = @"icon";
IX_STATIC_CONST_STRING kIXIconDefaultTintColor = @"icon.tint";
IX_STATIC_CONST_STRING kIXAlpha = @"alpha";
IX_STATIC_CONST_STRING kIXDarkensImageOnTouch = @"darkenOnTouch.enabled";
IX_STATIC_CONST_STRING kIXTouchDuration = @"touch.duration";
IX_STATIC_CONST_STRING kIXTouchUpDuration = @"touchUp.duration";

// IXButton states
IX_STATIC_CONST_STRING kIXNormal = @"normal";
IX_STATIC_CONST_STRING kIXTouch = @"touch";
IX_STATIC_CONST_STRING kIXDisabled = @"disabled";

@interface IXButton ()



@property (nonatomic,strong) UIButton* button;

@end

NSArray* backgroundColors;
NSArray* alphas;


@implementation IXButton

-(void)dealloc
{
    [_button removeTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_button removeTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_button removeTarget:self action:@selector(buttonTouchCancelled:) forControlEvents:UIControlEventTouchCancel];
}


-(void)buildView
{

    [super buildView];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_button addTarget:self action:@selector(buttonTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_button addTarget:self action:@selector(buttonTouchCancelled:) forControlEvents:UIControlEventTouchCancel];
    [_button addTarget:self action:@selector(buttonTouchCancelled:) forControlEvents:UIControlEventTouchUpOutside];
    [[self contentView] addSubview:_button];
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return [[self button] sizeThatFits:size];
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    [[self button] setFrame:rect];
}

-(void)applySettings
{
    [super applySettings];
    
    [[self button] setEnabled:[[self contentView] isEnabled]];
    
    self.button.shouldHighlightImageOnTouch = [self.attributeContainer getBoolValueForAttribute:kIXDarkensImageOnTouch defaultValue:YES];
    [[self button] setAdjustsImageWhenHighlighted:NO];
    
    [[self button] setAttributedTitle:nil forState:UIControlStateNormal];
    [[self button] setAttributedTitle:nil forState:UIControlStateHighlighted];
    [[self button] setAttributedTitle:nil forState:UIControlStateDisabled];

    __block NSString* defaultColorForTitles = @"#606060";
    __block NSString* defaultFontForTitles = @"HelveticaNeue:16.0f";

    // Grab the title states - comma separated
    __block NSArray* titleTexts = [self getButtonStatesForArray:[[self attributeContainer] getPipeCommaPipeSeparatedArrayOfValuesForAttribute:kIXTextDefault defaultValue:nil]];
    __block NSArray* titleColors = [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXTextDefaultColor defaultValue:@[defaultColorForTitles]]];
    __block NSArray* titleFonts = [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXTextDefaultFont defaultValue:@[defaultFontForTitles]]];
    __block NSArray* iconTintColors = [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXIconDefaultTintColor defaultValue:nil]];
    alphas = [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXAlpha defaultValue:@[@"1"]]];
    backgroundColors = [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXBackgroundColor defaultValue:nil]];
    
    [@[kIXNormal, kIXTouch, kIXDisabled] enumerateObjectsUsingBlock:^(NSString* titleState, NSUInteger idx, BOOL *stop) {
        
        UIControlState controlState = UIControlStateNormal;
        if ([titleState isEqualToString:kIXNormal])
            controlState = UIControlStateNormal;
        else if ([titleState isEqualToString:kIXTouch])
            controlState = UIControlStateHighlighted;
        else if ([titleState isEqualToString:kIXDisabled]) {
            controlState = UIControlStateDisabled;
            [[self button] setBackgroundColor:[UIColor colorWithString:backgroundColors[idx]]];
            [[self button] setAlpha:[alphas[idx] floatValue]];
        }
        
        NSString* titleText = titleTexts[idx];
        
        if( [titleText length] )
        {
            UIColor* titleTextColor = [UIColor colorWithString:titleColors[idx]];
            UIFont* titleTextFont = [UIFont ix_fontFromString:titleFonts[idx]];
            
            if([titleTextFont.familyName isEqualToString:kFontAwesomeFamilyName]) {
                titleText = [NSString fontAwesomeIconStringForIconIdentifier:titleText];
            }
            
            NSAttributedString* attributedTitle;
            
            if (titleTextColor && titleTextFont) {
                attributedTitle = [[NSAttributedString alloc] initWithString:titleText
                                                                  attributes:@{NSForegroundColorAttributeName: titleTextColor,
                                                                               NSFontAttributeName:titleTextFont}];
            }
            
            [[self button] setAttributedTitle:attributedTitle forState:controlState];
        }
        
        __block UIColor* imageTintColorForState = [UIColor colorWithString:iconTintColors[idx]];
        
        __weak typeof(self) weakSelf = self;
        [[self attributeContainer] getImageAttribute:kIXIconDefault
                                      successBlock:^(UIImage *image) {
                                          if( imageTintColorForState )
                                          {
                                              image = [image tintedImageUsingColor:imageTintColorForState];
                                          }
                                          [[weakSelf button] setImage:image forState:controlState];
                                      } failBlock:nil];
    }];
}

-(void)buttonTouchedDown:(id)sender
{
    if (self.button.shouldHighlightImageOnTouch)
    {
        CGFloat duration = [self.attributeContainer getFloatValueForAttribute:kIXTouchDuration defaultValue:0.05];
        CGFloat alpha = [alphas[1] floatValue] ?: [[self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXAlpha defaultValue:nil]][1] floatValue];
        UIColor* backgroundColor = [UIColor colorWithString:(backgroundColors[1] ?: [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXBackgroundColor defaultValue:nil]][1])];
        
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             if (alpha < 1)
                             {
                                 self.button.alpha = alpha;
                             }
                             if (backgroundColor)
                             {
                                 self.contentView.backgroundColor = backgroundColor;
                             }
                         }
                         completion:^(BOOL finished){
                             [self processBeginTouch:YES];
                         }];
    }
    else
        [self processBeginTouch:YES];
}

-(void)buttonTouchUpInside:(id)sender
{
    if (self.button.shouldHighlightImageOnTouch)
    {
        CGFloat duration = [self.attributeContainer getFloatValueForAttribute:kIXTouchUpDuration defaultValue:0.15];
        CGFloat alpha = [alphas[0] floatValue] ?: [[self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXAlpha defaultValue:nil]][0] floatValue];
        UIColor* backgroundColor = [UIColor colorWithString:(backgroundColors[0] ?: [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXBackgroundColor defaultValue:nil]][0])];
        
        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            self.button.alpha = alpha;
                            if (backgroundColor)
                            {
                                self.contentView.backgroundColor = backgroundColor;
                            }
                        }
                        completion:^(BOOL finished){
                            [self processEndTouch:YES];
                        }];
    }
    else
        [self processEndTouch:YES];
}

-(void)buttonTouchCancelled:(id)sender
{
    if (self.button.shouldHighlightImageOnTouch)
    {
        CGFloat duration = [self.attributeContainer getFloatValueForAttribute:kIXTouchUpDuration defaultValue:0.15];
        CGFloat alpha = [alphas[0] floatValue] ?: [[self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXAlpha defaultValue:nil]][0] floatValue];
        UIColor* backgroundColor = [UIColor colorWithString:(backgroundColors[0] ?: [self getButtonStatesForArray:[[self attributeContainer] getCommaSeparatedArrayOfValuesForAttribute:kIXBackgroundColor defaultValue:nil]][0])];

        [UIView transitionWithView:self.button
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            self.button.alpha = alpha;
                            if (backgroundColor)
                            {
                                self.contentView.backgroundColor = backgroundColor;
                            }
                        }
                        completion:^(BOOL finished){
                            [self processCancelTouch:YES];
                        }];
    }
    else
        [self processCancelTouch:YES];
}

- (NSArray*)getButtonStatesForArray:(NSArray*)array {
    if (array) {
        if (array.count == 1)
            return @[array[0], array[0], array[0]];
        else if (array.count == 2)
            return @[array[0], array[1], array[0]];
        else if (array.count == 3)
            return @[array[0], array[1], array[2]];
        else
            return @[array[0], array[0], array[0]];
    } else {
        return nil;
    }
}

@end
