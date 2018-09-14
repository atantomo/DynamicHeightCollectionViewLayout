# DynamicHeightCollectionViewLayout
Smooth scrolling solution for collection view cells with dynamic/variable height.

## Overview
The objective of this app is to provide an additional insight for shoppers prior to making a purchase decision. Users are able to observe the trends and growth of products through this app. Aside from price, the app also tracks reviews, which helps users who are especially active in gathering word-of-mouth to accumulate data.

## Build
The project was written in Swift 2.2, therefore it is recommended to build it using **Xcode 7.3** or above. The app is fully compatible to run on both a physical device and the simulator.

## Features

![Alt text](demo.gif)

The app uses [Rakuten Ichiba API](https://webservice.rakuten.co.jp/document/) to retrieve product & category / genre data.

## Features

The main feature of the app is creating a snapshot of search results to record the state of products on an e-commerce site. The following is the list of states that are tracked within the app:
  * Price
  * Review count & average
  * Availability / stock

**Persistence:** All data (item information, search settings, change history, and thumbnail / original images) are _persisted_ within the app.

Here is a more detailed breakdown of the features by view controller:

|View Controller | Feature|
|--------------- | -------|
|Browser | Displays the list of search result from 'Search setting' view controller. This is used as the base snapshot to compare against when the 'Update' button on the bar is pressed|
|| After pressing the 'Update' button, user will be notified of any updates on the items within the current snapshot|
|| Items are divided into 3 categories, namely 'New' (items appeared for the first time), 'Observing' (currently observed items), 'Out of sight' (items that have fell out of rank / outside of the current search scope)|
|Search setting | Option to specify name and category of item to search|
|| Saves search setting on a successful search. Any other input data that does not reach this point _will be discarded_|
|Item detail | Displays the attributes of the selected item from 'Browser' view controller.|
|| Dynamically loads the original version of the item image (larger size)|
|| Shows the recent change on attributes (if there's any) visually using icons|
|| A button that directs user to the product page on the e-commerce site|
|Item history | Displays the full change history of the selected attribute from 'Item detail' view controller|

## Test
Because the app observe the changes of real-time data, it may be difficult to examine them in a short period of time. One of the easier ways to test this is to execute a query on the SQLite database, such as:

```
-- Alter the price of the first 3 items
UPDATE ZPRICEHISTORY SET ZITEMPRICE = 1000 WHERE Z_PK IN (SELECT Z_PK FROM ZPRICEHISTORY LIMIT 3)
```

Then, press the 'Update' button on the 'Browser' view controller to observe the changes.

## Limitations
* The genre selection is only available in Japanese (the only language supported by the API)
* The app is only capable of storing one set of snapshot at a time. To perform a new search, all product data stored in the device has to be deleted as they can no longer be tracked
* Does not support push notification

## Future plan
* Provide wider selection of e-commerce platforms
* Store and manage multiple snapshots (search results) instead of just one
* Customize the ordering of search results (by popularity, price, etc.)
