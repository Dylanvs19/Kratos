//
//  Pager.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import Foundation
//
///// `PagingDataRequester` provides paging data in response to `Pager` requests.
//protocol PagingDataSource: class {
//    associatedtype Data
//    /// Return results for a given page of data.
//    func makeRequestForResults(at offset: UInt, withLimit limit: UInt, onComplete: ([Data]? -> Void))
//}
//
///// `PagingView` is the View that contains the UI that the pager interacts with.
//protocol PagingView: class {
//    /// The CollectionView, TableView, or Scrollview that shows the data that the pager retreives.
//    var scrollView: UIScrollView { get }
//    /// An optional view that appears while data is being refreshed.
//    var loadMoreSpinnerView: LoadMoreSpinnerView? { get set }
//}
//
///// `PagingCollectionViewDelegate` acts as the UICollectionViewDelegate or UITableViewDelegate for a collectionView
///// or tableView with paging data.
//protocol  PagingViewDelegate: class {
//    associatedtype Data
//    /// The variable that contains the data for the Datasource. `Pager` will sync this value
//    /// when it receives data.
//    /// - When `data` gets new Data, `cellMap` should be set via
//    /// `data`'s `didSet` method using the Array's `groupedBySection` or `asSingleSection`
//    /// methods.
//    /// - After cellMap is set within `didSet` append(data: [Data], to oldData: [Data]) should be called to append new cells to the UICollectionView or UITableView.
//    var data: [Data] { get set }
//    /// The variable that contains the formatted data for the CollectionView or TableView.
//    var cellMap: [Int: [Data]] { get set }
//    /// A function in charge of adding new data to old data
//    func append(data: [Data], to oldData: [Data])
//    /// Inserts new IndexPaths to PagingView's ScrollView
//    func insert(indexPaths: [NSIndexPath])
//    /// Reloads data for PagingView's ScrollView
//    func reloadView()
//}
//
///// `PagingViewDelegate` extension provides generic implementation for append(data: [Data], to oldData: [Data])
//extension PagingViewDelegate {
//    /// Builds IndexPath Array based on an updated CellMap and inserts new cells
//    /// into CollectionView or TableView based on the IndexPath Array.
//    func append(data: [Data], to oldData: [Data]) {
//        guard data.count != oldData.count else {
//            return
//        }
//        if data.count > 20 && !oldData.isEmpty {
//            let indexPaths = flatMap(cellMap)
//            let sliced = slice(indexPaths,
//                               from: oldData.count,
//                               to: indexPaths.count - 1)
//            insert(sliced)
//        } else {
//            reloadView()
//        }
//    }
//    
//    private func flatMap(cellMap: [Int: [Data]]) -> [NSIndexPath] {
//        var indexPaths = [NSIndexPath]()
//        for key in cellMap.keys.sort(<) {
//            if let values = cellMap[key] {
//                (0..<values.count).forEach {
//                    indexPaths.append(NSIndexPath(forItem: $0, inSection: key))
//                }
//            }
//        }
//        
//        return indexPaths
//    }
//    
//    private func slice(indexPaths: [NSIndexPath],
//                       from: Int,
//                       to: Int) -> [NSIndexPath] {
//        if from < to {
//            return Array(indexPaths[from...to])
//        }
//        
//        return indexPaths
//    }
//}
//
//protocol PagingCollectionViewDelegate: PagingViewDelegate {
//    var collectionView: UICollectionView! { get }
//}
//
///// `PagingViewDelegate` extension provides specific implementation for
///// insert(indexPaths: [NSIndexPath]) and reloadView for UICollectionViews
//extension PagingCollectionViewDelegate {
//    func insert(indexPaths: [NSIndexPath]) {
//        print("insert")
//        
//        collectionView.performBatchUpdates({
//            // Determine if new sections must be inserted.
//            let oldFinalSection = self.collectionView.numberOfSections() - 1
//            let newFinalSection = indexPaths.last?.section ?? 0
//            
//            if oldFinalSection < newFinalSection {
//                // Insert new sections.
//                let range = NSRange(location: oldFinalSection + 1,
//                                    length: newFinalSection - oldFinalSection)
//                let indexSet = NSIndexSet(indexesInRange: range)
//                print(indexPaths)
//                self.collectionView.insertSections(indexSet)
//            }
//            
//            // Insert items.
//            self.collectionView.insertItemsAtIndexPaths(indexPaths)
//        }, completion: nil)
//    }
//    
//    func reloadView() {
//        collectionView.reloadData()
//    }
//}
//
///// `Pager` handles the brunt of paging concerns for `PagingView` with paging data. These concerns include:
///// - Detecting when a new page of data is required
///// - Initiating paging data requests
///// - Updating the collectionView to represent request state
///// - Responding to completed requests by syncing displayed data
///// - Handling the showing and hiding of a loading indicator
//class Pager<DataSource, Delegate, View where DataSource: PagingDataSource,
//		  Delegate: NSObject,
//    Delegate: PagingViewDelegate,
//    View: PagingView,
//DataSource.Data == Delegate.Data>: NSObject {
//    // MARK: - Properties
//    // MARK: Delegates
//    /// A delegate responsible for requesting and returning paging data.
//    private weak var dataSource: DataSource?
//    /// A delegate responsible for managing a UIView's UI options associated with the pager.
//    private weak var view: View?
//    /// A delegate responsible for managing UI interactions with data new
//    private var delegate: Delegate?
//    
//    // MARK: Settings
//    /// The number of results displayed per page. By default, 20.
//    var pageLimit: UInt = 20
//    /// The distance from the bottom of the scrollview that, when exceeded, will triger a fetch for a new page of data. If 100,
//    /// for example, a new page will be fetched when a user scrolls within 100 points of the bottom of the scrollview.
//    var remainingScrollDistanceTrigger: CGFloat = 150
//    /// Height for loading indicator view at the bottom of the scrollView.
//    var loadingViewAreaHeight: CGFloat = 50
//    /// New Data that is coming back from the `makeRequestForResults` method.
//    var newPageData: [DataSource.Data]? = nil
//    
//    var loadMoreSpinnerView: LoadMoreSpinnerView? {
//        return view?.loadMoreSpinnerView
//    }
//    // Disables paging.
//    var isDisabled = false {
//        didSet {
//            if isDisabled {
//                isFinishedPaging = false
//                hideLoadMoreSpinner(nil)
//            }
//        }
//    }
//    
//    // MARK: Private
//    /// Pointer to memory location for ScrollView contentOffset used with KVO
//    private var kvoScrollViewDidScrollContext: UInt8 = 1
//    /// The collectionView or tableView displaying paging data.
//    var scrollView: UIScrollView? {
//        let scrollView = view?.scrollView
//        /// adding Observer for contentOffset Property on ScrollView
//        if let scrollView = scrollView {
//            scrollView.addObserver(self,
//                                   forKeyPath: "contentOffset",
//                                   options: [.New, .Old],
//                                   context: &self.kvoScrollViewDidScrollContext)
//        }
//        return scrollView
//    }
//    private var lastResultCount = UInt(0)
//    /// A bool Value that indicates whether the makeRequestForResults method is still updating.
//    private var isUpdating = false
//    /// A Bool that returns true when, after a page request goes out, data that is returned is less than pageLimit - indicating that there is not more data to fetch.
//    private var isFinishedPaging = false
//    /// The number of results displayed.
//    private var resultCount: UInt = 0
//    
//    private var _viewNeedsUpdate = false
//    private var viewNeedsUpdate: Bool {
//        get {
//            var needsUpdate = false
//            lock { needsUpdate = _viewNeedsUpdate }
//            return needsUpdate
//        } set {
//            lock { _viewNeedsUpdate = newValue }
//        }
//    }
//    let _lockQueue = dispatch_queue_create("lock", nil)
//    private func lock(@noescape function: () -> Void) {
//        dispatch_sync(_lockQueue, function)
//    }
//    
//    private var loadMoreSpinnerEnabled = false
//    
//    private var isDisplayingSpinner = false
//    
//    private var isScrolling = false
//    
//    // MARK: - Initialization
//    /// Assign required components to the `Pager`.
//    ///
//    /// - parameter view: The collectionView displaying paging data.
//    /// - parameter dataSource: The component responsible for fetching paging data.
//    /// - parameter delegate: The component responsible for managing the paging collectionView.
//    func set(view view: View,
//             dataSource: DataSource,
//             delegate: Delegate) {
//        self.view = view
//        self.dataSource = dataSource
//        self.delegate = delegate
//    }
//    /// Adds LoadMoreSpinner View to View. Must not be nil on PagerView.
//    func addLoadMoreSpinnerView() {
//        loadMoreSpinnerEnabled = true
//        if let loadMoreSpinnerView = loadMoreSpinnerView,
//            let scrollView = self.scrollView where view?.loadMoreSpinnerView?.superview == nil {
//            scrollView.superview?.addSubview(loadMoreSpinnerView)
//            loadMoreSpinnerView.translatesAutoresizingMaskIntoConstraints = false
//            let screen = UIScreen.mainScreen().bounds
//            //Centers Loading Spinner to ScrollView's SuperView
//            let horizontalPin = NSLayoutConstraint.constraintsWithVisualFormat(
//                "|-(0)-[view(==\(screen.width))]-(0)-|",
//                options: .AlignAllLeading,
//                metrics: nil,
//                views: ["view": loadMoreSpinnerView]
//            )
//            /// vertically pins Loading Spinner to Bottom of ScrollView's SuperView
//            let verticalPin = NSLayoutConstraint.constraintsWithVisualFormat(
//                "V:[view(50)]-(-50)-|",
//                options: .AlignAllLeading,
//                metrics: nil,
//                views: ["view": loadMoreSpinnerView]
//            )
//            
//            scrollView.superview?.addConstraints(horizontalPin)
//            scrollView.superview?.addConstraints(verticalPin)
//        }
//    }
//    
//    /// Set initial data on the `Pager`.
//    ///
//    /// - parameter data: The initial data displayed in the paging collectionView.
//    /// - note: Setting initial data will trigger UI refreshes and dataSource syncs.
//    func set(initialData data: [DataSource.Data]) {
//        if !isDisabled {
//            delegate?.data = []
//            delegate?.data = data
//            print("data count \(data.count)")
//            resultCount = UInt(data.count)
//            isFinishedPaging = false
//        }
//    }
//    
//    // MARK: - <UIScrollViewDelegate>
//    override func observeValueForKeyPath(keyPath: String?,
//                                         ofObject object: AnyObject?,
//                                         change: [String : AnyObject]?,
//                                         context: UnsafeMutablePointer<Void>) {
//        if context == &kvoScrollViewDidScrollContext,
//            let scrollView = object as? UIScrollView {
//            scrollViewDidScroll(scrollView)
//        }
//    }
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if !isDisabled {
//            isScrolling = true
//            let verticalOffset = scrollView.contentOffset.y
//            /// Determines whether scrollView has stopped.
//            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.125 * Double(NSEC_PER_SEC)))
//            dispatch_after(delayTime, dispatch_get_main_queue()) {
//                if scrollView.contentOffset.y == verticalOffset {
//                    self.isScrolling = false
//                    if self.viewNeedsUpdate && !self.isUpdating {
//                        // Scrolling has ended and an update has been loaded.
//                        // Perform update.
//                        self.updateView()
//                    }
//                }
//            }
//            let scrollViewBottomPosition = scrollView.contentOffset.y + scrollView.frame.height
//            let didScrollToBottom = (scrollViewBottomPosition >= scrollView.contentSize.height)
//            let didScrollToThreshold = (scrollViewBottomPosition >= scrollView.contentSize.height - remainingScrollDistanceTrigger)
//            
//            if didScrollToBottom {
//                if !isUpdating
//                    && viewNeedsUpdate {
//                    // Scrolling has reached the bottom of the content and an update has been loaded.
//                    // Perform view update.
//                    updateView()
//                } else if isUpdating {
//                    // Update has not completed but the user has scrolled to the bottom.
//                    // Show loading indicator.
//                    if loadMoreSpinnerEnabled && loadMoreSpinnerView?.alpha == 0 {
//                        showLoadMoreSpinner()
//                    }
//                }
//            } else if didScrollToThreshold
//                && !isFinishedPaging
//                && !isUpdating {
//                // Still scrolling, but has hit the threshold for queuing a request queue a request.
//                page()
//            }
//        }
//    }
//    
//    /// Calls for newData and, when received, manages when data should be incorporated into View by toggling
//    /// viewNeedsUpdate & isUpdating which are triggered in scroll events in scrollViewDidScroll (or by
//    /// immediately calling updateView if !isScrolling.)
//    private func page() {
//        /// Make Request for newData
//        
//        isUpdating = true
//        
//        dataSource?.makeRequestForResults(at: resultCount, withLimit: pageLimit, onComplete: { [weak self] newData in
//            
//            guard let `self` = self else {
//                debugPrint("Deallocated a pager before a fetch request could complete.")
//                return
//            }
//            
//            self.newPageData = newData
//            
//            if self.newPageData?.count < Int(self.pageLimit) {
//                self.isFinishedPaging = true
//            }
//            
//            self.viewNeedsUpdate = true
//            self.isUpdating = false
//            
//            if !self.isScrolling {
//                // When not scrolling, the view may be updated immediately without negative visual effects.
//                // Otherwise, updates will trigger on scroll events in `scrollViewDidScroll`.
//                self.updateView()
//            }
//        })
//    }
//    
//    func updateView() {
//        
//        guard let data = newPageData else {
//            return
//        }
//        
//        newPageData = nil
//        viewNeedsUpdate = false
//        
//        self.hideLoadMoreSpinner { (success) in
//            self.updateDataSource(with: data)
//        }
//    }
//    
//    // MARK: - Paging state handling
//    private func updateDataSource(with newData: [Delegate.Data]) {
//        if let data = delegate?.data where !data.isEmpty && !isDisabled {
//            delegate?.data += newData
//            self.resultCount = UInt(delegate?.data.count ?? 0)
//        }
//    }
//    
//    // MARK: - LoadMoreSpinner Handling
//    
//    func showLoadMoreSpinner() {
//        isDisplayingSpinner = true
//        if let loadMoreSpinnerView = loadMoreSpinnerView,
//            let scrollView = scrollView {
//            
//            loadMoreSpinnerView.superview?.bringSubviewToFront(loadMoreSpinnerView)
//            loadMoreSpinnerView.startSpinning()
//            
//            var insets = scrollView.contentInset
//            insets.bottom += loadingViewAreaHeight
//            
//            scrollView.contentInset = insets
//            
//            UIView.animateWithDuration(0.25) {
//                loadMoreSpinnerView.transform = CGAffineTransformMakeTranslation(0, -self.loadingViewAreaHeight)
//            }
//            let bottomOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.bounds.size.height + loadingViewAreaHeight))
//            scrollView.setContentOffset(bottomOffset, animated: true)
//        }
//    }
//    
//    func hideLoadMoreSpinner(onCompletion: ((Bool) -> ())?) {
//        if let loadMoreSpinnerView = loadMoreSpinnerView,
//            let scrollView = scrollView where isDisplayingSpinner == true {
//            self.isDisplayingSpinner = false
//            loadMoreSpinnerView.stopSpinning()
//            
//            UIView.animateWithDuration(0.5, delay: 0.25, options: [], animations: {
//                scrollView.contentInset = UIEdgeInsetsZero
//                loadMoreSpinnerView.transform = CGAffineTransformIdentity
//            }, completion: { (success) in
//                onCompletion?(success)
//            })
//        } else {
//            onCompletion?(true)
//        }
//    }
//}
