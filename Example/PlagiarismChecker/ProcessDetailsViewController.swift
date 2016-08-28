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

class ProcessDetailsViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var processIdLabel: UILabel!
    @IBOutlet weak var processStatusLabel: UILabel!
    @IBOutlet weak var processCreatedLabel: UILabel!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var resultsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var processId: String = ""
    var processStatus: String = "Finished"
    var processCreated: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Process Detail"
        updateView()
        
    }
    
    func updateView()  {
        processIdLabel.text = processId
        processStatusLabel.text = processStatus
        processCreatedLabel.text = processCreated

        let isFinished: Bool = (processStatus == "Finished")
        
        resultsButton.enabled = isFinished
        deleteButton.enabled = isFinished

    }
    

    @IBAction func deleteAction(sender: AnyObject) {
        
        if activityIndicator.isAnimating() {
            return
        }
        activityIndicator.startAnimating()
        
        let cloud = CopyleaksCloud(.Businesses)
        cloud.deleteProcess(processIdLabel.text!) { (result) in
            self.activityIndicator.stopAnimating()
            
            if result.isSuccess {
                self.activityIndicator.stopAnimating()
                self.navigationController?.popViewControllerAnimated(true)
                
            } else {
                Alert("Error", message: result.error?.localizedFailureReason ?? "Unknown error")
            }
        }
    }

    
    @IBAction func statusAction(sender: AnyObject) {
        
        if activityIndicator.isAnimating() {
            return
        }
        activityIndicator.startAnimating()
        
        let cloud = CopyleaksCloud(.Businesses)
        cloud.statusProcess(processIdLabel.text!) { (result) in
            self.activityIndicator.stopAnimating()
            
            if result.isSuccess {
                self.activityIndicator.stopAnimating()

                if let status = result.value?["Status"] as? String {
                    self.processStatus = status
                }
                self.updateView()
                
            } else {
                Alert("Error", message: result.error?.localizedFailureReason ?? "Unknown error")
            }
        }
    }

    
    // MARK: - Memory
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showResults" {
            (segue.destinationViewController as! ResultsViewController).processId = processId
        }

    }

}
