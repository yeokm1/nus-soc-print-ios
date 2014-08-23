nus-soc-print-ios
=================

An iOS Application that prints office documents and PDF files to Unix printers in NUS School Of Computing. A port from my [Android App](https://github.com/yeokm1/nus-soc-print/) Certain features I felt that are hardly used by people have been dropped compared to the Android version to improve the UI cleanliness. 

I'm waiting for Apple to start accepting Swift app submissions on the App Store before doing so myself.

##Features
1. Print PDF, DOC, DOCX, PPT, PPTX and ODT files
2. Remaining quota check
3. Print Status Check
4. Print to custom printer
5. Page formatting for documents
6. Accepts file exports from others apps like IVLE and Dropbox.
7. Deleting of existing job in print queue


##Screenshots


<a href="url"><img src="screenshots/print.png" align="centre" height="568" width="320" ></a>
<p></p>
<a href="url"><img src="screenshots/printing.png" align="centre" height="568" width="320" ></a>
<p></p>
<a href="url"><img src="screenshots/quota.png" align="centre" height="568" width="320" ></a>
<p></p>

Dependencies
=====
1. Swift language
2. Xcode 6 beta 6
3. Cocoapods
4. NMSSH SSH library (installed via Cocoapods)


##Compiling the project
1. Swift is only available on Xcode 6 beta so you have to download and install manually from Apple's website
2. Install Cocoapods `sudo gem install cocoapods`
3. Change directory to where you pulled the project and run `pod install`
4. Open the project using `NUS SOC Print.xcworkspace` instead of the `.xcodeproject` file

##Credits
Many thanks to Kai Yao and Yong Quan for initially working with me during the HacknRoll 2014 to kickstart this app. I just brought it to (nearly) the finish line.
