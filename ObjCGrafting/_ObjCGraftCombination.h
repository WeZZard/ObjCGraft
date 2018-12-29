//
//  _ObjCGraftCombination.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef _ObjCGraftCombination_h
#define _ObjCGraftCombination_h

#import <objc/runtime.h>

#include <vector>

namespace objcgrafting {
    struct _ObjCGraftCombination {
        bool is_instance;
        SEL name;
        const char * types;
        IMP impl;
        
        _ObjCGraftCombination(bool is_instance, SEL name, const char * types, IMP impl);
    };
    
    typedef std::vector<_ObjCGraftCombination> _ObjCGraftCombinationList;
}


#endif /* _ObjCGraftCombination_h */
