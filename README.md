# MovieSearch

**A coding exercise by Fritz Anderson** (`fritza@mac.com`)  
version 1.0 (2) of November 22, 2019

**Public repository**: The repo home page is [`https://github.com/fritza/MovieSearch`](https://github.com/fritza/MovieSearch). The repository URL, or a `.zip` archive, can be had from there.

---

_deleted_  
 **Executable**: This initial release is in review. I am now accepting Testflight addresses.~
 
 ---

It requires iOS 13.2, but does not use SwiftUI. iOS 13 has probably 70–80% penetration so far, with iOS 12 virtually all the rest. _As of  this month,_ you can’t demand 13. However, I’ve left Xcode’s preferred target OS, because adapting the source to scenes-or-not didn’t seem like the best use of my time.

---

**Document changes from build 2** are called out by horizontal rules in the text. Sorry for the conflict with the rules GitHub's CSS displays after section headers.

* Added instructions for installing CocoaPods frameworks, which are derived data and not inserted in the project repository.

**Binary/project changes:**

* Supplied other missing source files (`CG+extensions.swift`, `LargeResultCell.xib`)
* Updated the build number.

## Installation

### Clone the Workspace

First, check the project files out of the GitHub repository. There are two options.

!. Using the **Welcome to Xcode (⇧⌘1)** window, select **Clone an existing project**.  Enter the repository URL (``https://github.com/fritza/MovieSearch.git`) in the text field at the top. Click the **Clone** button, then select the _master_ branch, then use the save-file panel to name and choose a location for the project.

2. On the command line, choose a location in which to place the project directory, and clone the project.

```
$ cd MyContainerDirectory
$ git clone "https://github.com/fritza/MovieSearch.git"
```

If you clone by way of Xcode, Xcode will open the project automatically. Close the project window; you'll be using the Xcode Workspace generated from the next step, **CocoaPods**.  


### CocoaPods

_MovieSearch_ uses frameorks from Alamofire, which are most easily installed by way of the CocoaPods package manager. You must install CocoaPods and Alamofire (which the `Podfile` file identifies), or the project will not build; if that happens, you may have omitted these steps.

Make sure you've installed CocoaPods

```
sudo gem install cocoapods
```

> macOS 10.15 Catalina has tightened its support for downloaded binaries, including script interpreters. Either build a Ruby locally via a package manager like `rvm`, or use the _System Settings/Security & Privacy/General_ to authorize the use of the interpreter.

Using the command line, change the working directory to the one cloned by `git` or Xcode, and install Alamofire

```
$ cd MyContainerDirectory
$ pod install
```

> Troubleshooting the CocoaPode command is beyond the scope of this document; follow the instructions in any error message, or paste them into a web search.

### Open the Xcode Workspace document

When CocoaPods installs frameworks, it modifies the build process by wrapping the project in an Xcode framework file. Find it in Finder and open it.

The project will be ready for building and use.

---

## Usage

The initial screen (`FormController`) is simple, but adequate to framing an OMDb name/year query. 

* The segmented control chooses Movie/Series/Episode.
* The **Title** field accepts words to match in titles. So as to avoid prohibitively long result lists, there must be at least four characters to enable the **Search** button.
* The **Year** field is optional. The string, if any, must evaluate to an integer in `(1850...2200)`; anything other than that or blank will disable the **Search** button.

Tapping Search loads the results table (`ResultsController`) and transmits the query. OMDb pages its results; the app serializes the fetches and updates the table as records arrive. Because the backing array is sorted (year descending, then title) each time, the table looks unstable during the load. There are three possible responses.

* Use the `UITableView` methods to animate the insertions. The list would still be visually unstable, but it would be less jarring.
* Never sorting the table. This would make it less usable.

---

* Withholding the table until all the results are in, using a blocking overlay (with **Cancel** button) in the mean time. This would be better, but beyond minimal (let’s call it “MVP”) requirements, and demand more detail work than would fit into a quick project.

---
* Displaying progress text (**133 of 456 results**) in the title in the navigation bar.

The cells are designed for more information than the records provide; title and year are the only user-visible text. The excess labels will be removed in a later build.

The phrase _For rent_ in the bottom of the cell is a carryover from early tutorials on OS X development, in which "This Space for Rent" was the traditional marker for UI elements as yet unsupported.

---

## Implementation (some of it)

The app uses the `Alamofire`, `Alamofireimage`, and `AlamofireNetworkActivityIndicator` frameworks for network transactions and asynchronous caching and loading of images. The activity-indicator framework may or may not work — I haven’t seen the activity spinner in a status bar, but I’ve seen only Simulator devices or my iPhone Xr, so it may be there after all. Issue for testing.

I translate incoming JSON using the `Decodable` protocol. This can be fragile against variations in the REST provider’s schema. I try to present zero-results to the ResultsController, but I wish I could adapt better. (Optionals can cover potentially-missing data, but the code becomes gnarly enough that I’d like to see how it does in the field first.)

## Compromises/Bugs

_“Beyond spec” means “I’d love to do it, I even think it’s necessary, but it’s not required at this phase and I’m on an implicit deadline.”_

---

I should provide a better image for a poster placeholder; this one isn’t tall enough.  **Bug/incomplete.**

The result cells are designed for more information than the records provide; title and year are the only user-visible text. The excess fields will be removed in a later build.  **Bug/incomplete.**

---

The app does nothing for state restoration. At minimum it should save the criteria for the most recent search. **Beyond spec.**

---

The results table should display incoming result batches more gracefully. See **Usage**, above. **Bug/incomplete.**

---

An earlier version used an in-memory Core Data store for convenience in searching, sorting, and filtering in the Results view. This may be an interesting enhancement, but shouldn’t be pursued without further discussion. The results list can be expected to be short enough (max << 1000, min = 0, median ≈ 100) that in-memory processing is practical. Barring experience in testing and in the field, **not necessary**.

The backing results array is sorted (year descending, title), which looks ideal for a unique-keyed `Dictionary<Int, [SearchElement]>`, and from there a table sectioned by year. **Beyond spec.**
