# Saving feature points for future measurement

Author: Chesdametrey SENG

## Overview

This application development is a part of software development project at The University of Mebourne. Using ARKit framework to capture all the featurePoints. Each point associated to a real world coordinate of x, y,z. After we got enough featurepoints to process, all of these feature points will unproject to 2D point vector associated to the screeen and save those 2D point with its 3D point vector to CSV file.
These allow the user to load back the capture photo with the featurepoint to do remeasurment at anytime. The process behind this has to do with alot of filtering, such as edge filtering, average depth, removeduplicate and some missing coordinate recontruction. Once the filtering is done, the two sliders provide 2D cooridnate that is every time the user move, it will look for the 2D point of the loaded CSV file and map them to get the 3D vector back (SCNVector3) that is used to compute the distance between the two slider 2d coordinate (CGPoint)

## Running the project with Xcode 

FIsh ARKit requires iOS 11 and a device with an A9 (or later) processor. Note* ARKit is not availbale in iOS stimulator.
- CocoaPod 1.2.1 (2017) is used to install third party framework CSV.swift  (yaslab, 2017).
- Please run "pod install" in the current directory to generate a working space .xcworkspace


## Using the measuring features

- Press capture button 7 times: the user need to press the capture button 7 times, each time the featurepoints are collected. The users are able to see a visualisation of a progress bar. Once the user has pressed the button for 6 times, a clear message will notify the user to place and align the target object in the view fame -> press the last button -> transition to meauring view controller.

- Measuring the object with sliders: using sliders to specify the meaurment

- Few feature points: the app will not transition to meaurement view, if the captured feature points are less than 350. The app will notify the user to keep capture feature points untill the condition is satify

- Detected feature points on target object is very important for maximum accuracy

- Move the camera slightly, or in and out to ensure new and diffeent  feature points are detected

## References

- Apple sample code is used -> see license folder
- Apple 2017 , "Get Started witth ARKit", https://developer.apple.com/arkit/
- yaslab, 2017, "CSV.swift" https://github.com/yaslab/CSV.swift
- CocoaPod, 2017, https://cocoapods.org



