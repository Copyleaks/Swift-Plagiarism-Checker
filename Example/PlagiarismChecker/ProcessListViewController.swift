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

class ProcessListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var source : NSArray = NSArray()
    
    var selectedProcess: AnyObject?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Process List"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateProcessList()
    }

    func updateProcessList() {
        activityIndicator.startAnimating()
        
        let cloud = CopyleaksCloud(.Businesses)
        cloud.processesList { (result) in
            
            print(result.value)
            
            if let arr = result.value as? NSArray {
                self.source = arr
            }

            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            })
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProcessCell", forIndexPath: indexPath)
        
        let object = source[indexPath.row]
        
        cell.textLabel?.text = object["ProcessId"] as? String
        cell.detailTextLabel?.text = object["Status"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedProcess = source[indexPath.row]
        self.performSegueWithIdentifier("showDetails", sender: nil)
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
                processId: String = selectedProcess?["ProcessId"] as? String,
                status: String = selectedProcess?["Status"] as? String,
                created: String = selectedProcess?["CreationTimeUTC"] as? String {
                
                let vc: ProcessDetailsViewController = segue.destinationViewController as! ProcessDetailsViewController
                vc.processId = processId
                vc.processCreated = created
                vc.processStatus = status
                
            } else {
                Alert("Error", message: "No process data")
            }
        }
        
    }
    

}
