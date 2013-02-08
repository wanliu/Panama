# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :inline, :class => 'inline' do |b|
    b.use :input
  end

  config.wrappers :inline_label, :class => 'inline' do |b|
    b.use :html5
    b.use :placeholder  
    b.wrapper :tag => 'label', :class => 'span2 control-label' do |bl|
      bl.use :label_text
    end
    b.use :input
  end
end
