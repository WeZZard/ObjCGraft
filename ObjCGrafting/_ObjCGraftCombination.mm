//
//  _ObjCGraftCombination.mm
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#import "_ObjCGraftCombination.h"

namespace objcgrafting {
    _ObjCGraftCombination::_ObjCGraftCombination(bool is_instance, SEL name, const char * types, IMP impl) {
        this -> is_instance = is_instance;
        this -> name = name;
        this -> types = types;
        this -> impl = impl;
    }
}
