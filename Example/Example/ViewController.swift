import UIKit
import Emo

class ViewController: UIViewController, Emo.EmoViewContainer {
  @IBOutlet weak var toggleButton: UIButton!
  @IBOutlet weak var commentField: UITextField!
  @IBOutlet weak var mainContainerBottomSpacing: NSLayoutConstraint!
  @IBOutlet weak var emoView: EmoView!

  var emoEnabled: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()

    emoView.bootstrap(self)
    emoView.borderWidth = 0.5
  }

  @IBAction func didClickToggleButton(sender: UIButton) {
    commentField.resignFirstResponder()

    emoView.toggle()
  }

  @IBAction func didTouchBackground(sender: UIControl) {
    commentField.resignFirstResponder()
    emoView.resignFirstResponder()
  }

  func emoViewWillAssignBottomSpace(height: CGFloat) {
    mainContainerBottomSpacing.constant = height
  }

  func emoViewNumberOfPacks() -> Int {
    return 5
  }

  func emoViewDecorateCellForEmojiPackAt(cell: EmojiPackCollectionViewCell, item: Int) {
    var imageView = UIImageView(frame: cell.frame)

    cell.setIconSideLength(CGFloat(26))
    cell.setImage(UIImage(named: "EmojiPackOn"), offImage: UIImage(named: "EmojiPackOff"))
    cell.contentView.addSubview(imageView)
  }

  func emoViewNumberOfEmojisAt(pack: Int) -> Int {
    return (pack + 1) * 8
  }

  func emoViewDecorateCellForEmojiAt(cell: EmojiCollectionViewCell, path: NSIndexPath) {
    if path.section % 2 != 0 {
      cell.setImage(UIImage(named: "Emoji00"))
    } else {
      cell.setImage(UIImage(named: "Emoji01"))
    }
  }
}