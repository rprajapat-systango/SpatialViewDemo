//
//  WMSpatialViewShape.m
//  SpatialViewDemo
//
//  Created by Systango on 02/07/19.
//  Copyright © 2019 Systango. All rights reserved.
//

#import "WMSpatialViewShape.h"
@interface WMSpatialViewShape(){
    CGLayerRef shapeLayer_;
}
@property(assign) Shape shape;
@property(assign) UIColor *color;
@property(strong, nonatomic) NSString *title;
@property(retain, nonatomic) UILabel *labelResourceName;
@property(retain, nonatomic) UILabel *labelPartyName;

@end

@implementation WMSpatialViewShape

- (void)setupView {
    _labelResourceName = [UILabel new];
    _labelPartyName = [UILabel new];
    [self setBackgroundColor:[UIColor clearColor]];
    self.layer.borderColor = [UIColor blueColor].CGColor;
    [self addGestureRecognizer:[self getTapGesture]];
    self.identifier = self.title;
}

- (instancetype)initWithModel:(WMShape *)shapeModel{
    self = [super initWithFrame:shapeModel.frame];
    if (self) {
        self.shape = shapeModel.shapeType;
        self.color = shapeModel.fillColor;
        self.borderColor = shapeModel.borderColor;
        self.title = shapeModel.title;
        [self setupView];
    }
    return self;
}

- (UITapGestureRecognizer *) getTapGesture{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(didTapOnView)];
    return tapGesture;
}

- (void)didTapOnView{
    NSLog(@"did tap on view %@", self);
    if ([self.delegate respondsToSelector:@selector(didTapOnView:)]){
        [self.delegate didTapOnView:self];
    }
}

- (void)setIsSelected:(BOOL)isSelected{
    self.layer.borderWidth = isSelected ? 2.0 : 0.0;
    //[self setNeedsDisplay];
}

//-(void)makeTransform{
//    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
//    CGPathRef rotatedPath = CGPathCreateCopyByTransformingPath(myPath, &transform);
//    https://stackoverflow.com/questions/13738364/rotate-cgpath-without-changing-its-position
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    /* Get the current context */
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.shape) {
        case RECTANGLE:
            [self drawRectangle:context rect:&rect];
            [self addRectBorder:&rect];
            break;
        case ELLIPSE:
            [self drawEllipse:context rect:&rect];
            [self addEllipseBorder:&rect];
            break;
        case DIAMOND:
            [self drawDiomond:context rect:&rect];
            break;
        case TRIANGLE:
            [self drawTriangle:context rect:&rect];
            break;
        default:
            break;
    }
    [self addStackView];
    [self setData];
}

- (void)configureLables{
    // Configuring Resource name label
    _labelResourceName.textColor = [UIColor blackColor];
    _labelResourceName.backgroundColor = [UIColor clearColor];
    _labelResourceName.adjustsFontSizeToFitWidth = YES;
    _labelResourceName.minimumScaleFactor = 0.6;
    [_labelResourceName setFont:[UIFont boldSystemFontOfSize:24]];
    // Configuring Party name label
    _labelPartyName.textColor = [UIColor whiteColor];
    _labelPartyName.backgroundColor = [UIColor blueColor];
    
}

-(void)setData{
    [self configureLables];
    _labelResourceName.text = self.title;
    [_labelResourceName sizeToFit];
    NSUInteger size = arc4random_uniform(16)%10;
    if (size == 0) size = 1;
    _labelPartyName.text = [NSString stringWithFormat:@" %lu ",(unsigned long)size];
    [_labelPartyName sizeToFit];
}

/**
 Drwawnig ellipse

 @param context context
 @param rect frame
 */
- (void)drawEllipse:(CGContextRef)context rect:(const CGRect *)rect {
    const CGFloat *ellipseColorComponents = CGColorGetComponents(self.color.CGColor);
    CGContextSetFillColor(context, ellipseColorComponents);
    CGContextFillEllipseInRect(context, *rect);
}

/**
 To add border on shape

 @param rect frame
 */
- (void)addEllipseBorder:(const CGRect *)rect {
    UIBezierPath *arc = [UIBezierPath bezierPathWithOvalInRect:*rect];
    [arc setLineWidth:5.0];
    [arc addClip];
    [self.borderColor setStroke];
    [arc stroke];
}

- (void)drawRectangle:(CGContextRef)context rect:(const CGRect *)rect {
    const CGFloat *ellipseColorComponents = CGColorGetComponents(self.color.CGColor);
    CGContextSetFillColor(context, ellipseColorComponents);
    CGContextFillRect(context, *rect);
}

- (void)addRectBorder:(const CGRect *)rect {
    UIBezierPath *arc = [UIBezierPath bezierPathWithRect:*rect];
    [arc setLineWidth:5.0];
    [arc addClip];
    [self.borderColor setStroke];
    [arc stroke];
}

- (void)addBorder:(const CGPoint *)points  size:(int)size{
    CGMutablePathRef path = CGPathCreateMutable();
    int i = 0;
    CGPathMoveToPoint(path, nil, points[i].x, points[i].y);
    i++;
    while (i < size) {
        CGPathAddLineToPoint(path, nil, points[i].x, points[i].y);
        i++;
    }
    // Creating path to draw the lines
    UIBezierPath *clip = [UIBezierPath bezierPathWithCGPath:path];
    [clip setLineWidth:5.0];
    [clip closePath];
    [clip addClip];
    [self.borderColor setStroke];
    [clip stroke];
    
}

- (void)drawDiomond:(CGContextRef)context rect:(const CGRect *)rect {
    float W = rect->size.width;
    float H = rect->size.height;
    CGPoint points[5] = { CGPointMake(W/2, 0), CGPointMake(W, H/2),
        CGPointMake(W/2, H), CGPointMake(0, H/2),
        CGPointMake(W/2, 0) };
    [self drawPathWithContext:context points:points size:5];
    [self addBorder:points size:5];
}

- (void)drawPathWithContext:(CGContextRef)context points:(CGPoint *)points size:(int)size {
    CGContextSetFillColor(context, CGColorGetComponents(self.color.CGColor));
    CGContextAddLines(context, points, size);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawTriangle:(CGContextRef)context rect:(const CGRect *)rect {
    float W = rect->size.width;
    float H = rect->size.height;
    CGPoint points[5] = { CGPointMake(W/2, 0), CGPointMake(W, H), CGPointMake(0, H)};
    [self drawPathWithContext:context points:points size:3];
    [self addBorder:points size:3];
}


-  (void)addStackView{
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.distribution = UIStackViewDistributionEqualSpacing;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.spacing = 1;
    
    [_stackView addArrangedSubview:_labelResourceName];
    [_stackView addArrangedSubview:_labelPartyName];
    [self addSubview:_stackView];
    [self setupStackViewCenterConstraints:_stackView];
}

- (void) setupStackViewCenterConstraints:(UIStackView *)stackView{
    stackView.translatesAutoresizingMaskIntoConstraints = false;
    if (@available(iOS 11.0, *)) {
        [stackView.leadingAnchor constraintGreaterThanOrEqualToSystemSpacingAfterAnchor:self.leadingAnchor multiplier:3].active = YES;
    }else {
        // Fallback on earlier versions
        [stackView.leadingAnchor
         constraintEqualToAnchor:self.leadingAnchor].active = YES;
    }
    [stackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
    [stackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:0].active = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"layoutSubviews methods called %@",self);
}

@end