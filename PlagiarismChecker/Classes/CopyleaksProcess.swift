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

public class CopyleaksProcess: NSObject {
    
    var id: String?
    var creationTime: String?
    var status: String?
    
//    private let copyleaksProcessCreationTimeUTCKey = "copyleaksProcessCreationTimeUTC"
//    private let copyleaksProcessIdKey = "copyleaksProcessId"
//    private let copyleaksProcessStatusKey = "copyleaksProcessStatus"
    
    func parse(object: AnyObject) {
        id = object["ProcessId"] as? String
        creationTime = object["CreationTimeUTC"] as? String
        status = object["Status"] as? String
        
    }
    
//    required public init(coder aDecoder: NSCoder) {
//        id = aDecoder.decodeObjectForKey(copyleaksProcessIdKey) as! String
//        creationTime = aDecoder.decodeObjectForKey(copyleaksProcessCreationTimeUTCKey) as! String
//        status = aDecoder.decodeObjectForKey(copyleaksProcessStatusKey) as! String
//    }
//    
//    func encodeWithCoder(aCoder: NSCoder) {
//        aCoder.encodeObject(id, forKey: copyleaksProcessIdKey)
//        aCoder.encodeObject(creationTime, forKey: copyleaksProcessCreationTimeUTCKey)
//        aCoder.encodeObject(status, forKey: copyleaksProcessStatusKey)
//    }
    

}
