#define kOriginalBarCount 4

static NSArray<UIColor *> *colours;

@interface _UIStatusBarSignalView : UIView
@property (nonatomic, assign) NSInteger pridebars_maxBarStrength;
@property (assign,nonatomic) NSInteger numberOfBars;
@property (assign,nonatomic) NSInteger numberOfActiveBars;
- (void)pridebars_setPrideColors;
@end

@interface _UIStatusBarCellularSignalView : _UIStatusBarSignalView
// Sublayers are CALayers
// Set the color by modifying the sublayer's backgroundColor
@end

%hook _UIStatusBarCellularSignalView
%property (nonatomic, assign) NSInteger pridebars_maxBarStrength;

- (void)setNumberOfBars:(NSInteger)orig {
	self.pridebars_maxBarStrength = orig;
	%orig(colours.count);
}

- (void)setNumberOfActiveBars:(NSInteger)orig {
	NSInteger newNumberOfActiveBars = (NSInteger)ceil((CGFloat)orig / self.pridebars_maxBarStrength * (CGFloat)colours.count);
	%orig(newNumberOfActiveBars);
}

- (void)_updateActiveBars {
	%orig;
	[self pridebars_setPrideColors];
}

- (void)_colorsDidChange {
	%orig;
	[self pridebars_setPrideColors];
}

- (CGFloat)_heightForBarAtIndex:(NSInteger)index mode:(NSInteger)mode {
	if (mode < 0x2) return %orig; /* if not showing at normal height (e.g. no service) */
	CGFloat fullHeight = %orig(self.pridebars_maxBarStrength, mode);
	return fullHeight / colours.count * (index + 1);
}

%new
- (void)pridebars_setPrideColors {
	for (int i = 0; i < self.numberOfBars; i++) {
		self.layer.sublayers[i].backgroundColor = [colours[i] colorWithAlphaComponent:i <= self.numberOfActiveBars ? 1 : 0.2].CGColor;
	}
}

// iOS 11 bar width
- (CGFloat)_barWidth {
	return %orig / colours.count * self.pridebars_maxBarStrength;
}

- (CGFloat)_interspace {
	return %orig / colours.count * self.pridebars_maxBarStrength / 2;
}

// iOS 12+ bar width
+ (CGFloat)_barWidthForIconSize:(NSInteger)iconSize {
	return %orig / colours.count * kOriginalBarCount;
}

+ (CGFloat)_interspaceForIconSize:(NSInteger)iconSize {
	return %orig / colours.count * kOriginalBarCount / 2;
}

%end

%ctor {
	// Fix rejailbreak bug
	if (![NSBundle.mainBundle.bundleURL.lastPathComponent.pathExtension isEqualToString:@"app"]) return;
	colours = @[[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor purpleColor]];
	%init;
}
