# MovieSearch

**A coding exercise by Fritz Anderson** (`fritza@mac.com`)  
November 17, 2019

**Public repository**: [`https://github.com/fritza/MovieSearch`](https://github.com/fritza/MovieSearch)

## Compromises

**Fetch limits**: The specification implies that the (searchable) results table should represent all matches to the initial query. However, contrary to the spec — and not clear from the API docs — search results are paged 10 at a time out of potentially hundreds. Each page must be fetched separately. In addition to pulling a poster image for each item, fully-populating the results table could put a substantial dent in the 1000-transaction limit for the free API key.

This build will therefore pull no more than 15 pages for any query. This is a proof-of-concept limit only.

**Enabling fetches**: Very short search strings would yield very long result lists. The PoC fetch limit (≤ 150 items) incidentally finesses the problem, but how to control it should be a matter for peer and client discussion. In a real project, this would be a stopgap. For this demo, the app does not enable the **Search** button until the title string is three characters or more.


