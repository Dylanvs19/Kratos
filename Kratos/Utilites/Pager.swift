//
//  Pager.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/9/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

/// `PagingDataRequester` provides paging data in response to `Pager` requests.
public protocol PagingDataSource: class {
    associatedtype Data
    /// Return results for a given page of data.
    func makeRequestForResults(at page: UInt, onComplete: @escaping (([Data]?) -> Void))
}

/// `PagingView` is the View that contains the UI that the pager interacts with.
public protocol PagingView: class {
    /// The CollectionView, TableView, or Scrollview that shows the data that the pager retreives.
    var scrollView: UIScrollView { get }
    /// An optional view that appears while data is being refreshed.
    var loadMoreSpinnerView: LoadMoreSpinnerView? { get set }
}

/// `PagingCollectionViewDelegate` acts as the UICollectionViewDelegate or UITableViewDelegate for a collectionView
/// or tableView with paging data.
public protocol  PagingViewDelegate: class {
    associatedtype Data
    /// The variable that contains the data for the Datasource. `Pager` will sync this value
    /// when it receives data.
    /// - When `data` gets new Data, `cellMap` should be set via
    /// `data`'s `didSet` method using the Array's `groupedBySection` or `asSingleSection`
    /// methods.
    /// - After cellMap is set within `didSet` append(data: [Data], to oldData: [Data]) should be called to append new cells to the UICollectionView or UITableView.
    var data: [Data] { get set }
}

public protocol PagingCollectionViewDelegate: PagingViewDelegate {
    var collectionView: UICollectionView! { get }
}

public protocol PagingTableViewDelegate: PagingViewDelegate {
    var tableView: UITableView! { get }
}


/// `Pager` handles the brunt of paging concerns for `PagingView` with paging data. These concerns include:
/// - Detecting when a new page of data is required
/// - Initiating paging data requests
/// - Updating the collectionView to represent request state
/// - Responding to completed requests by syncing displayed data
/// - Handling the showing and hiding of a loading indicator
public class Pager<DataSource, Delegate, View>: NSObject where DataSource: PagingDataSource,
             Delegate: NSObject,
             Delegate: PagingViewDelegate,
             View: PagingView,
             DataSource.Data == Delegate.Data {
    // MARK: - Properties
    // MARK: Delegates
    /// A delegate responsible for requesting and returning paging data.
    private weak var dataSource: DataSource?
    /// A delegate responsible for managing a UIView's UI options associated with the pager.
    private weak var view: View?
    /// A delegate responsible for managing UI interactions with data new
    private weak var delegate: Delegate?
    
    // MARK: Settings
    /// The number of results displayed per page. By default, 20.
    public var pageLimit: UInt = 20
    /// The distance from the bottom of the scrollview that, when exceeded, will triger a fetch for a new page of data. If 100,
    /// for example, a new page will be fetched when a user scrolls within 100 points of the bottom of the scrollview.
    var remainingScrollDistanceTrigger: CGFloat = 150
    /// Height for loading indicator view at the bottom of the scrollView.
    var loadingViewAreaHeight: CGFloat = 50
    /// New Data that is coming back from the `makeRequestForResults` method.
    var newPageData: [DataSource.Data]? = nil
    
    var loadMoreSpinnerView: LoadMoreSpinnerView? {
        return view?.loadMoreSpinnerView
    }
    // Disables paging.
    var isDisabled = false {
        didSet {
            if isDisabled {
                isFinishedPaging = false
                hideLoadMoreSpinner(nil)
            }
        }
    }
    
    // MARK: Private
    /// Pointer to memory location for ScrollView contentOffset used with KVO
    private var kvoScrollViewDidScrollContext: UnsafeMutableRawPointer?
    /// The collectionView or tableView displaying paging data.
    var scrollView: UIScrollView? {
        let scrollView = view?.scrollView
        /// adding Observer for contentOffset Property on ScrollView
        if let scrollView = scrollView {
            scrollView.addObserver(self,
                                   forKeyPath: "contentOffset",
                                   options: [.new, .old],
                                   context: &self.kvoScrollViewDidScrollContext)
        }
        return scrollView
    }
    private var lastResultCount = UInt(0)
    /// A bool Value that indicates whether the makeRequestForResults method is still updating.
    private var isUpdating = false
    /// A Bool that returns true when, after a page request goes out, data that is returned is less than pageLimit - indicating that there is not more data to fetch.
    private var isFinishedPaging = false
    /// The number of results displayed.
    //private var resultCount: UInt = 0
    
    private var pageNumber: UInt = 1
    
    private var _viewNeedsUpdate = false
    private var viewNeedsUpdate: Bool {
        get {
            var needsUpdate = false
            lock { needsUpdate = _viewNeedsUpdate }
            return needsUpdate
        } set {
            lock { _viewNeedsUpdate = newValue }
        }
    }
    
    let _lockQueue = DispatchQueue(label: "lock")
    private func lock(function: () -> Void) {
        _lockQueue.sync {
            function() 
        }
    }
    
    private var loadMoreSpinnerEnabled = false
    
    private var isDisplayingSpinner = false
    
    private var isScrolling = false
    
    // MARK: - Initialization
    /// Assign required components to the `Pager`.
    ///
    /// - parameter view: The collectionView displaying paging data.
    /// - parameter dataSource: The component responsible for fetching paging data.
    /// - parameter delegate: The component responsible for managing the paging collectionView.
    public func set(view: View,
                    dataSource: DataSource,
                    delegate: Delegate) {
        self.view = view
        self.dataSource = dataSource
        self.delegate = delegate
    }
    /// Adds LoadMoreSpinner View to View. Must not be nil on PagerView.
    public func addLoadMoreSpinnerView() {
        loadMoreSpinnerEnabled = true
        if let loadMoreSpinnerView = loadMoreSpinnerView,
            let scrollView = self.scrollView,
            let superView = scrollView.superview ,view?.loadMoreSpinnerView?.superview == nil {
            scrollView.superview?.addSubview(loadMoreSpinnerView)
            loadMoreSpinnerView.translatesAutoresizingMaskIntoConstraints = false
            loadMoreSpinnerView.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
            loadMoreSpinnerView.widthAnchor.constraint(equalTo: superView.widthAnchor).isActive = true
            loadMoreSpinnerView.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        }
    }
    
    /// Set initial data on the `Pager`.
    ///
    /// - parameter data: The initial data displayed in the paging collectionView.
    /// - note: Setting initial data will trigger UI refreshes and dataSource syncs.
    public func set(initialData data: [DataSource.Data]) {
        if !isDisabled {
            delegate?.data = []
            delegate?.data = data
            pageNumber += 1
            isFinishedPaging = false
        }
    }
    
    // MARK: - <KVO>
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoScrollViewDidScrollContext,
            let scrollView = object as? UIScrollView {
            scrollViewDidScroll(scrollView: scrollView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isDisabled {
            isScrolling = true
            let verticalOffset = scrollView.contentOffset.y
            /// Determines whether scrollView has stopped.
            
            let when = DispatchTime.now() + 0.125
            DispatchQueue.main.asyncAfter(deadline: when) {
                if scrollView.contentOffset.y == verticalOffset {
                    self.isScrolling = false
                    if self.viewNeedsUpdate && !self.isUpdating {
                        // Scrolling has ended and an update has been loaded.
                        // Perform update.
                        self.updateView()
                    }
                }
            }
            
            let scrollViewBottomPosition = scrollView.contentOffset.y + scrollView.frame.height
            let didScrollToBottom = (scrollViewBottomPosition >= scrollView.contentSize.height)
            let didScrollToThreshold = (scrollViewBottomPosition >= scrollView.contentSize.height - remainingScrollDistanceTrigger)
            
            if didScrollToBottom {
                if !isUpdating
                    && viewNeedsUpdate {
                    // Scrolling has reached the bottom of the content and an update has been loaded.
                    // Perform view update.
                    updateView()
                } else if isUpdating {
                    // Update has not completed but the user has scrolled to the bottom.
                    // Show loading indicator.
                    if loadMoreSpinnerEnabled && loadMoreSpinnerView?.alpha == 0 {
                        showLoadMoreSpinner()
                    }
                }
            } else if didScrollToThreshold
                && !isFinishedPaging
                && !isUpdating {
                // Still scrolling, but has hit the threshold for queuing a request queue a request.
                page()
            }
        }
    }
    
    /// Calls for newData and, when received, manages when data should be incorporated into View by toggling
    /// viewNeedsUpdate & isUpdating which are triggered in scroll events in scrollViewDidScroll (or by
    /// immediately calling updateView if !isScrolling.)
    private func page() {
        /// Make Request for newData
        
        isUpdating = true
        
        dataSource?.makeRequestForResults(at: pageNumber, onComplete: { [weak self] newData in
            
            guard let `self` = self else {
                debugPrint("Deallocated a pager before a fetch request could complete.")
                return
            }
            
            self.newPageData = newData
            if let data = self.newPageData?.count , data < Int(self.pageLimit) {
                self.isFinishedPaging = true
            }
            
            self.viewNeedsUpdate = true
            self.isUpdating = false
            
            if !self.isScrolling {
                // When not scrolling, the view may be updated immediately without negative visual effects.
                // Otherwise, updates will trigger on scroll events in `scrollViewDidScroll`.
                self.updateView()
            }
        })
    }
    
    func updateView() {
        
        guard let data = newPageData else {
            return
        }
        
        newPageData = nil
        viewNeedsUpdate = false
        
        self.hideLoadMoreSpinner { (success) in
            self.updateDataSource(with: data)
        }
    }
    
    // MARK: - Paging state handling
    private func updateDataSource(with newData: [Delegate.Data]) {
        if let data = delegate?.data , !data.isEmpty && !isDisabled {
            delegate?.data += newData
            //self.resultCount = UInt(delegate?.data.count ?? 0)
            self.pageNumber += 1
        }
    }
    
    // MARK: - LoadMoreSpinner Handling
    
    func showLoadMoreSpinner() {
        isDisplayingSpinner = true
        if let loadMoreSpinnerView = loadMoreSpinnerView,
            let scrollView = scrollView {
            
            loadMoreSpinnerView.superview?.bringSubview(toFront: loadMoreSpinnerView)
            loadMoreSpinnerView.startSpinning()
            
            var insets = scrollView.contentInset
            insets.bottom += loadingViewAreaHeight
            
            scrollView.contentInset = insets
            
            UIView.animate(withDuration: 0.25) {
                loadMoreSpinnerView.transform = CGAffineTransform(translationX: 0, y: -self.loadingViewAreaHeight)
            }
            let bottomOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.bounds.size.height + loadingViewAreaHeight))
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    func hideLoadMoreSpinner(_ onCompletion: ((Bool) -> ())?) {
        if let loadMoreSpinnerView = loadMoreSpinnerView,
            let scrollView = scrollView , isDisplayingSpinner == true {
            self.isDisplayingSpinner = false
            loadMoreSpinnerView.stopSpinning()
            
            UIView.animate(withDuration: 0.5, delay: 0.25, options: [], animations: {
                scrollView.contentInset = .zero
                loadMoreSpinnerView.transform = .identity
            }, completion: { (success) in
                onCompletion?(success)
            })
        } else {
            onCompletion?(true)
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "contentOffset")
    }
}
