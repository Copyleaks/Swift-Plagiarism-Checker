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

import Foundation

public class CopyleaksSessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
    
    private var subdelegates: [Int: CopyleaksRequest.TaskDelegate] = [:]
    private let subdelegateQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
    
    /* Access the task delegate for the specified task in a thread-safe manner.*/
    
    public subscript(task: NSURLSessionTask) -> CopyleaksRequest.TaskDelegate? {
        get {
            var subdelegate: CopyleaksRequest.TaskDelegate?
            dispatch_sync(subdelegateQueue) { subdelegate = self.subdelegates[task.taskIdentifier] }
            
            return subdelegate
        }
        set {
            dispatch_barrier_async(subdelegateQueue) { self.subdelegates[task.taskIdentifier] = newValue }
        }
    }
    
    /**
     Initializes the CopyleaksSessionDelegate instance.
     - returns: The new CopyleaksSessionDelegate instance.
     */
    public override init() {
        super.init()
    }
    
    // MARK: - NSURLSessionDelegate

    /* Overrides default behavior for NSURLSessionDelegate method URLSession:didBecomeInvalidWithError: */
    public var sessionDidBecomeInvalidWithError: ((NSURLSession, NSError?) -> Void)?
    
    /* Overrides default behavior for NSURLSessionDelegate method URLSession:didReceiveChallenge:completionHandler:.*/
    public var sessionDidReceiveChallenge: ((NSURLSession, NSURLAuthenticationChallenge) -> (NSURLSessionAuthChallengeDisposition, NSURLCredential?))?
    
    /* Overrides all behavior for NSURLSessionDelegate method URLSession:didReceiveChallenge:completionHandler: and requires the caller to call the completionHandler.*/
    public var sessionDidReceiveChallengeWithCompletion: ((NSURLSession, NSURLAuthenticationChallenge, (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) -> Void)?
    
    /* Overrides default behavior for NSURLSessionDelegate method URLSessionDidFinishEventsForBackgroundURLSession:.*/
    public var sessionDidFinishEventsForBackgroundURLSession: ((NSURLSession) -> Void)?
    
    
    /**
     Tells the delegate that all messages enqueued for a session have been delivered.
     - parameter session: The session that no longer has any outstanding requests.
     */
    public func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        sessionDidFinishEventsForBackgroundURLSession?(session)
    }
    
    // MARK: - NSURLSessionTaskDelegate
    
    /* Overrides default behavior for NSURLSessionTaskDelegate method URLSession:task:didCompleteWithError:.*/
    public var taskDidComplete: ((NSURLSession, NSURLSessionTask, NSError?) -> Void)?
    
    /**
     Tells the delegate that the task finished transferring data.
     
     - parameter session: The session containing the task whose request finished transferring data.
     - parameter task:    The task whose request finished transferring data.
     - parameter error:   If an error occurred, an error object indicating how the transfer failed, otherwise nil.
     */
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let taskDidComplete = taskDidComplete {
            taskDidComplete(session, task, error)
        } else if let delegate = self[task] {
            delegate.URLSession(session, task: task, didCompleteWithError: error)
        }
        self[task] = nil
    }

    // MARK: - NSURLSessionDataDelegate
    
    /* Overrides default behavior for NSURLSessionDataDelegate method URLSession:dataTask:didReceiveData:.*/
    public var dataTaskDidReceiveData: ((NSURLSession, NSURLSessionDataTask, NSData) -> Void)?
    
    /**
     Tells the delegate that the data task has received some of the expected data.
     
     - parameter session:  The session containing the data task that provided data.
     - parameter dataTask: The data task that provided data.
     - parameter data:     A data object containing the transferred data.
     */
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        print(#function)
        if let dataTaskDidReceiveData = dataTaskDidReceiveData {
            dataTaskDidReceiveData(session, dataTask, data)
        } else if let delegate = self[dataTask] as? CopyleaksRequest.DataTaskDelegate {
            delegate.URLSession(session, dataTask: dataTask, didReceiveData: data)
        }
    }
    
    // MARK: - NSObject
    
    public override func respondsToSelector(selector: Selector) -> Bool {
        
        switch selector {
        case #selector(NSURLSessionDelegate.URLSession(_:didBecomeInvalidWithError:)):
            return sessionDidBecomeInvalidWithError != nil
        case #selector(NSURLSessionDelegate.URLSession(_:didReceiveChallenge:completionHandler:)):
            return (sessionDidReceiveChallenge != nil  || sessionDidReceiveChallengeWithCompletion != nil)
        case #selector(NSURLSessionDelegate.URLSessionDidFinishEventsForBackgroundURLSession(_:)):
            return sessionDidFinishEventsForBackgroundURLSession != nil
        default:
            return self.dynamicType.instancesRespondToSelector(selector)
        }
    }
}
