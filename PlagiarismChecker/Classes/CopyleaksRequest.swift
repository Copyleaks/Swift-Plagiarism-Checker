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

public class CopyleaksRequest {
    
    /* The delegate for the underlying task. */
    public let delegate: TaskDelegate
    
    /* The underlying task. */
    public var task: NSURLSessionTask { return delegate.task }
    
    /* The session belonging to the underlying task. */
    public let session: NSURLSession
    
    /* The request sent or to be sent to the server. */
    public var request: NSURLRequest? { return task.originalRequest }
    
    /* The response received from the server, if any. */
    public var response: NSHTTPURLResponse? { return task.response as? NSHTTPURLResponse }
    
    /* The progress of the request lifecycle. */
    public var progress: NSProgress { return delegate.progress }
    
    // MARK: - Lifecycle
    
    init(session: NSURLSession, task: NSURLSessionTask) {
        self.session = session
        
        switch task {
        case is NSURLSessionUploadTask:
            delegate = UploadTaskDelegate(task: task)
        case is NSURLSessionDataTask:
            delegate = DataTaskDelegate(task: task)
        default:
            delegate = TaskDelegate(task: task)
        }
    }
    
    // MARK: - State
    
    /**
     Resumes the request.
     */
    public func resume() {
        task.resume()
    }
    
    /**
     Suspends the request.
     */
    public func suspend() {
        task.suspend()
    }
    
    /**
     Cancels the request.
     */
    public func cancel() {
        task.cancel()
    }
    
    // MARK: - TaskDelegate
    
    /**
     The task delegate is responsible for handling all delegate callbacks for the underlying task as well as
     executing all operations attached to the serial operation queue upon task completion.
     */
    public class TaskDelegate: NSObject {
        
        public let queue: NSOperationQueue
        
        let task: NSURLSessionTask
        let progress: NSProgress
        
        var data: NSData? { return nil }
        var error: NSError?
        
        init(task: NSURLSessionTask) {
            self.task = task
            self.progress = NSProgress(totalUnitCount: 0)
            self.queue = {
                let operationQueue = NSOperationQueue()
                operationQueue.maxConcurrentOperationCount = 1
                operationQueue.suspended = true
                return operationQueue
            }()
        }
        
        deinit {
            queue.cancelAllOperations()
            queue.suspended = false
        }
        
        // MARK: - NSURLSessionTaskDelegate
        
        var taskDidCompleteWithError: ((NSURLSession, NSURLSessionTask, NSError?) -> Void)?
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            if let taskDidCompleteWithError = taskDidCompleteWithError {
                taskDidCompleteWithError(session, task, error)
            } else {
                if let error = error {
                    self.error = error
                }
                
                queue.suspended = false
            }
        }
    }
    
    // MARK: - DataTaskDelegate
    
    class DataTaskDelegate: TaskDelegate, NSURLSessionDataDelegate {
        var dataTask: NSURLSessionDataTask? { return task as? NSURLSessionDataTask }
        
        private var totalBytesReceived: Int64 = 0
        private var mutableData: NSMutableData
        override var data: NSData? {
            return mutableData
        }
        
        private var expectedContentLength: Int64?
        private var dataProgress: ((bytesReceived: Int64, totalBytesReceived: Int64, totalBytesExpectedToReceive: Int64) -> Void)?
        
        override init(task: NSURLSessionTask) {
            mutableData = NSMutableData()
            super.init(task: task)
        }
        
        // MARK: - NSURLSessionDataDelegate
        
        var dataTaskDidReceiveResponse: ((NSURLSession, NSURLSessionDataTask, NSURLResponse) -> NSURLSessionResponseDisposition)?
        var dataTaskDidReceiveData: ((NSURLSession, NSURLSessionDataTask, NSData) -> Void)?
        
        // MARK: Delegate Methods
        
        func URLSession(
            session: NSURLSession,
            dataTask: NSURLSessionDataTask,
            didReceiveResponse response: NSURLResponse,
                               completionHandler: (NSURLSessionResponseDisposition -> Void))
        {
            var disposition: NSURLSessionResponseDisposition = .Allow
            
            expectedContentLength = response.expectedContentLength
            
            if let dataTaskDidReceiveResponse = dataTaskDidReceiveResponse {
                disposition = dataTaskDidReceiveResponse(session, dataTask, response)
            }
            
            completionHandler(disposition)
        }
        
        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            
            if let dataTaskDidReceiveData = dataTaskDidReceiveData {
                dataTaskDidReceiveData(session, dataTask, data)
            } else {
                mutableData.appendData(data)
                
                totalBytesReceived += data.length
                let totalBytesExpected = dataTask.response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
                
                progress.totalUnitCount = totalBytesExpected
                progress.completedUnitCount = totalBytesReceived
                
                dataProgress?(
                    bytesReceived: Int64(data.length),
                    totalBytesReceived: totalBytesReceived,
                    totalBytesExpectedToReceive: totalBytesExpected
                )
            }
        }

    }
    
    class UploadTaskDelegate: DataTaskDelegate {
        var uploadTask: NSURLSessionUploadTask? { return task as? NSURLSessionUploadTask }
        var uploadProgress: ((Int64, Int64, Int64) -> Void)!
        
        // MARK: - NSURLSessionTaskDelegate

        var taskDidSendBodyData: ((NSURLSession, NSURLSessionTask, Int64, Int64, Int64) -> Void)?
        
        // MARK: Delegate Methods
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
            
            if let taskDidSendBodyData = taskDidSendBodyData {
                taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
                
            } else {
                progress.totalUnitCount = totalBytesExpectedToSend
                progress.completedUnitCount = totalBytesSent
                
                uploadProgress?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
            }
        }
    }
}


