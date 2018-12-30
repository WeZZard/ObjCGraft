//
//  ObjCGraftCommon.h
//  ObjCGrafting
//
//  Created by WeZZard on 27/03/2017.
//
//

#ifndef ObjCGraftCommon_h
#define ObjCGraftCommon_h

#import <objc/runtime.h>

#include <map>
#include <list>

namespace objcgrafting {
    struct _ObjCProtocolHasher;
    struct _ObjCIdHasher;
    
#pragma mark - Typedefs
    typedef std::pair<Protocol * __unsafe_unretained, __unsafe_unretained Class> _ObjCGraftRequest;
    typedef std::vector<_ObjCGraftRequest> _ObjCGraftRequestVector;
    typedef std::map<Protocol * __unsafe_unretained , __unsafe_unretained Class> _ObjCGraftRecordMap;
    typedef std::list<Protocol * __unsafe_unretained> _ObjCProtocolList;
    
#pragma mark - Utility Functors
    struct _ObjCProtocolHasher {
        std::size_t operator()(Protocol * __unsafe_unretained const& protocol) const {
            auto pointer = (__bridge void *)protocol;
            
            return (std::size_t)pointer;
        }
    };
    
    struct _ObjCIdHasher {
        std::size_t operator()(id __unsafe_unretained const& object) const {
            auto pointer = (__bridge void *)object;
            
            return (std::size_t)pointer;
        }
    };
}

#endif /* ObjCGraftCommon_h */
