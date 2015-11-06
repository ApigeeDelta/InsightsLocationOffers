//
//  UIImage+IXAdditions.h
//  Ignite Engine
//
//  Created by Robert Walsh on 2/5/14.
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

#import <UIKit/UIKit.h>

@interface UIImage (IXAdditions)

-(UIImage*)tintedImageUsingColor:(UIColor*)tintColor;
+(UIImage *)ix_animatedGIFWithData:(NSData *)data withDuration:(NSUInteger)duration;

//all 4 of these are broken? possibly need self.contentView.autoresizesSubviews = NO; as workaround
-(UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
-(UIImage *)imageRotatedByRadians:(CGFloat)radians;
+(CGFloat)degreesToRadians:(CGFloat)degrees;
+(CGFloat)radiansToDegrees:(CGFloat)radians;
+(NSString *)contentTypeForImageData:(NSData *)data;
+(UIImage *)setImage:(UIImage *)image withAlpha:(CGFloat)alpha;
-(UIImage*)fixRotation;
-(UIImage*)adjustedForRetina;

@end
