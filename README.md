DVPlaylistPlayer
================

DVPlaylistPlayer is an easy-to-use AVQueuePlayer-like player with wider capabilities. It is built on top of the AVPlayer. 
Unlike AVQueuePlayer here you have all the basic player controls like moving to next or previous video, mute, unmute or 
change volume level and so on. Another difference with AVQueuePlayer is in non-regular way of setting the list of tracks. 
This player takes it's tracks from data source like UITableView.

##Required frameworks##
 - MediaPlayer
 - AVFoundation
 - AudioToolbox

##Adding DVPlaylistPlayer to your project##
###CocoaPods###
The easiest way to add our playlist player to your project is to use CocoaPods.
If you don't have CocoaPods installed on your system, then we suggest you to check cocoapods.org for further information.
All you need to do to install DVPlaylistPlayer is to create file named 'Podfile' right in your project.xcodeproj file 
directory. Then you need to add next two lines:

`platform :ios, '5.0'` //depends on your project requirments but not less
`pod 'DVPlaylistPlayer', :git=>'https://github.com/denivip/DVPlaylistPlayer'`

Then you enter magic words to your console:
`pod install`

and DVPlaylistPlayer will be automatically downloaded and installed to your project. All the frameworks required for 
player will also be added automatically.
Just don't forget to use Workspace file instead of *.xcodeproj from now!

###Source files###
The other way is to add source files to your project directly by copying them. Here is the algorithm.
 - Clone this repository or download zip archive with SDK.
 - Open your project in XCode and drag-and-drop all files from directory 'DVPlaylistPlayer' to your project.
 - import class DVPlaylistPlayer.h to any implementation or header file where you want to use it.
 
###Framework###
Also you can include DVPlaylistPlayer as a framework.
 - Clone the repository or download zip archive with SDK.
 - Enter `pod install` in the console. This will install THObservers required by the player SDK project.
 - Under directory 'Playlist Player SDK' find and open the project 'PlaylistPlayerSDK.xcodeproj' in XCode.
 - Choose 'PlayerPlaylistAggregate' target and build the project.
 - File 'DVPlaylistPlayer.framework' will now appear under 'Products' directory of this project. Now you can easily link
 you project with this framework and use it. But don't forget to include all the required frameworks to your project also!
 
##Usage##
DVPlaylistPlayer is really easy to use. All you need to start playing media is to create an instance:

`self.playlistPlayer = [[DVPlaylistPlayer alloc] init];`

Provide it with the data source:

`self.playlistPlayer.dataSource = some id<DVPlaylistPlayerDataSource>;`

And play:

`[self.playlistPlayer playMediaWithIndex:0];`

That is all. Data source takes AVPlayerItem files in it's method and passes it to player. DVPlaylistPlayer does all the
player setup for you.
Playlist player have all the regular player controls as methods. Here's the list.
 - playMediaWithIndex:
 - resume
 - pause
 - stop
 - next
 - previous
 - setVolume
 - mute
 - unmute
 
Additionally you can receive events about playing state changes and set a periodic time observer. To receive events you 
just have to set the 'delegate' property on player. Delegate object must correspond to protocol DVPlaylistPlayerDelegate. To set a
periodic time observer you must call method `addPeriodicTimeObserverForInterval:queue:usingBlock:`. 
Also if you need to have an access to the AVPlayer instance that is lying at the heart of DVPlaylistPlayer - you're 
welcome. It is in public interface.

##Requirements##
DVPlaylistPlayer requires iOS 5.0 as minimum OS version.
This project uses ARC.
