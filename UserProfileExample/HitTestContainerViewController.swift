//
//  HitTestContainerViewController.swift
//  UserProfileExample
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class HitTestContainerViewCollectionViewCell: UICollectionViewCell {
    
    fileprivate var view: UIView? {
        didSet {
            view?.backgroundColor = UIColor.white
            if view != oldValue {
                oldValue?.removeFromSuperview()
                guard let v = view else { return }
                self.contentView.addSubview(v)
                v.translatesAutoresizingMaskIntoConstraints = false
                v.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                v.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
                v.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
                v.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            }
        }
    }
}

@objc
protocol HitTestContainerViewControllerDelegate: NSObjectProtocol {
    /// 页面完全显示时调用
    @objc func hitTestContainerViewController(containerViewController: HitTestContainerViewController, didPageDisplay controller: UIViewController, forItemAt index: Int) -> Void
}

class HitTestContainerViewController: UIViewController {
    
    public var viewControllers: [UIViewController]?
    
    public weak var delegate: HitTestContainerViewControllerDelegate?
    
    fileprivate static let cellIfentifier: String = "HitTestContainerViewCollectionViewCell"
    
    public lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.delegate = self
        view.dataSource = self
        view.register(HitTestContainerViewCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: HitTestContainerViewController.cellIfentifier)
        view.isPagingEnabled = true
        view.backgroundColor = UIColor.white
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    fileprivate func setupUI() {
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public var initialPage = 0
    private func displayViewController() -> UIViewController? {
        guard let viewControllers = viewControllers else {
            return nil
        }
        let indexPath = collectionView.indexPathsForVisibleItems.first
        guard let ip = indexPath else { return nil }
        let vc = viewControllers[ip.row]
        return vc
    }
    
    public func show(page index: NSInteger, animated: Bool) {
        if collectionView.indexPathsForVisibleItems.first?.row == index {
            return
        }
        collectionView .scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }

}

extension HitTestContainerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewControllers = viewControllers else { return 0 }
        return viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HitTestContainerViewController.cellIfentifier, for: indexPath) as! HitTestContainerViewCollectionViewCell
        cell.view = viewControllers![indexPath.row].view
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
    /// cell 完全离开屏幕后调用
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let viewControllers = viewControllers else { return }
        // 获取当前显示已经显示的控制器
        guard let displayIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let displayIndexPathController = viewControllers[displayIndexPath.row]
        displayIndexPathController.endAppearanceTransition()
        
        if let delegate = delegate {
            if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(containerViewController:didPageDisplay:forItemAt:))) {
                delegate.hitTestContainerViewController(containerViewController: self, didPageDisplay: displayIndexPathController, forItemAt: displayIndexPath.row)
            }
        }
        
        // 获取已离开屏幕的cell上控制器，执行其view消失的生命周期方法
        let endDisplayingViewController = viewControllers[indexPath.row]
        if displayIndexPathController != endDisplayingViewController {
            // 如果完全显示的控制器和已经离开屏幕的控制器是同一个就return，防止初始化完成后是同一个
            endDisplayingViewController.endAppearanceTransition()
        }
//        UIView.animate(withDuration: 0.3) {
//            UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
//        }
    }
    
    /// cell 即将显示在屏幕时调用
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if initialPage > 0 {
            show(page: initialPage, animated: false)
            initialPage = 0
        }
        guard let viewControllers = viewControllers else { return }
        /// 获取即将显示的cell上的控制器，执行其view显示的生命周期方法
        let willDisplayController = viewControllers[indexPath.row]
        willDisplayController.beginAppearanceTransition(true, animated: true)
        
        /// 获取即将消失的控制器（当前collectionView显示的cell就是即将要离开屏幕的cell）
        guard let willEndDisplayingIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let willEndDisplayingController = viewControllers[willEndDisplayingIndexPath.row]
        if willEndDisplayingController != willDisplayController {
            // 如果是同一个控制器return，防止初始化完成后是同一个
            willEndDisplayingController.beginAppearanceTransition(false, animated: true)
        }
    }
}
