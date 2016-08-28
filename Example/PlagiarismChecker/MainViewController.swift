/*
 * The MIT License(MIT)
 *
 * Copyright(c) 2016 Copyleaks LTD (https://copyleaks.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import UIKit
import PlagiarismChecker

class MainViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currentProcess: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.title = "Main"

    }

    //createByUrl
    
    @IBAction func createByUrlAction(sender: AnyObject) {
        
        if activityIndicator.isAnimating() {
            return
        }
        activityIndicator.startAnimating()

        let cloud = CopyleaksCloud(.Businesses)
        cloud.allowPartialScan = true
        cloud.createByUrl(NSURL(string: "https://google.com")!) { (result) in
            self.activityIndicator.stopAnimating()
            self.showProcessResult(result)
        }
    }

    
    @IBAction func createByTextAction(sender: AnyObject) {
        
        if activityIndicator.isAnimating() {
            return
        }
        activityIndicator.startAnimating()

        let cloud = CopyleaksCloud(.Businesses)
        cloud.createByText("Test me") { (result) in
            self.activityIndicator.stopAnimating()
            self.showProcessResult(result)
        }
        
    }
    
    @IBAction func createByFileAction(sender: AnyObject) {
        
        if activityIndicator.isAnimating() {
            return
        }
        activityIndicator.startAnimating()
        let imagePath: String = NSBundle.mainBundle().pathForResource("doc_test", ofType: "txt")!

        let cloud = CopyleaksCloud(.Businesses)
        cloud.allowPartialScan = true
        cloud.createByFile(fileURL: NSURL(string: imagePath)!, language: "English") { (result) in
            self.activityIndicator.stopAnimating()
            self.showProcessResult(result)
        }
        
    }


    @IBAction func createByOCRAction(sender: AnyObject) {
        if activityIndicator.isAnimating() {
            return
        }
        activityIndicator.startAnimating()
        let imagePath: String = NSBundle.mainBundle().pathForResource("ocr_test", ofType: "png")!

        let cloud = CopyleaksCloud(.Businesses)
        cloud.allowPartialScan = true
        cloud.createByOCR(fileURL: NSURL(string: imagePath)!, language: "English") { (result) in
            self.activityIndicator.stopAnimating()
            self.showProcessResult(result)
        }
    }


    @IBAction func countCreditsAction(sender: AnyObject) {
        
        if activityIndicator.isAnimating() {
            return
        }
        activityIndicator.startAnimating()

        let cloud = CopyleaksCloud(.Businesses)
        cloud.countCredits { (result) in
            self.activityIndicator.stopAnimating()
            
            if result.isSuccess {
                let val = result.value?["Amount"] as? Int ?? 0
                Alert("Amount", message: "\(val)")
            }
            else {
                Alert("Error", message: result.error?.localizedFailureReason ?? "Unknown error")
            }
            
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        Copyleaks.logout {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - helpers
    
    func showProcessResult(result: PlagiarismChecker.CopyleaksResult<AnyObject, NSError>) {
        currentProcess = nil
        
        if result.isSuccess {
            currentProcess = result.value
            self.performSegueWithIdentifier("showDetails", sender: nil)
        }
        else {
            Alert("Error", message: result.error?.localizedFailureReason ?? "Unknown error")
        }
        
    }
    
    
    // MARK: - Memory
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetails" {
            if let
                processId: String = currentProcess?["ProcessId"] as? String,
                created: String = currentProcess?["CreationTimeUTC"] as? String {
                
                let vc: ProcessDetailsViewController = segue.destinationViewController as! ProcessDetailsViewController
                vc.processId = processId
                vc.processCreated = created
                vc.processStatus = "Progress"
            
            } else {
                Alert("Error", message: "No process data")
            }
        }
        
    }

    
}
