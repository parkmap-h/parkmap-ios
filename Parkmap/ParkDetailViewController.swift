//  Copyright (c) 2015年 Parkmap. All rights reserved.
import UIKit

class ParkDetailViewController: UIViewController {
    
    var park: Park? = nil

    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let park = park {
            titleLabel.text = park.name
            let url: NSURL? = park.miniPhotoURLs[0]
            let image = NSData(contentsOfURL: url!)
            imageView.image = UIImage(data: image!)
        } else {
            titleLabel.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapBack(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func tapLookMap(sender: UIButton) {
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
            UIApplication.sharedApplication().openURL(NSURL(string:
                "comgooglemaps://?center=\(park?.coordinate.latitude),\(park?.coordinate.longitude)&zoom=14&views=traffic")!)
        } else {
            NSLog("Can't use comgooglemaps://");
        }
    }
}
