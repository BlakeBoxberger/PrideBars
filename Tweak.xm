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

@interface _UIStatusBarWifiSignalView : _UIStatusBarSignalView
// Sublayers are CAShapeLayers
// Set the color by modifying the sublayer's strokeColor and fillColor
@end

%hook _UIStatusBarCellularSignalView
%property (nonatomic, assign) NSInteger pridebars_maxBarStrength;

- (void)setNumberOfBars:(NSInteger)arg1 {
	self.pridebars_maxBarStrength = arg1;
	%orig(6);
}

- (void)setNumberOfActiveBars:(NSInteger)arg1 {
	CGFloat strength = arg1/self.pridebars_maxBarStrength;
	NSInteger newNumberOfActiveBars = floor(strength * self.numberOfBars);
	%orig(newNumberOfActiveBars);
}

- (void)_updateActiveBars {
	%orig;
	[self pridebars_setPrideColors];
}

- (void)_colorsDidChange {
	[self pridebars_setPrideColors];
}

- (CGFloat)_heightForBarAtIndex:(NSInteger)arg1 {
	if(arg1 == 5) {
		CGFloat heightFor5bars = %orig(4);
		if(heightFor5bars == 3.0) {
			return 3.0;
		}
		else {
			return heightFor5bars + 3.0;
		}
	}
	else {
		return %orig;
	}
}


%new - (void)pridebars_setPrideColors {
	NSArray *sublayers = self.layer.sublayers;

	CALayer *bar1 = (CALayer *)sublayers[0];
	CALayer *bar2 = (CALayer *)sublayers[1];
	CALayer *bar3 = (CALayer *)sublayers[2];
	CALayer *bar4 = (CALayer *)sublayers[3];
	CALayer *bar5 = (CALayer *)sublayers[4];
	CALayer *bar6 = (CALayer *)sublayers[5];

	for(int i = 0; i <= self.numberOfBars; i++) {
		switch(i) {
			case 1:
				bar1.backgroundColor = [UIColor.redColor CGColor];
			case 2:
				bar2.backgroundColor = [UIColor.orangeColor CGColor];
			case 3:
				bar3.backgroundColor = [UIColor.yellowColor CGColor];
			case 4:
				bar4.backgroundColor = [UIColor.greenColor CGColor];
			case 5:
				bar5.backgroundColor = [UIColor.blueColor CGColor];
			case 6:
				bar6.backgroundColor = [UIColor.purpleColor CGColor];
		}
	}
}

%end

%ctor {
	// Fix rejailbreak bug
	if (![NSBundle.mainBundle.bundleURL.lastPathComponent.pathExtension isEqualToString:@"app"]) {
		return;
	}

	%init;
}
