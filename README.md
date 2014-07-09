**Weather widget**

This is to be used as an example for creating your own widgets for Convergance.

To create a widget, you need to create an object that adheres to the protocol set out in CVWidgetDelegate.h. 
-(UIView*)view; is called in Convergance to get the view for your widget and then add it to the view hierarchy. 

The background of the widget is handled in Convergance, and in a near-future update will likely add an option for users to specify 
the colour of the background. For future compatibility purposes, here's some example code that will detect the background colour:

if ([[objc_getClass("CVAPI") class] respondsToSelector:@selector(usesDarkBackground)]) {
	BOOL isDarkBackground = [objc_getClass("CVAPI") usesDarkBackground];
}

Additionally, you must ensure that your NSPrincipalClass in Info.plist is the same as the class that adheres to the CVWidgetDelegate protocol.
For further information on this, please check the included Package folder under Weather. 

Settings bundles can also be made for your widget. These are plist based only, and so follow PreferenceLoader's usual way of defining options.
Again, please refer to the included Package folder under Weather. 

