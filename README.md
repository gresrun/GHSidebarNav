GHSideBarNav
============

A clone of the new Facebook iOS UI paradigm; a sidebar navigation table that is revealed by sliding the main content panel to the right. The search goes full-screen and everything supports the standard orientations.

This project uses the Container View Controller methods introduced iOS 5.0 so, it won't work on any version prior.
This project uses ARC so, you'll need Mac OS 10.7 (Lion) and Xcode 4.2.1+ to build it.

***

How Do I Use It?
----------------

 1. Copy the core components (GHSidebarViewController, GHSidebarSearchViewController and GHSidebarMenuCell) into your project. 
 1. Use GHAppDelegate as a template to integrate GHSidebarViewController into your main window in your project's AppDelegate.
 1. Modify GHSidebarController to use your navigation items and images.
 1. Modify GHSidebarSearchViewController to use your web service to find search results.
 1. Modify the colors and appearance to match your color scheme. 

***

License
-------
Copyright 2011 Greg Haines

Haven't decided yet...
