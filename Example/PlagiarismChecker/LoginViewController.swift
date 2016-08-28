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

class LoginViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sign In"
        
        emailTextField.text = "michael@uvision.co.il"
        keyTextField.text = "9E5A35A7-D9EE-4ABC-A11B-4BC3ACA0ACF9"
        
        if Copyleaks.isAuthorized() {
            self.performSegueWithIdentifier("showMain", sender: nil)
        }
        
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        
        if activityIndicator.isAnimating() {
            return
        }
        
        if let email = emailTextField.text,
            key = keyTextField.text {
            activityIndicator.startAnimating()
            
            let cloud = CopyleaksCloud(.Businesses)
            cloud.login(email, apiKey: key, success: { (result) in
                self.activityIndicator.stopAnimating()
                
                if result.isSuccess {
                    self.performSegueWithIdentifier("showMain", sender: sender)
                    
                } else {
                    Alert("Error", message: result.error?.localizedFailureReason ?? "Unknown error")
                    
                }
            })
            
        } else {
            Alert("Authorization:", message: "Please, enter your credentials")
        }
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
   


}
