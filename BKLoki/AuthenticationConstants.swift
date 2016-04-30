
/*
* Copyright (c) Sara Du. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import Foundation

// You'll set your application's ClientId and RedirectURI here. These values are provided by your Microsoft Azure app
//registration. See README.MD for more details.

struct AuthenticationConstants {
    
    static let ClientId    = "dacd693d-dd6c-4baf-b93a-c84b47e498cb"
    static let RedirectUri = NSURL.init(string: "http://localhost/LOKI")
    static let Authority   = "https://login.microsoftonline.com/common"
    static let ResourceId  = "https://graph.microsoft.com"
    
}


