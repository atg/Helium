Helium (will be) a _simple_ RSS reader for OS X.

# Features #

* Mark feeds as either "Important" or "Filler".
* * Unread posts from important feeds always appear above unread posts from filler feeds.
* * Important feeds contribute to the unread count.
* Option to display posts from certain feeds as either full webviews of the &lt;url>, or plain HTML of the &lt;description>.
* Unread posts move up the source list. Read posts move down as they are displaced by unread posts.
* Growl notifications

# Technical Details #

* Garbage Collected
* NSXMLDocument for parsing (for now)
* Core Data for storage