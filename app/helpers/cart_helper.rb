module CartHelper

  def add_to_my_cart(title, target)
    link_to title, 
      '#', 
      :class => 'btn btn-large', 
      'add-to-cart' => target, 
      'add-to-action' => add_to_cart_person_path(current_user.login)
  end

  def cart_clear_list
    clear_cart_list_person_path(current_user)
  end
end