[1m[1;34mActiveSupport::Configurable#methods[0m[0m: config
[1m[1;34mAbstractController::Base#methods[0m[0m: 
  action_methods  action_name  action_name=  available_action?  controller_path  response_body
[1m[1;34mActionController::Metal#methods[0m[0m: 
  controller_name  env=      middleware_stack   middleware_stack?  params=     request   response   session
  env              headers=  middleware_stack=  params             performed?  request=  response=  to_a   
[1m[1;34mAbstractController::ViewPaths#methods[0m[0m: 
  _prefixes         details_for_lookup  formats=  locale=         prepend_view_path  view_paths
  append_view_path  formats             locale    lookup_context  template_exists? 
[1m[1;34mAbstractController::Rendering#methods[0m[0m: 
  process  view_assigns  view_context_class  view_context_class=  view_renderer
[1m[1;34mAbstractController::Layouts#methods[0m[0m: 
  _layout_conditions  action_has_layout=  action_has_layout?  conditional_layout?
[1m[1;34mAbstractController::Translation#methods[0m[0m: localize  t  translate
[1m[1;34mActionDispatch::Routing::PolymorphicRoutes#methods[0m[0m: 
  edit_polymorphic_path  new_polymorphic_path  polymorphic_path
  edit_polymorphic_url   new_polymorphic_url   polymorphic_url 
[1m[1;34mActionDispatch::Routing::UrlFor#methods[0m[0m: url_for
[1m[1;34mActionController::UrlFor#methods[0m[0m: url_options
[1m[1;34mActiveSupport::Benchmarkable#methods[0m[0m: benchmark  silence
[1m[1;34mActionController::RackDelegation#methods[0m[0m: 
  content_type   dispatch  location   reset_session   status 
  content_type=  headers   location=  response_body=  status=
[1m[1;34mActionController::Rendering#methods[0m[0m: render_to_string
[1m[1;34mActionController::Renderers#methods[0m[0m: 
  _handle_render_options  _render_option_js  _render_option_json  _render_option_xml
[1m[1;34mActionController::Head#methods[0m[0m: head
[1m[1;34mActionController::ConditionalGet#methods[0m[0m: expires_in  expires_now  fresh_when  stale?
[1m[1;34mActiveSupport::Callbacks#methods[0m[0m: run_callbacks
[1m[1;34mActionController::Caching::Actions#methods[0m[0m: _save_fragment
[1m[1;34mActionController::Caching::Pages#methods[0m[0m: cache_page  expire_page
[1m[1;34mActionController::Caching::ConfigMethods#methods[0m[0m: cache_store  cache_store=
[1m[1;34mActionController::Caching::Fragments#methods[0m[0m: 
  expire_fragment     fragment_exist?            read_fragment 
  fragment_cache_key  instrument_fragment_cache  write_fragment
[1m[1;34mActionController::Caching#methods[0m[0m: caching_allowed?
[1m[1;34mActionController::ImplicitRender#methods[0m[0m: default_render  send_action
[1m[1;34mActionController::MimeResponds#methods[0m[0m: respond_to  respond_with
[1m[1;34mActionController::RecordIdentifier#methods[0m[0m: dom_class  dom_id
[1m[1;34mActionController::HttpAuthentication::Basic::ControllerMethods#methods[0m[0m: 
  authenticate_or_request_with_http_basic  authenticate_with_http_basic  request_http_basic_authentication
[1m[1;34mActionController::HttpAuthentication::Digest::ControllerMethods#methods[0m[0m: 
  authenticate_or_request_with_http_digest  request_http_digest_authentication
  authenticate_with_http_digest           
[1m[1;34mActionController::HttpAuthentication::Token::ControllerMethods#methods[0m[0m: 
  authenticate_or_request_with_http_token  authenticate_with_http_token  request_http_token_authentication
[1m[1;34mActiveSupport::Rescuable#methods[0m[0m: handler_for_rescue
[1m[1;34mActionController::Rescue#methods[0m[0m: rescue_with_handler  show_detailed_exceptions?
[1m[1;34mActionController::Instrumentation#methods[0m[0m: redirect_to  send_data  send_file  view_runtime  view_runtime=
[1m[1;34mActionController::Compatibility#methods[0m[0m: 
  _handle_method_missing  assign_shortcuts           method_for_action
  _normalize_options      initialize_template_class  render_to_body   
[1m[1;34mCells::Rails::ActionController#methods[0m[0m: cell  cell_for  expire_cell_state  render_cell
[1m[1;34mCanCan::ControllerAdditions#methods[0m[0m: authorize!  can?  cannot?  unauthorized!
[1m[1;34mActionDispatch::Routing::RouteSet::MountedHelpers#methods[0m[0m: _main_app  main_app
[1m[1;34mActiveRecord::Railties::ControllerRuntime#methods[0m[0m: db_runtime  db_runtime=
[1m[1;34mDraper::ViewContext#methods[0m[0m: view_context
[1m[1;34mNewRelic::Agent::Instrumentation::Rails3::Errors#methods[0m[0m: newrelic_notice_error
[1m[1;34mNewRelic::Agent::Instrumentation::ControllerInstrumentation#methods[0m[0m: 
  perform_action_with_newrelic_trace  recorded_metrics
[1m[1;34mNewRelic::Agent::Instrumentation::Rails3::ActionController#methods[0m[0m: newrelic_metric_path  process_action
[1m[1;34mDevise::Controllers::SignInOut#methods[0m[0m: sign_in  sign_out  sign_out_all_scopes  signed_in?
[1m[1;34mDevise::Controllers::StoreLocation#methods[0m[0m: store_location_for  stored_location_for
[1m[1;34mDevise::Controllers::Helpers#methods[0m[0m: 
  after_sign_in_path_for        devise_parameter_sanitizer  request_format         warden
  after_sign_out_path_for       handle_unverified_request   sign_in_and_redirect 
  allow_params_authentication!  is_flashing_format?         sign_out_and_redirect
  devise_controller?            is_navigational_format?     signed_in_root_path  
[1m[1;34mActionController::Base#methods[0m[0m: 
  _callback_before_23             asset_path                    page_cache_compression           
  _helper_methods                 asset_path=                   page_cache_compression=          
  _helper_methods=                assets_dir                    page_cache_compression?          
  _helper_methods?                assets_dir=                   page_cache_directory             
  _helpers                        default_asset_host_protocol   page_cache_directory=            
  _helpers=                       default_asset_host_protocol=  page_cache_directory?            
  _helpers?                       default_url_options           page_cache_extension             
  _layout_conditions=             default_url_options=          page_cache_extension=            
  _layout_conditions?             default_url_options?          page_cache_extension?            
  _one_time_conditions_valid_24?  flash                         perform_caching                  
  _process_action_callbacks       helpers_path                  perform_caching=                 
  _process_action_callbacks=      helpers_path=                 protected_instance_variables     
  _process_action_callbacks?      helpers_path?                 protected_instance_variables=    
  _renderers                      hidden_actions                protected_instance_variables?    
  _renderers=                     hidden_actions=               relative_url_root                
  _renderers?                     hidden_actions?               relative_url_root=               
  _view_paths                     include_all_helpers           request_forgery_protection_token 
  _view_paths=                    include_all_helpers=          request_forgery_protection_token=
  _view_paths?                    include_all_helpers?          rescue_action                    
  _wrapper_options                javascripts_dir               rescue_handlers                  
  _wrapper_options=               javascripts_dir=              rescue_handlers=                 
  _wrapper_options?               logger                        rescue_handlers?                 
  alert                           logger=                       responder                        
  allow_forgery_protection        mimes_for_respond_to          responder=                       
  allow_forgery_protection=       mimes_for_respond_to=         responder?                       
  asset_host                      mimes_for_respond_to?         stylesheets_dir                  
  asset_host=                     notice                        stylesheets_dir=                 
[1m[1;34m#<Module:0x000000089459f0>#methods[0m[0m: _routes
[1m[1;34m#<Module:0x00000008bb1770>#methods[0m[0m: 
  activities_auction_index_path                       new_contact_friend_path                           
  activities_auction_index_url                        new_contact_friend_url                            
  activities_auction_path                             new_content_path                                  
  activities_auction_url                              new_content_url                                   
  activities_courage_index_path                       new_delivery_type_path                            
  activities_courage_index_url                        new_delivery_type_url                             
  activities_courage_path                             new_person_activity_path                          
  activities_courage_url                              new_person_activity_url                           
  activities_focu_path                                new_person_ask_buy_path                           
  activities_focu_url                                 new_person_ask_buy_url                            
  activities_focus_path                               new_person_bank_path                              
  activities_focus_url                                new_person_bank_url                               
  activities_package_index_path                       new_person_cart_path                              
  activities_package_index_url                        new_person_cart_url                               
  activities_package_path                             new_person_circle_path                            
  activities_package_url                              new_person_circle_url                             
  activities_path                                     new_person_community_path                         
  activities_score_index_path                         new_person_community_url                          
  activities_score_index_url                          new_person_delivery_address_path                  
  activities_score_path                               new_person_delivery_address_url                   
  activities_score_url                                new_person_direct_transaction_path                
  activities_url                                      new_person_direct_transaction_url                 
  activity_comments_path                              new_person_following_path                         
  activity_comments_url                               new_person_following_url                          
  activity_path                                       new_person_notification_path                      
  activity_url                                        new_person_notification_url                       
  add_price_options_system_category_path              new_person_order_refund_path                      
  add_price_options_system_category_url               new_person_order_refund_url                       
  add_to_cart_path                                    new_person_path                                   
  add_to_cart_url                                     new_person_product_comment_path                   
  addedyou_person_circles_path                        new_person_product_comment_url                    
  addedyou_person_circles_url                         new_person_topic_path                             
  after_signup_index_path                             new_person_topic_url                              
  after_signup_index_url                              new_person_transaction_path                       
  after_signup_path                                   new_person_transaction_url                        
  after_signup_url                                    new_person_url                                    
  agree_join_community_invite_path                    new_person_withdraw_money_path                    
  agree_join_community_invite_url                     new_person_withdraw_money_url                     
  agree_join_community_notification_path              new_plus_system_categories_path                   
  agree_join_community_notification_url               new_plus_system_categories_url                    
  agree_system_order_refund_path                      new_plus_system_products_path                     
  agree_system_order_refund_url                       new_plus_system_products_url                      
  all_attach_attributes_system_category_path          new_plus_system_regions_path                      
  all_attach_attributes_system_category_url           new_plus_system_regions_url                       
  all_circles_person_communities_path                 new_product_comments_path                         
  all_circles_person_communities_url                  new_product_comments_url                          
  all_friends_person_circles_path                     new_product_path                                  
  all_friends_person_circles_url                      new_product_search_path                           
  all_friends_shop_admins_circles_path                new_product_search_url                            
  all_friends_shop_admins_circles_url                 new_product_url                                   
  answer_ask_buy_index_path                           new_receive_order_message_path                    
  answer_ask_buy_index_url                            new_receive_order_message_url                     
  answer_ask_buy_path                                 new_shop_admins_bank_path                         
  answer_ask_buy_url                                  new_shop_admins_bank_url                          
  apotomo_event_path                                  new_shop_admins_category_path                     
  apotomo_event_url                                   new_shop_admins_category_url                      
  append_item_system_property_path                    new_shop_admins_circle_path                       
  append_item_system_property_url                     new_shop_admins_circle_url                        
  apply_join_community_circles_path                   new_shop_admins_community_path                    
  apply_join_community_circles_url                    new_shop_admins_community_url                     
  apply_join_person_circles_path                      new_shop_admins_complaint_path                    
  apply_join_person_circles_url                       new_shop_admins_complaint_url                     
  ask_buy_index_path                                  new_shop_admins_content_path                      
  ask_buy_index_url                                   new_shop_admins_content_url                       
  ask_buy_path                                        new_shop_admins_dashboard_path                    
  ask_buy_url                                         new_shop_admins_dashboard_url                     
  attach_properties_system_product_path               new_shop_admins_direct_transaction_path           
  attach_properties_system_product_url                new_shop_admins_direct_transaction_url            
  attachments_path                                    new_shop_admins_employee_path                     
  attachments_upload_path                             new_shop_admins_employee_url                      
  attachments_upload_url                              new_shop_admins_following_path                    
  attachments_url                                     new_shop_admins_following_url                     
  audit_failure_system_order_transaction_path         new_shop_admins_group_path                        
  audit_failure_system_order_transaction_url          new_shop_admins_group_url                         
  audit_system_order_transaction_path                 new_shop_admins_menu_path                         
  audit_system_order_transaction_url                  new_shop_admins_menu_url                          
  auth_failure_path                                   new_shop_admins_order_refund_path                 
  auth_failure_url                                    new_shop_admins_order_refund_url                  
  base_info_person_transaction_path                   new_shop_admins_product_comment_path              
  base_info_person_transaction_url                    new_shop_admins_product_comment_url               
  base_info_product_path                              new_shop_admins_product_path                      
  base_info_product_url                               new_shop_admins_product_url                       
  batch_action_system_activities_path                 new_shop_admins_receive_order_message_path        
  batch_action_system_activities_url                  new_shop_admins_receive_order_message_url         
  batch_action_system_admin_users_path                new_shop_admins_shop_product_path                 
  batch_action_system_admin_users_url                 new_shop_admins_shop_product_url                  
  batch_action_system_categories_path                 new_shop_admins_template_path                     
  batch_action_system_categories_url                  new_shop_admins_template_url                      
  batch_action_system_comments_path                   new_shop_admins_topic_path                        
  batch_action_system_comments_url                    new_shop_admins_topic_url                         
  batch_action_system_order_refunds_path              new_shop_admins_transaction_path                  
  batch_action_system_order_refunds_url               new_shop_admins_transaction_url                   
  batch_action_system_order_transactions_path         new_shop_admins_transport_path                    
  batch_action_system_order_transactions_url          new_shop_admins_transport_url                     
  batch_action_system_products_path                   new_shop_path                                     
  batch_action_system_products_url                    new_shop_product_path                             
  batch_action_system_properties_path                 new_shop_product_url                              
  batch_action_system_properties_url                  new_shop_url                                      
  batch_action_system_regions_path                    new_system_activity_path                          
  batch_action_system_regions_url                     new_system_activity_url                           
  batch_action_system_settings_path                   new_system_admin_user_path                        
  batch_action_system_settings_url                    new_system_admin_user_url                         
  batch_action_system_shops_path                      new_system_category_path                          
  batch_action_system_shops_url                       new_system_category_url                           
  batch_action_system_user_checkings_path             new_system_order_refund_path                      
  batch_action_system_user_checkings_url              new_system_order_refund_url                       
  batch_action_system_withdraw_moneys_path            new_system_order_transaction_path                 
  batch_action_system_withdraw_moneys_url             new_system_order_transaction_url                  
  batch_create_person_transactions_path               new_system_product_path                           
  batch_create_person_transactions_url                new_system_product_url                            
  batch_property_values_system_category_path          new_system_property_path                          
  batch_property_values_system_category_url           new_system_property_url                           
  buy_activity_path                                   new_system_region_path                            
  buy_activity_url                                    new_system_region_url                             
  buy_shop_product_path                               new_system_setting_path                           
  buy_shop_product_url                                new_system_setting_url                            
  card_person_order_refund_path                       new_system_shop_path                              
  card_person_order_refund_url                        new_system_shop_url                               
  card_person_transaction_path                        new_system_withdraw_money_path                    
  card_person_transaction_url                         new_system_withdraw_money_url                     
  card_shop_admins_order_refund_path                  new_user_auth_path                                
  card_shop_admins_order_refund_url                   new_user_auth_url                                 
  card_shop_admins_transaction_path                   new_user_path                                     
  card_shop_admins_transaction_url                    new_user_url                                      
  catalog_delete_system_categories_path               notify_person_transaction_path                    
  catalog_delete_system_categories_url                notify_person_transaction_url                     
  catalog_index_path                                  operator_person_direct_transaction_path           
  catalog_index_system_categories_path                operator_person_direct_transaction_url            
  catalog_index_system_categories_url                 operator_person_transaction_path                  
  catalog_index_url                                   operator_person_transaction_url                   
  catalog_path                                        operator_shop_admins_direct_transaction_path      
  catalog_products_path                               operator_shop_admins_direct_transaction_url       
  catalog_products_url                                operator_shop_admins_transaction_path             
  catalog_url                                         operator_shop_admins_transaction_url              
  categories_id_catalog_path                          page_person_direct_transaction_path               
  categories_id_catalog_url                           page_person_direct_transaction_url                
  category_children_shop_admins_categories_path       page_person_order_refund_path                     
  category_children_shop_admins_categories_url        page_person_order_refund_url                      
  category_full_name_shop_admins_categories_path      page_person_transaction_path                      
  category_full_name_shop_admins_categories_url       page_person_transaction_url                       
  category_index_path                                 page_shop_admins_direct_transaction_path          
  category_index_url                                  page_shop_admins_direct_transaction_url           
  category_page_shop_admins_products_path             page_shop_admins_order_refund_path                
  category_page_shop_admins_products_url              page_shop_admins_order_refund_url                 
  category_path                                       page_shop_admins_transaction_path                 
  category_root_shop_admins_categories_path           page_shop_admins_transaction_url                  
  category_root_shop_admins_categories_url            participate_community_topic_path                  
  category_search_shop_admins_categories_path         participate_community_topic_url                   
  category_search_shop_admins_categories_url          participates_community_topic_path                 
  category_url                                        participates_community_topic_url                  
  change_number_person_cart_path                      payment_person_recharges_path                     
  change_number_person_cart_url                       payment_person_recharges_url                      
  channels_users_path                                 pending_index_path                                
  channels_users_url                                  pending_index_url                                 
  chat_message_path                                   people_path                                       
  chat_message_url                                    people_shop_admins_communities_path               
  chat_messages_path                                  people_shop_admins_communities_url                
  chat_messages_url                                   people_url                                        
  check_system_activity_path                          person_activities_path                            
  check_system_activity_url                           person_activities_url                             
  check_system_user_checking_path                     person_activity_path                              
  check_system_user_checking_url                      person_activity_url                               
  children_category_system_category_path              person_ask_buy_index_path                         
  children_category_system_category_url               person_ask_buy_index_url                          
  children_table_system_category_path                 person_ask_buy_path                               
  children_table_system_category_url                  person_ask_buy_url                                
  city_index_path                                     person_bank_path                                  
  city_index_url                                      person_bank_url                                   
  city_path                                           person_banks_path                                 
  city_url                                            person_banks_url                                  
  clear_cart_list_path                                person_cart_index_path                            
  clear_cart_list_url                                 person_cart_index_url                             
  close_system_order_refund_path                      person_cart_path                                  
  close_system_order_refund_url                       person_cart_url                                   
  comment_ask_buy_path                                person_circle_path                                
  comment_ask_buy_url                                 person_circle_url                                 
  comment_path                                        person_circles_path                               
  comment_url                                         person_circles_url                                
  comments_community_topic_path                       person_communities_path                           
  comments_community_topic_url                        person_communities_url                            
  comments_path                                       person_community_path                             
  comments_system_category_path                       person_community_url                              
  comments_system_category_url                        person_delivery_address_path                      
  comments_url                                        person_delivery_address_url                       
  communities_path                                    person_delivery_addresses_path                    
  communities_url                                     person_delivery_addresses_url                     
  community_access_denied_path                        person_direct_transaction_path                    
  community_access_denied_url                         person_direct_transaction_url                     
  community_categories_path                           person_direct_transactions_path                   
  community_categories_url                            person_direct_transactions_url                    
  community_category_path                             person_followers_path                             
  community_category_url                              person_followers_url                              
  community_circles_path                              person_following_path                             
  community_circles_url                               person_following_url                              
  community_invite_index_path                         person_followings_path                            
  community_invite_index_url                          person_followings_url                             
  community_invite_path                               person_my_activity_path                           
  community_invite_url                                person_my_activity_url                            
  community_notification_path                         person_notification_path                          
  community_notification_url                          person_notification_url                           
  community_notifications_path                        person_notifications_path                         
  community_notifications_url                         person_notifications_url                          
  community_path                                      person_order_refund_path                          
  community_topic_path                                person_order_refund_url                           
  community_topic_url                                 person_order_refunds_path                         
  community_topics_path                               person_order_refunds_url                          
  community_topics_url                                person_path                                       
  community_url                                       person_product_comment_path                       
  complete_index_path                                 person_product_comment_url                        
  complete_index_url                                  person_product_comments_path                      
  completed_person_direct_transaction_path            person_product_comments_url                       
  completed_person_direct_transaction_url             person_recharge_path                              
  completed_person_transactions_path                  person_recharge_url                               
  completed_person_transactions_url                   person_recharges_path                             
  completed_system_withdraw_money_path                person_recharges_url                              
  completed_system_withdraw_money_url                 person_topic_path                                 
  completing_people_path                              person_topic_url                                  
  completing_people_url                               person_topics_path                                
  completing_person_path                              person_topics_url                                 
  completing_person_url                               person_transaction_path                           
  completing_shop_index_path                          person_transaction_url                            
  completing_shop_index_url                           person_transactions_path                          
  completing_shop_path                                person_transactions_url                           
  completing_shop_url                                 person_url                                        
  contact_friend_path                                 person_withdraw_money_index_path                  
  contact_friend_url                                  person_withdraw_money_index_url                   
  contact_friends_path                                person_withdraw_money_path                        
  contact_friends_url                                 person_withdraw_money_url                         
  content_path                                        price_options_system_category_path                
  content_url                                         price_options_system_category_url                 
  contents_path                                       print_person_transaction_path                     
  contents_url                                        print_person_transaction_url                      
  count_comments_path                                 print_shop_admins_transaction_path                
  count_comments_url                                  print_shop_admins_transaction_url                 
  create_comment_community_topic_path                 product_comments_path                             
  create_comment_community_topic_url                  product_comments_url                              
  create_hot_system_categories_path                   product_path                                      
  create_hot_system_categories_url                    product_search_index_path                         
  create_order_answer_ask_buy_path                    product_search_index_url                          
  create_order_answer_ask_buy_url                     product_search_path                               
  create_plus_system_categories_path                  product_search_url                                
  create_plus_system_categories_url                   product_url                                       
  create_plus_system_products_path                    products_catalog_path                             
  create_plus_system_products_url                     products_catalog_url                              
  create_property_value_system_category_path          products_category_path                            
  create_property_value_system_category_url           products_category_url                             
  create_region_system_regions_path                   products_index_path                               
  create_region_system_regions_url                    products_index_url                                
  delay_sign_person_transaction_path                  products_path                                     
  delay_sign_person_transaction_url                   products_url                                      
  delete_many_shop_product_path                       properties_system_category_path                   
  delete_many_shop_product_url                        properties_system_category_url                    
  delete_property_value_system_category_path          properties_system_product_path                    
  delete_property_value_system_category_url           properties_system_product_url                     
  delete_relation_system_category_path                property_values_system_category_path              
  delete_relation_system_category_url                 property_values_system_category_url               
  delete_system_property_path                         province_city_index_path                          
  delete_system_property_url                          province_city_index_url                           
  delivery_type_path                                  quit_circle_community_circles_path                
  delivery_type_url                                   quit_circle_community_circles_url                 
  delivery_types_path                                 rails_info_properties_path                        
  delivery_types_url                                  rails_info_properties_url                         
  destroy_circle_community_circles_path               read_all_person_notifications_path                
  destroy_circle_community_circles_url                read_all_person_notifications_url                 
  dialog_person_direct_transaction_path               receive_order_message_path                        
  dialog_person_direct_transaction_url                receive_order_message_url                         
  dialog_shop_admins_direct_transaction_path          receive_order_messages_path                       
  dialog_shop_admins_direct_transaction_url           receive_order_messages_url                        
  dialogue_person_transaction_path                    receive_person_recharge_path                      
  dialogue_person_transaction_url                     receive_person_recharge_url                       
  dialogue_shop_admins_transaction_path               refund_person_transaction_path                    
  dialogue_shop_admins_transaction_url                refund_person_transaction_url                     
  direct_buy_shop_product_path                        refuse_join_community_invite_path                 
  direct_buy_shop_product_url                         refuse_join_community_invite_url                  
  dispose_shop_admins_direct_transaction_path         refuse_join_community_notification_path           
  dispose_shop_admins_direct_transaction_url          refuse_join_community_notification_url            
  dispose_shop_admins_transaction_path                refuse_reason_shop_admins_order_refund_path       
  dispose_shop_admins_transaction_url                 refuse_reason_shop_admins_order_refund_url        
  done_person_transaction_path                        reject_system_activity_path                       
  done_person_transaction_url                         reject_system_activity_url                        
  edit_activities_auction_path                        reject_system_user_checking_path                  
  edit_activities_auction_url                         reject_system_user_checking_url                   
  edit_activities_courage_path                        relate_property_system_category_path              
  edit_activities_courage_url                         relate_property_system_category_url               
  edit_activities_focu_path                           remove_member_community_circles_path              
  edit_activities_focu_url                            remove_member_community_circles_url               
  edit_activities_package_path                        reply_shop_admins_product_comment_path            
  edit_activities_package_url                         reply_shop_admins_product_comment_url             
  edit_activities_score_path                          root_path                                         
  edit_activities_score_url                           root_url                                          
  edit_activity_path                                  schedule_sort1_system_activities_path             
  edit_activity_url                                   schedule_sort1_system_activities_url              
  edit_address_completing_person_path                 schedule_sort_system_activities_path              
  edit_address_completing_person_url                  schedule_sort_system_activities_url               
  edit_address_completing_shop_path                   search_all_path                                   
  edit_address_completing_shop_url                    search_all_url                                    
  edit_after_signup_path                              search_circles_path                               
  edit_after_signup_url                               search_circles_url                                
  edit_answer_ask_buy_path                            search_communities_path                           
  edit_answer_ask_buy_url                             search_communities_url                            
  edit_ask_buy_path                                   search_path                                       
  edit_ask_buy_url                                    search_products_path                              
  edit_catalog_path                                   search_products_url                               
  edit_catalog_url                                    search_property_value_system_category_path        
  edit_category_path                                  search_property_value_system_category_url         
  edit_category_url                                   search_shop_circles_path                          
  edit_chat_message_path                              search_shop_circles_url                           
  edit_chat_message_url                               search_shop_products_path                         
  edit_city_path                                      search_shop_products_url                          
  edit_city_url                                       search_shops_path                                 
  edit_comment_path                                   search_shops_url                                  
  edit_comment_url                                    search_title_system_properties_path               
  edit_community_category_path                        search_title_system_properties_url                
  edit_community_category_url                         search_url                                        
  edit_community_invite_path                          search_user_checkings_path                        
  edit_community_invite_url                           search_user_checkings_url                         
  edit_community_path                                 search_users_path                                 
  edit_community_topic_path                           search_users_url                                  
  edit_community_topic_url                            send_message_person_direct_transaction_path       
  edit_community_url                                  send_message_person_direct_transaction_url        
  edit_completing_person_path                         send_message_person_transaction_path              
  edit_completing_person_url                          send_message_person_transaction_url               
  edit_completing_shop_path                           send_message_shop_admins_direct_transaction_path  
  edit_completing_shop_url                            send_message_shop_admins_direct_transaction_url   
  edit_contact_friend_path                            send_message_shop_admins_transaction_path         
  edit_contact_friend_url                             send_message_shop_admins_transaction_url          
  edit_content_path                                   settings_shop_admins_communities_path             
  edit_content_url                                    settings_shop_admins_communities_url              
  edit_delivery_type_path                             share_activity_activity_path                      
  edit_delivery_type_url                              share_activity_activity_url                       
  edit_info_system_region_path                        share_circle_community_circles_path               
  edit_info_system_region_url                         share_circle_community_circles_url                
  edit_person_activity_path                           shop_admins_apply_update_path                     
  edit_person_activity_url                            shop_admins_apply_update_url                      
  edit_person_ask_buy_path                            shop_admins_bank_path                             
  edit_person_ask_buy_url                             shop_admins_bank_url                              
  edit_person_bank_path                               shop_admins_banks_path                            
  edit_person_bank_url                                shop_admins_banks_url                             
  edit_person_cart_path                               shop_admins_bill_detail_path                      
  edit_person_cart_url                                shop_admins_bill_detail_url                       
  edit_person_circle_path                             shop_admins_categories_path                       
  edit_person_circle_url                              shop_admins_categories_url                        
  edit_person_community_path                          shop_admins_category_path                         
  edit_person_community_url                           shop_admins_category_url                          
  edit_person_delivery_address_path                   shop_admins_circle_path                           
  edit_person_delivery_address_url                    shop_admins_circle_url                            
  edit_person_direct_transaction_path                 shop_admins_circles_path                          
  edit_person_direct_transaction_url                  shop_admins_circles_url                           
  edit_person_following_path                          shop_admins_communities_path                      
  edit_person_following_url                           shop_admins_communities_url                       
  edit_person_notification_path                       shop_admins_community_path                        
  edit_person_notification_url                        shop_admins_community_url                         
  edit_person_order_refund_path                       shop_admins_complaint_index_path                  
  edit_person_order_refund_url                        shop_admins_complaint_index_url                   
  edit_person_path                                    shop_admins_complaint_path                        
  edit_person_product_comment_path                    shop_admins_complaint_url                         
  edit_person_product_comment_url                     shop_admins_complete_path                         
  edit_person_topic_path                              shop_admins_complete_url                          
  edit_person_topic_url                               shop_admins_content_path                          
  edit_person_transaction_path                        shop_admins_content_url                           
  edit_person_transaction_url                         shop_admins_contents_path                         
  edit_person_url                                     shop_admins_contents_url                          
  edit_person_withdraw_money_path                     shop_admins_create_address_path                   
  edit_person_withdraw_money_url                      shop_admins_create_address_url                    
  edit_plus_system_product_path                       shop_admins_dashboard_index_path                  
  edit_plus_system_product_url                        shop_admins_dashboard_index_url                   
  edit_product_path                                   shop_admins_dashboard_path                        
  edit_product_search_path                            shop_admins_dashboard_url                         
  edit_product_search_url                             shop_admins_direct_transaction_path               
  edit_product_url                                    shop_admins_direct_transaction_url                
  edit_receive_order_message_path                     shop_admins_direct_transactions_path              
  edit_receive_order_message_url                      shop_admins_direct_transactions_url               
  edit_shop_admins_bank_path                          shop_admins_edit_address_path                     
  edit_shop_admins_bank_url                           shop_admins_edit_address_url                      
  edit_shop_admins_category_path                      shop_admins_employee_path                         
  edit_shop_admins_category_url                       shop_admins_employee_url                          
  edit_shop_admins_circle_path                        shop_admins_employees_path                        
  edit_shop_admins_circle_url                         shop_admins_employees_url                         
  edit_shop_admins_community_path                     shop_admins_following_path                        
  edit_shop_admins_community_url                      shop_admins_following_url                         
  edit_shop_admins_complaint_path                     shop_admins_followings_path                       
  edit_shop_admins_complaint_url                      shop_admins_followings_url                        
  edit_shop_admins_content_path                       shop_admins_group_path                            
  edit_shop_admins_content_url                        shop_admins_group_url                             
  edit_shop_admins_dashboard_path                     shop_admins_groups_path                           
  edit_shop_admins_dashboard_url                      shop_admins_groups_url                            
  edit_shop_admins_direct_transaction_path            shop_admins_menu_index_path                       
  edit_shop_admins_direct_transaction_url             shop_admins_menu_index_url                        
  edit_shop_admins_employee_path                      shop_admins_menu_path                             
  edit_shop_admins_employee_url                       shop_admins_menu_url                              
  edit_shop_admins_following_path                     shop_admins_order_refund_path                     
  edit_shop_admins_following_url                      shop_admins_order_refund_url                      
  edit_shop_admins_group_path                         shop_admins_order_refunds_path                    
  edit_shop_admins_group_url                          shop_admins_order_refunds_url                     
  edit_shop_admins_menu_path                          shop_admins_path                                  
  edit_shop_admins_menu_url                           shop_admins_pending_path                          
  edit_shop_admins_order_refund_path                  shop_admins_pending_url                           
  edit_shop_admins_order_refund_url                   shop_admins_product_comment_path                  
  edit_shop_admins_product_comment_path               shop_admins_product_comment_url                   
  edit_shop_admins_product_comment_url                shop_admins_product_comments_path                 
  edit_shop_admins_product_path                       shop_admins_product_comments_url                  
  edit_shop_admins_product_url                        shop_admins_product_path                          
  edit_shop_admins_receive_order_message_path         shop_admins_product_url                           
  edit_shop_admins_receive_order_message_url          shop_admins_products_path                         
  edit_shop_admins_shop_product_path                  shop_admins_products_url                          
  edit_shop_admins_shop_product_url                   shop_admins_receive_order_message_path            
  edit_shop_admins_template_path                      shop_admins_receive_order_message_url             
  edit_shop_admins_template_url                       shop_admins_receive_order_messages_path           
  edit_shop_admins_topic_path                         shop_admins_receive_order_messages_url            
  edit_shop_admins_topic_url                          shop_admins_shop_info_path                        
  edit_shop_admins_transaction_path                   shop_admins_shop_info_url                         
  edit_shop_admins_transaction_url                    shop_admins_shop_product_path                     
  edit_shop_admins_transport_path                     shop_admins_shop_product_url                      
  edit_shop_admins_transport_url                      shop_admins_shop_products_path                    
  edit_shop_path                                      shop_admins_shop_products_url                     
  edit_shop_product_path                              shop_admins_template_path                         
  edit_shop_product_url                               shop_admins_template_url                          
  edit_shop_url                                       shop_admins_templates_path                        
  edit_system_activity_path                           shop_admins_templates_url                         
  edit_system_activity_url                            shop_admins_topic_path                            
  edit_system_admin_user_path                         shop_admins_topic_url                             
  edit_system_admin_user_url                          shop_admins_topics_path                           
  edit_system_category_path                           shop_admins_topics_url                            
  edit_system_category_url                            shop_admins_transaction_path                      
  edit_system_order_refund_path                       shop_admins_transaction_url                       
  edit_system_order_refund_url                        shop_admins_transactions_path                     
  edit_system_order_transaction_path                  shop_admins_transactions_url                      
  edit_system_order_transaction_url                   shop_admins_transport_index_path                  
  edit_system_product_path                            shop_admins_transport_index_url                   
  edit_system_product_url                             shop_admins_transport_path                        
  edit_system_property_path                           shop_admins_transport_url                         
  edit_system_property_url                            shop_admins_update_address_path                   
  edit_system_region_path                             shop_admins_update_address_url                    
  edit_system_region_url                              shop_admins_url                                   
  edit_system_setting_path                            shop_circles_shop_path                            
  edit_system_setting_url                             shop_circles_shop_url                             
  edit_system_shop_path                               shop_path                                         
  edit_system_shop_url                                shop_product_path                                 
  edit_system_withdraw_money_path                     shop_product_url                                  
  edit_system_withdraw_money_url                      shop_products_category_index_path                 
  edit_user_auth_path                                 shop_products_category_index_url                  
  edit_user_auth_url                                  shop_products_path                                
  edit_user_path                                      shop_products_url                                 
  edit_user_url                                       shop_url                                          
  enter_person_notification_path                      shops_path                                        
  enter_person_notification_url                       shops_person_followings_path                      
  failer_system_withdraw_money_path                   shops_person_followings_url                       
  failer_system_withdraw_money_url                    shops_url                                         
  find_by_group_shop_admins_employees_path            skip_completing_person_path                       
  find_by_group_shop_admins_employees_url             skip_completing_person_url                        
  follow_person_path                                  subtree_ids_category_path                         
  follow_person_url                                   subtree_ids_category_url                          
  follow_shop_path                                    system_activities_path                            
  follow_shop_url                                     system_activities_url                             
  followers_shop_admins_circles_path                  system_activity_path                              
  followers_shop_admins_circles_url                   system_activity_url                               
  following_person_topics_path                        system_admin_user_path                            
  following_person_topics_url                         system_admin_user_url                             
  followings_users_path                               system_admin_users_path                           
  followings_users_url                                system_admin_users_url                            
  friends_person_circles_path                         system_categories_path                            
  friends_person_circles_url                          system_categories_url                             
  friends_shop_admins_circles_path                    system_category_path                              
  friends_shop_admins_circles_url                     system_category_url                               
  generate_token_person_direct_transaction_path       system_comment_path                               
  generate_token_person_direct_transaction_url        system_comment_url                                
  generate_token_person_transaction_path              system_comments_path                              
  generate_token_person_transaction_url               system_comments_url                               
  generate_token_shop_admins_direct_transaction_path  system_dashboard_path                             
  generate_token_shop_admins_direct_transaction_url   system_dashboard_url                              
  generate_token_shop_admins_transaction_path         system_logout_path                                
  generate_token_shop_admins_transaction_url          system_logout_url                                 
  get_city_system_regions_path                        system_order_refund_path                          
  get_city_system_regions_url                         system_order_refund_url                           
  get_delivery_price_person_transaction_path          system_order_refunds_path                         
  get_delivery_price_person_transaction_url           system_order_refunds_url                          
  group_join_employee_shop_admins_employees_path      system_order_transaction_path                     
  group_join_employee_shop_admins_employees_url       system_order_transaction_url                      
  group_remove_employee_shop_admins_employees_path    system_order_transactions_path                    
  group_remove_employee_shop_admins_employees_url     system_order_transactions_url                     
  hot_region_name_communities_path                    system_product_path                               
  hot_region_name_communities_url                     system_product_url                                
  index_activities_comments_path                      system_products_path                              
  index_activities_comments_url                       system_products_url                               
  init_comment_community_topic_path                   system_properties_path                            
  init_comment_community_topic_url                    system_properties_url                             
  invite_people_shop_admins_communities_path          system_property_path                              
  invite_people_shop_admins_communities_url           system_property_url                               
  invite_shop_admins_employees_path                   system_region_path                                
  invite_shop_admins_employees_url                    system_region_url                                 
  items_system_property_path                          system_regions_path                               
  items_system_property_url                           system_regions_url                                
  join_activities_auction_path                        system_root_path                                  
  join_activities_auction_url                         system_root_url                                   
  join_activities_focu_path                           system_setting_path                               
  join_activities_focu_url                            system_setting_url                                
  join_ask_buy_path                                   system_settings_path                              
  join_ask_buy_url                                    system_settings_url                               
  join_community_circles_path                         system_shop_path                                  
  join_community_circles_url                          system_shop_url                                   
  kuaiqian_payment_person_transaction_path            system_shops_path                                 
  kuaiqian_payment_person_transaction_url             system_shops_url                                  
  kuaiqian_receive_person_transaction_path            system_user_checking_path                         
  kuaiqian_receive_person_transaction_url             system_user_checking_url                          
  like_activity_path                                  system_user_checkings_path                        
  like_activity_url                                   system_user_checkings_url                         
  likes_person_activities_path                        system_vfs_file_add_path                          
  likes_person_activities_url                         system_vfs_file_add_url                           
  load_category_properties_system_products_path       system_vfs_file_path                              
  load_category_properties_system_products_url        system_vfs_file_url                               
  logout_path                                         system_vfs_path                                   
  logout_url                                          system_vfs_show_file_path                         
  low_to_member_community_circles_path                system_vfs_show_file_url                          
  low_to_member_community_circles_url                 system_vfs_url                                    
  mark_as_read_person_notification_path               system_withdraw_money_path                        
  mark_as_read_person_notification_url                system_withdraw_money_url                         
  mark_as_read_person_transaction_path                system_withdraw_moneys_path                       
  mark_as_read_person_transaction_url                 system_withdraw_moneys_url                        
  members_community_circles_path                      test_payment_person_recharges_path                
  members_community_circles_url                       test_payment_person_recharges_url                 
  messages_person_direct_transaction_path             test_payment_person_transaction_path              
  messages_person_direct_transaction_url              test_payment_person_transaction_url               
  messages_person_transaction_path                    to_cart_activity_path                             
  messages_person_transaction_url                     to_cart_activity_url                              
  messages_shop_admins_communities_path               tomorrow_activities_path                          
  messages_shop_admins_communities_url                tomorrow_activities_url                           
  messages_shop_admins_direct_transaction_path        topic_comments_path                               
  messages_shop_admins_direct_transaction_url         topic_comments_url                                
  messages_shop_admins_transaction_path               topics_community_category_path                    
  messages_shop_admins_transaction_url                topics_community_category_url                     
  mini_item_person_direct_transaction_path            transfer_person_transaction_path                  
  mini_item_person_direct_transaction_url             transfer_person_transaction_url                   
  mini_item_person_order_refund_path                  transport_index_path                              
  mini_item_person_order_refund_url                   transport_index_url                               
  mini_item_person_transaction_path                   trigger_event_person_order_refund_path            
  mini_item_person_transaction_url                    trigger_event_person_order_refund_url             
  mini_item_shop_admins_direct_transaction_path       trigger_event_person_transaction_path             
  mini_item_shop_admins_direct_transaction_url        trigger_event_person_transaction_url              
  mini_item_shop_admins_order_refund_path             trigger_event_shop_admins_order_refund_path       
  mini_item_shop_admins_order_refund_url              trigger_event_shop_admins_order_refund_url        
  mini_item_shop_admins_transaction_path              trigger_event_shop_admins_transaction_path        
  mini_item_shop_admins_transaction_url               trigger_event_shop_admins_transaction_url         
  modify_system_activity_path                         unfollow_person_path                              
  modify_system_activity_url                          unfollow_person_url                               
  modify_template_system_category_path                unfollow_shop_path                                
  modify_template_system_category_url                 unfollow_shop_url                                 
  move_out_cart_person_cart_path                      unjoin_activities_focu_path                       
  move_out_cart_person_cart_url                       unjoin_activities_focu_url                        
  move_out_person_cart_index_path                     unlike_activity_path                              
  move_out_person_cart_index_url                      unlike_activity_url                               
  my_related_shop_admins_topics_path                  unread_count_person_notifications_path            
  my_related_shop_admins_topics_url                   unread_count_person_notifications_url             
  new_activities_auction_path                         unread_messages_person_transactions_path          
  new_activities_auction_url                          unread_messages_person_transactions_url           
  new_activities_courage_path                         unreads_person_notifications_path                 
  new_activities_courage_url                          unreads_person_notifications_url                  
  new_activities_focu_path                            up_to_manager_community_circles_path              
  new_activities_focu_url                             up_to_manager_community_circles_url               
  new_activities_package_path                         update_address_completing_person_path             
  new_activities_package_url                          update_address_completing_person_url              
  new_activities_score_path                           update_address_completing_shop_path               
  new_activities_score_url                            update_address_completing_shop_url                
  new_activity_comments_path                          update_attribute_shop_product_path                
  new_activity_comments_url                           update_attribute_shop_product_url                 
  new_activity_path                                   update_circle_community_circles_path              
  new_activity_url                                    update_circle_community_circles_url               
  new_after_signup_path                               update_delivery_person_order_refund_path          
  new_after_signup_url                                update_delivery_person_order_refund_url           
  new_answer_ask_buy_path                             update_delivery_price_person_order_refund_path    
  new_answer_ask_buy_url                              update_delivery_price_person_order_refund_url     
  new_ask_buy_path                                    update_delivery_price_shop_admins_transaction_path
  new_ask_buy_url                                     update_delivery_price_shop_admins_transaction_url 
  new_catalog_path                                    update_delivery_shop_admins_transaction_path      
  new_catalog_url                                     update_delivery_shop_admins_transaction_url       
  new_category_path                                   update_plus_system_product_path                   
  new_category_url                                    update_plus_system_product_url                    
  new_chat_message_path                               update_template_system_category_path              
  new_chat_message_url                                update_template_system_category_url               
  new_city_path                                       user_auth_path                                    
  new_city_url                                        user_auth_url                                     
  new_comment_path                                    user_auths_path                                   
  new_comment_url                                     user_auths_url                                    
  new_community_category_path                         user_checkings_update_shop_auth_path              
  new_community_category_url                          user_checkings_update_shop_auth_url               
  new_community_invite_path                           user_path                                         
  new_community_invite_url                            user_url                                          
  new_community_path                                  users_path                                        
  new_community_topic_path                            users_url                                         
  new_community_topic_url                             vfs_create_file_path                              
  new_community_url                                   vfs_create_file_url                               
  new_completing_person_path                          vfs_destroy_file_path                             
  new_completing_person_url                           vfs_destroy_file_url                              
  new_completing_shop_path                            vfs_edit_file_path                                
  new_completing_shop_url                             vfs_edit_file_url                                 
[1m[1;34mWidgetHelper#methods[0m[0m: apppend_class  collapse_button  state_button  trigget
[1m[1;34mContentsHelper#methods[0m[0m: 
  content_tpl_path      generate_template      register_value           value_for
  extract_temp_options  in_view?               render_content           values   
  fs                    prepend_tpl_view_path  render_content_template
[1m[1;34mApplicationHelper#methods[0m[0m: 
  account_info           current_shop                  link_to_account     recharge_payment_url     
  accounts_provider_url  current_user                  link_to_admin       register_javascript      
  action_controller      default_img_url               link_to_community   render_base_template     
  breadcrumb_button      default_title                 link_to_logout      search_box               
  build_menu             display_title                 link_to_mycart      shop_recently_friends    
  build_menu2            dispose_options               link_to_notice      side_nav_for             
  caret                  find_resource_by              my_cart             site_name                
  circle_active          get_delivery_type             my_likes            token                    
  city_by_ip             has_right_to_answer_ask_buy?  options_dom_id      unread_notification_count
  city_ids               icon                          payment_mode?       upload_tip               
  community_active       industry_title                payment_order_path  user_recently_friends    
  controller_title       javascripts_codes             product_join_state
  current_admin          l                             realtime_uri      
[1m[1;34mOmniAuth::Wanliu::AjaxHelpers#methods[0m[0m: 
  ajax_set_response_headers  auth_params  authorize_url  foreg_ajax_auth  wanliu_omniauth_options
[1m[1;34mApotomo::WidgetShortcuts#methods[0m[0m: widget
[1m[1;34mApotomo::Rails::ControllerMethods#methods[0m[0m: 
  apotomo_request_processor  apotomo_root  render_event_response  render_widget  url_for_event
[1m[1;34mApplicationController#methods[0m[0m: 
  _one_time_conditions_valid_27379?  filter_special_sym          login_required                        
  _one_time_conditions_valid_27381?  generate_auth_string        login_required_without_service_choosen
  admin_required                     get_city                    login_required_without_service_seller 
  auth_redirect                      load_category               set_locale                            
  configure_callback_url             login_and_service_required  to_csv                                
  draw_errors_message                login_or_admin_required     validate_auth_string                  
[1m[1;34mAdmins::BaseController#methods[0m[0m: _one_time_conditions_valid_27383?  section  sections
[1m[1;34mAdmins::Shops::SectionController#methods[0m[0m: 
  _one_time_conditions_valid_27385?  ajaxify_pages_names=  current_section
  ajaxify_pages_names                current_ability       render         
[1m[1;34mAdmins::Shops::CommunitiesController#methods[0m[0m: index  invite_people  people
[1m[1;34minstance variables[0m[0m: 
  [0;34m@_action_has_layout[0m  [0;34m@_env[0m             [0;34m@_params[0m    [0;34m@_response[0m       [0;34m@_status[0m     
  [0;34m@_action_name[0m        [0;34m@_headers[0m         [0;34m@_prefixes[0m  [0;34m@_response_body[0m  [0;34m@current_shop[0m
  [0;34m@_config[0m             [0;34m@_lookup_context[0m  [0;34m@_request[0m   [0;34m@_routes[0m         [0;34m@current_user[0m
[1m[1;34mclass variables[0m[0m: [1;34m@@ajaxify_pages_names[0m  [1;34m@@javascripts_codes[0m  [1;34m@@sections[0m
[1m[1;34mlocals[0m[0m: _  __  _dir_  _ex_  _file_  _in_  _out_  _pry_  [0;33mids[0m
