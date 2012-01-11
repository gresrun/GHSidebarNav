GHSideBarNav
============

A clone of the new Facebook iOS UI paradigm; a sidebar navigation table that is revealed by sliding the main content panel to the right. The search goes full-screen and everything supports the standard orientations.

This project uses the Container View Controller methods introduced in iOS 5.0 so, it won't work on any version prior.  
This project uses ARC so, you'll need Mac OS 10.7+ (Lion) and Xcode 4.2.1+ to build it.

[![](http://gresrun.github.com/GHSidebarNav/sidebarScreenshot.png)](http://gresrun.github.com/GHSidebarNav/sidebarScreenshot.png)
[![](http://gresrun.github.com/GHSidebarNav/searchScreenshot.png)](http://gresrun.github.com/GHSidebarNav/searchScreenshot.png)

***
How Do I Use It?
----------------

 1. Copy the core components (GHRevealViewController, GHSidebarSearchViewController and GHSidebarSearchViewControllerDelegate) into your project. 
 1. Use GHAppDelegate as a template to integrate GHRevealViewController into your main window in your project's AppDelegate, sending your own headers, controllers and cellInfos.
 1. Implement GHSidebarSearchViewControllerDelegate to find your search results (call a web service, etc.) and do something with the selected search result.
 1. Modify the colors and appearance to match your color scheme. 

***
License
-------
Copyright 2011 Greg Haines

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
