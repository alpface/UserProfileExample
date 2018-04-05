//
//  BaseProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

fileprivate let HitTestScrollViewCellIdentifier = "HitTestScrollViewCellIdentifier"
fileprivate let HitTestScrollViewSectionIdentifier = "HitTestScrollViewSectionIdentifier"
let ALPNavigationTitleLabelBottomPadding : CGFloat = 15.0;

open class BaseProfileViewController: UIViewController {
    
    // MARK: Public methods
    open func numberOfSegments() -> Int {
        /* 需要子类重写 */
        return 0
    }
    
    open func segmentTitle(forSegment index: Int) -> String {
        /* 需要子类重写 */
        return ""
    }
    
    open func prepareForLayout() {
        /* 需要子类重写 */
    }
    
    open func controller(forSegment index: Int) -> UIViewController {
        /* 需要子类重写 */
        return UIViewController()
    }
    
    // 全局tint color
    open static var globalTint: UIColor = UIColor(red: 42.0/255.0, green: 163.0/255.0, blue: 239.0/255.0, alpha: 1)
    
    
    // Constants
    open let stickyheaderContainerViewHeight: CGFloat = 125
    
    open let bouncingThreshold: CGFloat = 100
    
    open let scrollToScaleDownProfileIconDistance: CGFloat = 60
    
    open var navigationTitleLabelBottomConstraint : NSLayoutConstraint?
    
    open var profileHeaderViewHeight: CGFloat = 160
    
    open let segmentedControlContainerHeight: CGFloat = 46
    
    /// 容器cell最大高度
    open func containerCellMaxHeight() -> CGFloat {
        let maxHeight: CGFloat = self.view.frame.size.height - scrollToScaleDownProfileIconDistance - segmentedControlContainerHeight
        return maxHeight
    }
    
    open var username: String? {
        didSet {
            self.profileHeaderView.usernameLabel?.text = username
            
            self.navigationTitleLabel.text = username
        }
    }
    
    open var nickname : String? {
        didSet {
            self.profileHeaderView.nicknameLabel.text = nickname;
        }
    }
    
    open var profileImage: UIImage? {
        didSet {
            self.profileHeaderView.iconImageView?.image = profileImage
        }
    }
    
    open var locationString: String? {
        didSet {
            self.profileHeaderView.locationLabel?.text = locationString
        }
    }
    
    open var descriptionString: String? {
        didSet {
            self.profileHeaderView.descriptionLabel?.text = descriptionString
        }
    }
    
    open var coverImage: UIImage? {
        didSet {
            self.headerCoverView.image = coverImage
        }
    }
    
    // MARK: Properties
    var currentIndex: Int = 0 {
        didSet {
            self.updateTableViewContent()
        }
    }
    
    var controllers: [UIViewController] = []
    
    var currentController: UIViewController {
        return controllers[currentIndex]
    }
    
    
    fileprivate lazy var mainScrollView: UITableView = {
        let _mainScrollView = HitTestScrollView(frame: self.view.bounds, style: .plain)
        _mainScrollView.delegate = self
        _mainScrollView.dataSource = self
        _mainScrollView.showsHorizontalScrollIndicator = false
        _mainScrollView.backgroundColor = UIColor.white
        _mainScrollView.register(HitTestScrollViewCell.classForCoder(), forCellReuseIdentifier: HitTestScrollViewCellIdentifier)
        if #available(iOS 11.0, *) {
            _mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return _mainScrollView
    }()
    
    fileprivate lazy var headerCoverView: UIImageView = {
        let coverImageView = UIImageView()
        coverImageView.clipsToBounds = true
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.image = UIImage(named: "Firewatch.png")
        coverImageView.contentMode = .scaleAspectFill
        return coverImageView
    }()
    
    fileprivate lazy var profileHeaderView: ProfileHeaderView = {
        let _profileHeaderView = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)?.first as! ProfileHeaderView
        _profileHeaderView.usernameLabel.text = self.username
        _profileHeaderView.locationLabel.text = self.locationString
        _profileHeaderView.iconImageView.image = self.profileImage
        _profileHeaderView.nicknameLabel.text = self.nickname
        return _profileHeaderView
    }()
    
    fileprivate lazy var stickyHeaderContainerView: UIView = {
        let _stickyHeaderContainer = UIView()
        _stickyHeaderContainer.clipsToBounds = true
        return _stickyHeaderContainer
    }()
    
    fileprivate lazy var tableHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let _blurEffectView = UIVisualEffectView(effect: blurEffect)
        _blurEffectView.alpha = 0
        return _blurEffectView
    }()
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let _segmentedControl = UISegmentedControl()
        _segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueDidChange(sender:)), for: .valueChanged)
        _segmentedControl.backgroundColor = UIColor.white
        
        for index in 0..<numberOfSegments() {
            let segmentTitle = self.segmentTitle(forSegment: index)
            _segmentedControl.insertSegment(withTitle: segmentTitle, at: index, animated: false)
        }
        _segmentedControl.selectedSegmentIndex = 0
        return _segmentedControl
    }()
    
    fileprivate lazy var segmentedControlContainer: UITableViewHeaderFooterView = {
        let _segmentedControlContainer = UITableViewHeaderFooterView.init(reuseIdentifier: HitTestScrollViewSectionIdentifier)
        _segmentedControlContainer.contentView.backgroundColor = UIColor.white
        return _segmentedControlContainer
    }()
    
    fileprivate lazy var navigationTitleLabel: UILabel = {
        let _navigationTitleLabel = UILabel()
        _navigationTitleLabel.text = self.username ?? "{username}"
        _navigationTitleLabel.textColor = UIColor.white
        _navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        return _navigationTitleLabel
    }()
    
    fileprivate var debugTextView: UILabel!
    
    fileprivate var shouldUpdateScrollViewContentFrame = false
    
    deinit {
        self.controllers.forEach { (controller) in
            controller.view.removeFromSuperview()
        }
        self.controllers.removeAll()
        
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareForLayout()
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.prepareViews()
        
        shouldUpdateScrollViewContentFrame = true
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.profileHeaderViewHeight = profileHeaderView.sizeThatFits(self.mainScrollView.bounds.size).height
        
        
        if self.shouldUpdateScrollViewContentFrame {
            /// 只要第一次view布局完成时，再调整下stickyHeaderContainerView的frame，剩余的情况会在scrollViewDidScrollView:时调整
            self.stickyHeaderContainerView.frame = self.computeStickyHeaderContainerViewFrame()
            self.shouldUpdateScrollViewContentFrame = false
        }
        
        /// 更新profileHeaderView和segmentedControlContainer的frame
        self.profileHeaderView.frame = self.computeProfileHeaderViewFrame()
        let contentOffset = self.mainScrollView.contentOffset
        let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderContainerView.bounds.width, height: stickyHeaderContainerView.frame.origin.y - contentOffset.y + stickyHeaderContainerView.bounds.height)
        let navigationHeight = navigationLocation.height - abs(navigationLocation.origin.y)
        let segmentedControlContainerLocationY = stickyheaderContainerViewHeight + profileHeaderViewHeight - navigationHeight
        if contentOffset.y > 0 && contentOffset.y >= segmentedControlContainerLocationY {
            segmentedControlContainer.frame = CGRect(x: 0, y: contentOffset.y + navigationHeight, width: segmentedControlContainer.bounds.width, height: segmentedControlContainer.bounds.height)
        } else {
            segmentedControlContainer.frame = computeSegmentedControlContainerFrame()
        }
        
        /// 更新 子 scrollView的frame
//        self.controllers.forEach({ (scrollView) in
//            scrollView.frame = self.computeTableViewFrame(tableView: scrollView)
//            scrollView.isScrollEnabled = false
//        })
        
//        self.updateMainScrollViewFrame()
        
        self.mainScrollView.scrollIndicatorInsets = computeMainScrollViewIndicatorInsets()
        
        
        tableHeaderView.frame = CGRect.init(x: 0, y: 0, width: 0, height: stickyHeaderContainerView.frame.height + profileHeaderView.frame.size.height)
        self.mainScrollView.tableHeaderView = tableHeaderView
        profileHeaderView.frame = self.computeProfileHeaderViewFrame()

    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension BaseProfileViewController {
    
    func prepareViews() {
        
        self.view.addSubview(mainScrollView)
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // sticker header Container view
//        mainScrollView.addSubview(stickyHeaderContainerView)
        tableHeaderView.addSubview(stickyHeaderContainerView)
        tableHeaderView.addSubview(profileHeaderView)
        
        mainScrollView.tableHeaderView = tableHeaderView
        
        // Cover Image View
        stickyHeaderContainerView.addSubview(headerCoverView)
        headerCoverView.translatesAutoresizingMaskIntoConstraints = false
        headerCoverView.leadingAnchor.constraint(equalTo: stickyHeaderContainerView.leadingAnchor).isActive = true
        headerCoverView.trailingAnchor.constraint(equalTo: stickyHeaderContainerView.trailingAnchor).isActive = true
        headerCoverView.topAnchor.constraint(equalTo: stickyHeaderContainerView.topAnchor).isActive = true
        headerCoverView.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor).isActive = true
        
        
        // blur effect on top of coverImageView
        stickyHeaderContainerView.addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.leadingAnchor.constraint(equalTo: stickyHeaderContainerView.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: stickyHeaderContainerView.trailingAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: stickyHeaderContainerView.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor).isActive = true
        
        // 导航标题
        stickyHeaderContainerView.addSubview(navigationTitleLabel)
        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationTitleLabel.centerXAnchor.constraint(equalTo: stickyHeaderContainerView.centerXAnchor).isActive = true
        navigationTitleLabelBottomConstraint = navigationTitleLabel.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor, constant: -ALPNavigationTitleLabelBottomPadding)
        navigationTitleLabelBottomConstraint?.isActive = true
        
        
        // 设置进度为0时的导航条标题和导航条详情label的位置 (此时标题和详情label 在headerView的最下面隐藏)
        animateNaivationTitleAt(progress: 0.0)
        
        // 分段控制视图
        segmentedControlContainer.contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.widthAnchor.constraint(equalTo: segmentedControlContainer.contentView.widthAnchor, constant: -16.0).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: segmentedControlContainer.contentView.centerXAnchor).isActive = true
        segmentedControl.centerYAnchor.constraint(equalTo: segmentedControlContainer.contentView.centerYAnchor).isActive = true
        
        self.controllers = []
        for index in 0..<numberOfSegments() {
            let controller = self.controller(forSegment: index)
            self.controllers.append(controller)
            controller.view.isHidden = (index > 0)
        }
        
        self.mainScrollView.reloadData()
        
        self.showDebugInfo()
    }
    
    func computeStickyHeaderContainerViewFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
    }
    
    func computeProfileHeaderViewFrame() -> CGRect {
        return CGRect(x: 0, y: computeStickyHeaderContainerViewFrame().origin.y + stickyheaderContainerViewHeight, width: mainScrollView.bounds.width, height: profileHeaderViewHeight)
    }
    
    func computeTableViewFrame(tableView: UIScrollView) -> CGRect {
        let upperViewFrame = computeSegmentedControlContainerFrame()
        return CGRect(x: 0, y: upperViewFrame.origin.y + upperViewFrame.height , width: mainScrollView.bounds.width, height: tableView.contentSize.height)
    }
    
    func computeMainScrollViewIndicatorInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.computeSegmentedControlContainerFrame().alp_originBottom, 0, 0, 0)
    }
    
    func computeNavigationFrame() -> CGRect {
        return headerCoverView.convert(headerCoverView.bounds, to: self.view)
    }
    
    func computeSegmentedControlContainerFrame() -> CGRect {
        //        let rect = computeProfileHeaderViewFrame()
        //        return CGRect(x: 0, y: rect.origin.y + rect.height, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight)
        return CGRect(x: 0, y: profileHeaderView.frame.maxY, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight)
        
    }
}

extension BaseProfileViewController: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.mainScrollView) == false {
            return
        }
        let contentOffset = scrollView.contentOffset
        self.debugContentOffset(contentOffset: contentOffset)
        
        // sticky headerCover
        if contentOffset.y <= 0 {
            let bounceProgress = min(1, abs(contentOffset.y) / bouncingThreshold)
            
            let newHeight = abs(contentOffset.y) + self.stickyheaderContainerViewHeight
            
            // adjust stickyHeader frame
            self.stickyHeaderContainerView.frame = CGRect(
                x: 0,
                y: contentOffset.y,
                width: mainScrollView.bounds.width,
                height: newHeight)
            
            // blurring effect amplitude
            self.blurEffectView.alpha = min(1, bounceProgress * 2)
            
            // scaling effect
            let scalingFactor = 1 + min(log(bounceProgress + 1), 2)
            //      print(scalingFactor)
            self.headerCoverView.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
            
            // adjust mainScrollView indicator insets
            var baseInset = computeMainScrollViewIndicatorInsets()
            baseInset.top += abs(contentOffset.y)
            self.mainScrollView.scrollIndicatorInsets = baseInset
            
        } else {
            
            // anything to be set if contentOffset.y is positive
            self.blurEffectView.alpha = 0
            self.mainScrollView.scrollIndicatorInsets = computeMainScrollViewIndicatorInsets()
        }
        
        // Universal
        // applied to every contentOffset.y
        let scaleProgress = max(0, min(1, contentOffset.y / self.scrollToScaleDownProfileIconDistance))
        self.profileHeaderView.animator(t: scaleProgress)
        
        if contentOffset.y > 0 {
            
            // When scroll View reached the threshold
            if contentOffset.y >= scrollToScaleDownProfileIconDistance {
                self.stickyHeaderContainerView.frame = CGRect(x: 0, y: contentOffset.y - scrollToScaleDownProfileIconDistance, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
                // 当scrollView 的 segment顶部 滚动到scrollToScaleDownProfileIconDistance时(也就是导航底部及以上位置)，让stickyHeaderContainerView显示在最上面，防止被profileHeaderView遮挡
                tableHeaderView.bringSubview(toFront: self.stickyHeaderContainerView)
                
            } else {
                // 当scrollView 的 segment顶部 滚动到导航底部以下位置，让profileHeaderView显示在最上面,防止用户头像被遮挡
                self.stickyHeaderContainerView.frame = computeStickyHeaderContainerViewFrame()
                tableHeaderView.bringSubview(toFront: self.profileHeaderView)
            }
            
            // Sticky Segmented Control
            let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderContainerView.bounds.width, height: stickyHeaderContainerView.frame.origin.y - contentOffset.y + stickyHeaderContainerView.bounds.height)
            let navigationHeight = navigationLocation.height - abs(navigationLocation.origin.y)
            let segmentedControlContainerLocationY = stickyheaderContainerViewHeight + profileHeaderViewHeight - navigationHeight
            
            if contentOffset.y > 0 && contentOffset.y >= segmentedControlContainerLocationY {
                // 让segment悬停在导航底部
                segmentedControlContainer.frame = CGRect(x: 0, y: contentOffset.y + navigationHeight, width: segmentedControlContainer.bounds.width, height: segmentedControlContainer.bounds.height)
            } else {
                segmentedControlContainer.frame = computeSegmentedControlContainerFrame()
            }
            
            // Override
            // 当滚动视图到达标题标签的顶部边缘时
            if let titleLabel = profileHeaderView.nicknameLabel, let usernameLabel = profileHeaderView.usernameLabel  {
                
                // titleLabel location relative to self.view
                let titleLabelLocationY = stickyheaderContainerViewHeight - 35
                
                let totalHeight = titleLabel.bounds.height + usernameLabel.bounds.height + 35
                let detailProgress = max(0, min((contentOffset.y - titleLabelLocationY) / totalHeight, 1))
                blurEffectView.alpha = detailProgress
                animateNaivationTitleAt(progress: detailProgress)
            }
        }
        
    }
    
    
}

// MARK: UITableViewDelegates & DataSources
extension BaseProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HitTestScrollViewCellIdentifier, for: indexPath) as! HitTestScrollViewCell
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return containerCellMaxHeight()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HitTestScrollViewSectionIdentifier)
        if headerView == nil {
            headerView = self.segmentedControlContainer
        }
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return segmentedControlContainerHeight
    }

}

// MARK: Animators
extension BaseProfileViewController {
    /// 更新导航条上面titleLabel的位置
    func animateNaivationTitleAt(progress: CGFloat) {
        
        let totalDistance: CGFloat = self.navigationTitleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + ALPNavigationTitleLabelBottomPadding
        
        if progress >= 0 {
            let distance = (1 - progress) * totalDistance
            navigationTitleLabelBottomConstraint?.constant = -ALPNavigationTitleLabelBottomPadding + distance
        }
    }
}

/// status bar
extension BaseProfileViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override open var prefersStatusBarHidden: Bool {
        return false
    }
}

// Table View Switching

extension BaseProfileViewController {
    func updateTableViewContent() {
        print("currentIndex did changed \(self.currentIndex)")
    }
    
    @objc internal func segmentedControlValueDidChange(sender: AnyObject?) {
        self.currentIndex = self.segmentedControl.selectedSegmentIndex
        
//        let scrollViewToBeShown: UIScrollView! = self.currentScrollView
        
//        self.controllers.forEach { (scrollView) in
//            scrollView?.isHidden = scrollView != scrollViewToBeShown
//        }
        
//        scrollViewToBeShown.frame = self.computeTableViewFrame(tableView: scrollViewToBeShown)
//        self.updateMainScrollViewFrame()
        
        // auto scroll to top if mainScrollView.contentOffset > navigationHeight + segmentedControl.height
//        let navigationHeight = self.scrollToScaleDownProfileIconDistance
//        let threshold = self.computeProfileHeaderViewFrame().alp_originBottom - navigationHeight
////
//        if mainScrollView.contentOffset.y > threshold {
//            self.mainScrollView.setContentOffset(CGPoint(x: 0, y: threshold), animated: false)
//        }
    }
}

extension BaseProfileViewController {
    
    var debugMode: Bool {
        return false
    }
    
    func showDebugInfo() {
        if debugMode {
            self.debugTextView = UILabel()
            debugTextView.text = "debug mode: on"
            debugTextView.backgroundColor = UIColor.white
            debugTextView.sizeToFit()
            
            self.view.addSubview(debugTextView)
            debugTextView.translatesAutoresizingMaskIntoConstraints = false
            debugTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 16.0).isActive = true
            debugTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16.0).isActive = true
        }
    }
    
    func debugContentOffset(contentOffset: CGPoint) {
        self.debugTextView?.text = "\(contentOffset)"
    }
}

extension CGRect {
    var alp_originBottom: CGFloat {
        return self.origin.y + self.height
    }
}
