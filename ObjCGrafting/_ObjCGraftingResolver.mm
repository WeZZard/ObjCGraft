//
//  _ObjCGraftingResolver.mm
//  ObjCGrafting
//
//  Created on 30/12/2018.
//

#import "_ObjCGraftingResolver.h"

#import "_ObjCGraftCombination.h"
#import "_ObjCCompositedClass.h"

namespace objcgrafting {
    _ObjCGraftingResolver& _ObjCGraftingResolver::shared() {
        static _ObjCGraftingResolver shared_instance;
        return shared_instance;
    }
    
#pragma mark Resolving Composited Class
    std::unique_ptr<_ObjCGraftCombinationList> _ObjCGraftingResolver::resolveGraftCombinationList(_ObjCGraftRecordMap &graft_record_map) {
        _resolveProtocolsHierarchy(graft_record_map);
        
        auto graft_combination_list = std::make_unique<_ObjCGraftCombinationList>();
        
        auto resolved_instance_selector_set = std::make_unique<std::unordered_set<SEL>>();
        
        auto resolved_class_selector_set = std::make_unique<std::unordered_set<SEL>>();
        
        for (auto& pair: graft_record_map) {
            auto &grafted_protocol = pair.first;
            
            auto source_class = graft_record_map[grafted_protocol];
            
            auto source_meta_class = objc_getMetaClass(class_getName(source_class));
            
            /* We use `class_copyMethodList` to make the candidate
             selector set, which to get the source class's method list
             without considering its superclass.
             
             Because the `grafted_protocol` might inherit a protocol
             like `NSObject` which is conformed by many classes and
             grafting implementations defined by such a protocol does
             not mean that grafting the inherited protocol, the
             implementations can be grafted from are constrained to
             the topmost class in the `source_class`'s inheritance
             hierarchy.
             */
            
            unsigned int source_class_method_count = 0;
            auto source_class_method_list = class_copyMethodList(source_class, &source_class_method_count);
            
            auto candidate_instance_selector_set = std::make_unique<std::unordered_set<SEL>>();
            
            for (unsigned int index = 0; index < source_class_method_count; index ++) {
                auto method = source_class_method_list[index];
                auto selector = method_getName(method);
                candidate_instance_selector_set -> insert(selector);
            }
            
            free(source_class_method_list);
            
            unsigned int source_meta_class_method_count = 0;
            auto source_meta_class_method_list = class_copyMethodList(source_meta_class, &source_meta_class_method_count);
            
            auto candidate_class_selector_set = std::make_unique<std::unordered_set<SEL>>();
            
            for (unsigned int index = 0; index < source_meta_class_method_count; index ++) {
                auto method = source_meta_class_method_list[index];
                auto selector = method_getName(method);
                candidate_class_selector_set -> insert(selector);
            }
            
            free(source_meta_class_method_list);
            
            assert(source_class != nullptr);
            
            auto pending_protocol_list = std::make_unique<_ObjCProtocolList>();
            pending_protocol_list -> push_back(grafted_protocol);
            
            while (!pending_protocol_list -> empty()) {
                auto pending_protocol = * pending_protocol_list -> cbegin();
                pending_protocol_list -> pop_front();
                
                assert(_hasSetHierarchyForProtocol(pending_protocol));
                
                for (unsigned int flag = 0; flag <= 0b11; flag ++) {
                    bool is_required = (flag & 0b01) != 0;
                    bool is_instance = (flag & 0b10) != 0;
                    
                    auto cls = is_instance ? source_class : source_meta_class;
                    
                    auto& resolved_selector_set = is_instance ? resolved_instance_selector_set : resolved_class_selector_set;
                    
                    auto& candidate_selector_set = is_instance ? candidate_instance_selector_set : candidate_class_selector_set;
                    
                    unsigned int method_count = 0;
                    auto method_description_list = protocol_copyMethodDescriptionList(pending_protocol, is_required, is_instance, &method_count);
                    
                    for (unsigned int index = 0; index < method_count; index ++) {
                        auto method_description = method_description_list[index];
                        
                        auto selector = method_description.name;
                        auto types = method_description.types;
                        
                        bool is_not_resolved = resolved_selector_set -> find(selector) == resolved_selector_set -> cend();
                        
                        if (is_not_resolved && candidate_selector_set -> find(selector) != candidate_selector_set -> cend()) {
                            auto impl = class_getMethodImplementation(cls, selector);
                            
                            graft_combination_list -> emplace_back(is_instance, selector, types, impl);
                            resolved_selector_set -> insert(selector);
                        }
                    }
                    
                    free(method_description_list);
                }
                
                for (auto& protocol: _hierarchyForProtocol(pending_protocol)) {
                    pending_protocol_list -> push_back(protocol);
                }
            }
            
        }
        
        return graft_combination_list;
    }
    
    NSString * _ObjCGraftingResolver::makeGraftRecordIdentifier(_ObjCGraftRecordMap& graft_record_map) {
        auto component_names = [[NSMutableArray<NSString *> alloc] init];
        
        auto protocols = std::make_unique<std::vector<Protocol * __unsafe_unretained>>();
        
        for (auto& pair: graft_record_map) {
            auto &protocol = pair.first;
            auto source_class = graft_record_map[protocol];
            assert(source_class != nullptr);
            protocols -> push_back(protocol);
            auto protocol_name = NSStringFromProtocol(protocol);
            auto source_class_name = NSStringFromClass(source_class);
            auto component_name = [NSString stringWithFormat:@"%@->%@", protocol_name, source_class_name];
            [component_names addObject:component_name];
        }
        
        auto grafted_components_id = [component_names componentsJoinedByString:@"|"];
        
        return grafted_components_id;
    }
    
    void _ObjCGraftingResolver::_resolveProtocolsHierarchy(_ObjCGraftRecordMap& graft_record_map) {
        auto resolved_protocol_set = std::make_unique<_ObjCProtocolUnorderedSet>();
        
        for (auto& pair: graft_record_map) {
            auto &topmost_protocol = pair.first;
            
            if (resolved_protocol_set -> find(topmost_protocol) == resolved_protocol_set -> cend()) {
                
                auto unresolved_protocol_list = std::make_unique<_ObjCProtocolList>();
                unresolved_protocol_list -> push_back(topmost_protocol);
                
                while (!unresolved_protocol_list -> empty()) {
                    auto protocol_being_resolved = * unresolved_protocol_list -> cbegin();
                    unresolved_protocol_list -> pop_front();
                    
                    if (!_hasSetHierarchyForProtocol(protocol_being_resolved)) {
                        
                        auto conformed_protocol_list = std::make_unique<_ObjCProtocolList>();
                        
                        unsigned int conformed_protocol_count = 0;
                        auto conformed_protocols = protocol_copyProtocolList(protocol_being_resolved, &conformed_protocol_count);
                        
                        for (unsigned int index = 0; index < conformed_protocol_count; index ++) {
                            auto conformed_protocol = conformed_protocols[index];
                            
                            conformed_protocol_list -> push_back(conformed_protocol);
                            unresolved_protocol_list -> push_back(conformed_protocol);
                        }
                        
                        free(conformed_protocols);
                        
                        _setHierarchyForProtocol(protocol_being_resolved, std::move(conformed_protocol_list));
                    }
                    
                    resolved_protocol_set -> insert(protocol_being_resolved);
                }
            }
            
        }
    }
    
#pragma mark Accessing Elements in Registered Protocol Graph
    _ObjCProtocolHierarchyGraph& _ObjCGraftingResolver::_protocolHierarchyGraph() {
        return *protocol_hierarchy_graph_;
    }
    
    bool _ObjCGraftingResolver::_hasSetHierarchyForProtocol(Protocol * __unsafe_unretained protocol) {
        auto position = protocol_hierarchy_graph_ -> find(protocol);
        if (position == protocol_hierarchy_graph_ -> cend()) {
            return false;
        }
        return true;
    }
    
    _ObjCProtocolList& _ObjCGraftingResolver::_hierarchyForProtocol(Protocol * __unsafe_unretained protocol) {
        auto position = protocol_hierarchy_graph_ -> find(protocol);
        return * position -> second;
    }
    
    void _ObjCGraftingResolver::_setHierarchyForProtocol(Protocol * __unsafe_unretained protocol, std::unique_ptr<_ObjCProtocolList> protocol_list) {
        protocol_hierarchy_graph_ -> emplace(protocol, std::move(protocol_list));
    }
}
