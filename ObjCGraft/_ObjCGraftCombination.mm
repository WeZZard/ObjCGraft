//
//  _ObjCGraftCombination.mm
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import "_ObjCGraftCombination.h"

namespace objcgraft {
    _ObjCGraftCombination::_ObjCGraftCombination(bool is_instance, SEL name, const char * types, IMP impl) {
        this -> is_instance = is_instance;
        this -> name = name;
        this -> types = types;
        this -> impl = impl;
    }
}
