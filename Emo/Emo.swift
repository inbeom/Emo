import UIKit

@objc public protocol EmoViewContainer {
  func emoViewWillAssignBottomSpace(CGFloat)
  func emoViewNumberOfPacks() -> Int
  func emoViewNumberOfEmojisAt(Int) -> Int
  optional func emoViewDecorateCellForEmojiPackAt(cell: EmojiPackCollectionViewCell, item: Int)
  optional func emoViewDecorateCellForEmojiAt(cell: EmojiCollectionViewCell, path: NSIndexPath)
}


public class EmojiCollectionViewDiscreteLayout: UICollectionViewFlowLayout {
  public override func prepareLayout() {
    super.prepareLayout()
    self.scrollDirection = UICollectionViewScrollDirection.Horizontal
    self.minimumInteritemSpacing = 0
    self.minimumLineSpacing = 0
    self.itemSize = CGSize(width: collectionView!.frame.width / 4, height: collectionView!.frame.height / 2)
  }
}

public class EmojiCollectionViewCell: UICollectionViewCell {
  var emojiIcon: UIImageView!
  var iconSideLength: CGFloat!

  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public func setImage(image: UIImage?) {
    emojiIcon.image = image
  }

  public func setIconSideLength(length: CGFloat) {
    self.iconSideLength = length
    renderIcon()
  }

  private func commonInit() {
    self.selected = false
    self.iconSideLength = min(frame.width, frame.height)
    self.emojiIcon = UIImageView()

    renderIcon()
    addSubview(emojiIcon)
  }

  private func renderIcon() {
    emojiIcon.frame = centerRect()
  }

  private func centerRect() -> CGRect {
    let x = (frame.width - iconSideLength) / 2
    let y = (frame.height - iconSideLength) / 2

    return CGRect(x: x, y: y, width: iconSideLength, height: iconSideLength)
  }
}

public class EmojiPackCollectionViewCell: EmojiCollectionViewCell {
  var emojiPackSelectedImage: UIImage!
  var emojiPackNormalImage: UIImage!

  override public var selected: Bool {
    didSet {
      setStateImage()
    }
  }

  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public func setImage(onImage: UIImage?, offImage: UIImage?) {
    emojiPackSelectedImage = onImage
    emojiPackNormalImage = offImage

    setStateImage()
  }

  private func setStateImage() {
    if emojiIcon != nil && emojiPackSelectedImage != nil && emojiPackNormalImage != nil {
      emojiIcon.image = selected ? emojiPackSelectedImage : emojiPackNormalImage
    }
  }
}

public class EmoView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
  @IBOutlet weak private var contentView: UIView!
  @IBOutlet weak var emojiCollectionView: UICollectionView!
  @IBOutlet weak var emojiCollectionPager: UIPageControl!
  @IBOutlet weak var emojiPackCollectionView: UICollectionView!
  @IBOutlet weak var bottomBorder: UIView!

  var container: EmoViewContainer?
  var enabled: Bool = false {
    didSet {
      render()
    }
  }

  var currentPackIndex = -1
  public var borderWidth: CGFloat = 0.5 {
    didSet {
      renderBorders()
    }
  }

  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public override func awakeFromNib() {
    super.awakeFromNib()

    emojiPackCollectionView.dataSource = self
    emojiPackCollectionView.delegate = self
    emojiPackCollectionView.registerClass(EmojiPackCollectionViewCell.self, forCellWithReuseIdentifier: "emojiPack")

    emojiCollectionView.dataSource = self
    emojiCollectionView.delegate = self
    emojiCollectionView.registerClass(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emoji")
  }

  public func bootstrap(container: EmoViewContainer) {
    self.container = container

    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

    emojiPackCollectionView.reloadData()

    if container.emoViewNumberOfPacks() > 0 {
      emojiPackCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection:0), animated: false, scrollPosition: nil)
      self.collectionView(emojiPackCollectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    }

    render()
  }

  func keyboardWillShow(notification: NSNotification) {
    let info = notification.userInfo!

    if enabled {
      hide()
    }

    if let frameEnds = (info[UIKeyboardFrameEndUserInfoKey as NSObject])?.CGRectValue() {
      if let convertedEnds = window?.convertRect(frameEnds, fromWindow: nil) {
        container?.emoViewWillAssignBottomSpace(convertedEnds.height)
      }
    }
  }

  func keyboardWillHide(notification: NSNotification) {
    container?.emoViewWillAssignBottomSpace(0)
  }

  public func toggle() {
    enabled = !enabled
    render()
  }

  public func hide() {
    enabled = false
    render()
  }

  public override func resignFirstResponder() -> Bool {
    super.resignFirstResponder()
    hide()

    return true
  }

  @IBAction func pageChanged(sender: UIPageControl) {
    if sender == emojiCollectionPager {
      emojiCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: emojiCollectionPager.currentPage * 8, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if collectionView == emojiPackCollectionView {
      var cell = collectionView.dequeueReusableCellWithReuseIdentifier("emojiPack", forIndexPath: indexPath) as! EmojiPackCollectionViewCell

      if container != nil {
        container!.emoViewDecorateCellForEmojiPackAt?(cell, item: indexPath.item)
      }

      return cell
    } else {
      var cell = collectionView.dequeueReusableCellWithReuseIdentifier("emoji", forIndexPath: indexPath) as! EmojiCollectionViewCell

      if container != nil {
        container!.emoViewDecorateCellForEmojiAt?(cell, path: NSIndexPath(forItem: indexPath.item, inSection: currentPackIndex))
      }

      return cell
    }
  }

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == emojiPackCollectionView {
      return (container != nil) ? container!.emoViewNumberOfPacks() : 0
    } else {
      return (container != nil) ? container!.emoViewNumberOfEmojisAt(currentPackIndex) : 0
    }
  }

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if collectionView == emojiPackCollectionView {
      currentPackIndex = indexPath.item

      var cell = self.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! EmojiPackCollectionViewCell
      cell.selected = true

      emojiCollectionView.reloadData()
      emojiCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)

      renderPageControl(0)
    } else {

    }
  }

  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if scrollView == emojiCollectionView {

      let mean = emojiCollectionView.visibleCells().map({
        self.emojiCollectionView.indexPathForCell($0 as! UICollectionViewCell)!.item
      }).reduce(0, combine: +) / emojiCollectionView.visibleCells().count

      renderPageControl(mean)
    }
  }

  private func renderBorders() {
    if bottomBorder != nil {
      bottomBorder!.frame = CGRect(x: 0, y: frame.height - borderWidth, width: frame.width, height: borderWidth)
    }
  }

  private func renderPageControl(currentPosition: Int) {
    let numItems = self.container!.emoViewNumberOfEmojisAt(currentPackIndex)
    let numPages = ceil(Float(numItems) / 8)

    emojiCollectionPager.numberOfPages = Int(numPages)
    emojiCollectionPager.currentPage = currentPosition / 8
  }

  private func render() {
    hidden = !enabled

    container?.emoViewWillAssignBottomSpace(enabled ? frame.height : 0)
  }

  private func commonInit() {
    NSBundle(forClass: EmoView.self).loadNibNamed("EmoView", owner: self, options: nil)
    contentView.frame = self.bounds
    contentView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    self.addSubview(contentView)
  }
}