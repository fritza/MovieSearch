# MovieSearch

**A coding exercise by Fritz Anderson** (`fritza@mac.com`)  
version 1.0 (1) of November 17, 2019

**Public repository**: [`https://github.com/fritza/MovieSearch`](https://github.com/fritza/MovieSearch)

**Executable**: This initial release is in review. I am now accepting Testflight addresses.

It requires iOS 13.2, but does not use SwiftUI. iOS 13 has probably 70–80% penetration so far, with iOS 12 virtually all the rest. _As of  this month,_ you can’t demand 13. However, I’ve left Xcode’s preferred target OS, because adapting the source to scenes-or-not didn’t seem like the best use of my time.

## Usage

The initial screen (`FormController`) is simple, but adequate to framing an OMDb name/year query. 

* The segmented control chooses Movie/Series/Episode.
* The **Title** field accepts words to match in titles. So as to avoid prohibitively long result lists, there must be at least four characters to enable the **Search** button.
* The **Year** field is optional. The string, if any, must evaluate to an integer in `(1850...2200)`; anything other than that or blank will disable the **Search** button.

Tapping Search loads the results table (`ResultsController`) and transmits the query. OMDb pages its results; the app serializes the fetches and updates the table as records arrive. Because the backing array is sorted (year descending, then title) each time, the table looks unstable during the load. There are three possible responses.

* Use the `UITableView` methods to animate the insertions. The list would still be visually unstable, but it would be less jarring.
* Never sorting the table. This would make it less usable.
* Withholding the table until all the results are in, using a blocking overlay (with **Cancel** button) in the mean time. This would be better, but beyond minimal (let’s call it “MVP”) requirements, and demand more detail work than would fit into a quick project.

The cells are designed for more information than the records provide; title and year are the only user-visible text. The excess fields will be removed in a later build.

## Implementation (some of it)

The app uses the `Alamofire`, `Alamofireimage`, and `AlamofireNetworkActivityIndicator` frameworks for network transactions and asynchronous caching and loading of images. The activity-indicator framework may or may not work — I haven’t seen the activity spinner in a status bar, but I’ve seen only Simulator devices or my iPhone Xr, so it may be there after all. Issue for testing.

I translate incoming JSON using the `Decodable` protocol. This can be fragile against variations in the REST provider’s schema. I try to present zero-results to the ResultsController, but I wish I could adapt better. (Optionals can cover potentially-missing data, but the code becomes gnarly enough that I’d like to see how it does in the field first.)

## Compromises/Bugs

_“Beyond spec” means “I’d love to do it, I even think it’s necessary, but it’s not required at this phase and I’m on an implicit deadline.”_

I should provide a better image for a poster placeholder; this one isn’t tall enough.

The app does nothing for state restoration. At minimum it should save the criteria for the most recent search. **Beyond spec.**

An earlier version used an in-memory Core Data store for convenience in searching, sorting, and filtering in the Results view. This may be an interesting enhancement, but shouldn’t be pursued without further discussion. The results list can be expected to be short enough (max << 1000, min = 0, median ≈ 100) that in-memory processing is practical. Barring experience in testing and in the field, **not necessary**.

The backing results array is sorted (year descending, title), which looks ideal for a unique-keyed `Dictionary<Int, [SearchElement]>`, and from there a table sectioned by year. **Beyond spec.**
